import asyncio
import json
import time
from datetime import datetime, timezone
from uuid import UUID, uuid4

from fastapi import WebSocket, WebSocketDisconnect
from jose import JWTError
from supabase import Client

from app.audio.parameter_mapper import map_parameters
from app.audio.service import AudioService
from app.auth.jwt import jwt_validator
from app.sessions.classifier import classify
from app.sessions.schemas import BiometricPacket, SleepStage
from app.soundscapes.catalog import SOUNDSCAPES_BY_ID

# Minimum seconds a stage must persist before triggering stem generation
STAGE_DEBOUNCE_SECONDS = 60


class BiometricWebSocketHandler:
    def __init__(self, websocket: WebSocket, session_id: UUID, user_id: UUID, supabase: Client):
        self.websocket = websocket
        self.session_id = session_id
        self.user_id = user_id
        self.supabase = supabase
        self.audio_service = AudioService(supabase)

        self.previous_stage: SleepStage | None = None
        self.stage_since: float = 0  # timestamp when current stage started
        self.session_start: datetime | None = None
        self.soundscape_id: str = ""

        # Biometric buffer for batch inserts
        self._buffer: list[dict] = []
        self._buffer_flush_interval = 30  # seconds
        self._last_flush = time.time()

    async def handle(self):
        """Main WebSocket loop."""
        # Fetch session metadata
        result = (
            self.supabase.table("sleep_sessions")
            .select("*")
            .eq("id", str(self.session_id))
            .single()
            .execute()
        )
        session = result.data
        if not session or session["user_id"] != str(self.user_id):
            await self.websocket.close(code=4004, reason="Session not found")
            return
        if session.get("ended_at"):
            await self.websocket.close(code=4009, reason="Session already ended")
            return

        self.session_start = datetime.fromisoformat(session["started_at"])
        self.soundscape_id = session["soundscape_used"]

        try:
            while True:
                raw = await asyncio.wait_for(self.websocket.receive_text(), timeout=90)
                await self._process_message(raw)
        except WebSocketDisconnect:
            await self._flush_buffer()
        except asyncio.TimeoutError:
            await self._flush_buffer()
            await self.websocket.close(code=1000, reason="Timeout — no data received")

    async def _process_message(self, raw: str):
        try:
            data = json.loads(raw)
            packet = BiometricPacket(**data)
        except (json.JSONDecodeError, Exception) as e:
            await self.websocket.send_json({"error": f"Invalid message: {e}"})
            return

        # Classify sleep stage
        elapsed_min = (packet.recorded_at - self.session_start).total_seconds() / 60 if self.session_start else 0
        stage = classify(packet, elapsed_min)

        # Compute audio parameters
        soundscape = SOUNDSCAPES_BY_ID.get(self.soundscape_id)
        if not soundscape:
            await self.websocket.send_json({"error": "Unknown soundscape"})
            return

        params = map_parameters(packet, stage, soundscape)

        # Send parameters immediately
        response: dict = {
            "type": "parameters",
            "stage": stage.value,
            "audioParameters": params.model_dump(by_alias=True),
        }
        await self.websocket.send_json(response)

        # Detect stage transition and trigger stem generation
        now = time.time()
        if stage != self.previous_stage:
            if self.previous_stage is not None and (now - self.stage_since) >= STAGE_DEBOUNCE_SECONDS:
                # Fire-and-forget stem generation
                asyncio.create_task(self._generate_and_push_stem(stage))
            self.previous_stage = stage
            self.stage_since = now

        # Buffer biometric event
        self._buffer.append({
            "id": str(uuid4()),
            "session_id": str(self.session_id),
            "recorded_at": packet.recorded_at.isoformat(),
            "hr": packet.heart_rate,
            "hrv": packet.hrv,
            "spo2": packet.spo2,
            "respiratory_rate": packet.respiratory_rate,
            "motion_intensity": packet.motion_intensity,
        })

        # Flush buffer periodically
        if now - self._last_flush >= self._buffer_flush_interval:
            await self._flush_buffer()

    async def _generate_and_push_stem(self, stage: SleepStage):
        try:
            stem = await self.audio_service.generate_stem(self.soundscape_id, stage)
            await self.websocket.send_json({
                "type": "stem",
                "stemUrl": stem.stem_url,
                "stemId": stem.stem_id,
                "stage": stage.value,
                "crossfadeDuration": 5.0,
            })
        except Exception:
            # Stem generation failure is non-fatal — client keeps playing current audio
            pass

    async def _flush_buffer(self):
        if not self._buffer:
            return
        try:
            self.supabase.table("biometric_events").insert(self._buffer).execute()
        except Exception:
            pass  # Best-effort persistence
        self._buffer.clear()
        self._last_flush = time.time()


async def authenticate_websocket(websocket: WebSocket, token: str) -> UUID | None:
    """Validate JWT from WebSocket query param. Returns user_id or None."""
    try:
        claims = await jwt_validator.verify(token)
        user_id = claims.get("sub")
        if user_id:
            return UUID(user_id)
    except (JWTError, ValueError):
        pass
    return None
