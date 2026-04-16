from datetime import datetime, timezone
from uuid import UUID, uuid4

from supabase import Client

from app.sessions.schemas import BiometricPacket, SleepStage, SleepStageInterval
from app.sessions.classifier import classify
from app.sessions.scorer import compute_sleep_score
from app.soundscapes.catalog import SOUNDSCAPES_BY_ID


class SessionService:
    def __init__(self, supabase: Client):
        self.supabase = supabase

    async def start_session(self, user_id: UUID, soundscape_id: str) -> dict:
        if soundscape_id not in SOUNDSCAPES_BY_ID:
            raise ValueError(f"Invalid soundscape_id: {soundscape_id}")

        session_id = uuid4()
        now = datetime.now(timezone.utc)
        row = {
            "id": str(session_id),
            "user_id": str(user_id),
            "started_at": now.isoformat(),
            "soundscape_used": soundscape_id,
        }
        self.supabase.table("sleep_sessions").insert(row).execute()
        return {"session_id": session_id, "started_at": now, "soundscape_id": soundscape_id}

    async def end_session(self, session_id: UUID, user_id: UUID) -> dict:
        # Fetch session
        result = (
            self.supabase.table("sleep_sessions")
            .select("*")
            .eq("id", str(session_id))
            .single()
            .execute()
        )
        session = result.data
        if not session:
            raise LookupError("Session not found")
        if session["user_id"] != str(user_id):
            raise PermissionError("Not your session")
        if session.get("ended_at"):
            raise ValueError("Session already ended")

        # Fetch biometric events for scoring
        events_result = (
            self.supabase.table("biometric_events")
            .select("*")
            .eq("session_id", str(session_id))
            .order("recorded_at")
            .execute()
        )
        events = events_result.data or []

        # Classify stages from biometrics
        started_at = datetime.fromisoformat(session["started_at"])
        stages: list[SleepStageInterval] = []
        prev_stage: SleepStage | None = None
        for ev in events:
            recorded = datetime.fromisoformat(ev["recorded_at"])
            elapsed_min = (recorded - started_at).total_seconds() / 60
            packet = BiometricPacket(
                recorded_at=recorded,
                heart_rate=ev["hr"],
                hrv=ev["hrv"],
                spo2=ev["spo2"],
                respiratory_rate=ev["respiratory_rate"],
                motion_intensity=ev["motion_intensity"],
            )
            stage = classify(packet, elapsed_min)
            if stage != prev_stage:
                if stages and stages[-1].ended_at is None:
                    stages[-1].ended_at = recorded
                stages.append(SleepStageInterval(stage=stage, started_at=recorded))
                prev_stage = stage

        now = datetime.now(timezone.utc)
        if stages and stages[-1].ended_at is None:
            stages[-1].ended_at = now

        total_minutes = (now - started_at).total_seconds() / 60
        score = compute_sleep_score(total_minutes, stages)

        # Update session
        self.supabase.table("sleep_sessions").update({
            "ended_at": now.isoformat(),
            "sleep_score": score,
        }).eq("id", str(session_id)).execute()

        return {
            "session_id": session_id,
            "sleep_score": score,
            "started_at": started_at,
            "ended_at": now,
            "stages": stages,
        }

    async def get_sessions(self, user_id: UUID, limit: int = 30) -> list[dict]:
        result = (
            self.supabase.table("sleep_sessions")
            .select("*")
            .eq("user_id", str(user_id))
            .order("started_at", desc=True)
            .limit(limit)
            .execute()
        )
        return [
            {
                "id": row["id"],
                "started_at": row["started_at"],
                "ended_at": row.get("ended_at"),
                "sleep_score": row.get("sleep_score"),
                "soundscape_used": row["soundscape_used"],
            }
            for row in (result.data or [])
        ]

    async def get_session(self, session_id: UUID, user_id: UUID) -> dict:
        result = (
            self.supabase.table("sleep_sessions")
            .select("*")
            .eq("id", str(session_id))
            .single()
            .execute()
        )
        session = result.data
        if not session:
            raise LookupError("Session not found")
        if session["user_id"] != str(user_id):
            raise PermissionError("Not your session")
        return {
            "id": session["id"],
            "started_at": session["started_at"],
            "ended_at": session.get("ended_at"),
            "sleep_score": session.get("sleep_score"),
            "soundscape_used": session["soundscape_used"],
        }

    async def ingest_biometric(self, session_id: UUID, packet: BiometricPacket) -> None:
        row = {
            "id": str(uuid4()),
            "session_id": str(session_id),
            "recorded_at": packet.recorded_at.isoformat(),
            "hr": packet.heart_rate,
            "hrv": packet.hrv,
            "spo2": packet.spo2,
            "respiratory_rate": packet.respiratory_rate,
            "motion_intensity": packet.motion_intensity,
        }
        self.supabase.table("biometric_events").insert(row).execute()
