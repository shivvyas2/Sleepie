from uuid import uuid4

from supabase import Client

from app.audio.musicgen_client import MusicGenClient
from app.audio.prompt_builder import build_prompt
from app.audio.parameter_mapper import map_parameters
from app.audio.schemas import AudioParameters, StemResponse
from app.sessions.schemas import BiometricPacket, SleepStage
from app.soundscapes.catalog import SOUNDSCAPES_BY_ID
from app.soundscapes.schemas import Soundscape

STEMS_BUCKET = "stems"


class AudioService:
    def __init__(self, supabase: Client):
        self.supabase = supabase
        self.musicgen = MusicGenClient()

    async def generate_stem(
        self,
        soundscape_id: str,
        stage: SleepStage,
    ) -> StemResponse:
        soundscape = SOUNDSCAPES_BY_ID.get(soundscape_id)
        if not soundscape:
            raise ValueError(f"Invalid soundscape_id: {soundscape_id}")

        # Build prompt and generate audio
        prompt = build_prompt(soundscape_id, stage)
        audio_bytes = await self.musicgen.generate(prompt)

        # Upload to Supabase Storage
        stem_id = str(uuid4())
        file_path = f"{stem_id}.wav"

        self.supabase.storage.from_(STEMS_BUCKET).upload(
            file_path, audio_bytes, {"content-type": "audio/wav"}
        )

        # Get signed URL (1 hour expiry)
        url_response = self.supabase.storage.from_(STEMS_BUCKET).create_signed_url(
            file_path, 3600
        )
        stem_url = url_response.get("signedURL", "")

        # Compute default audio parameters for this soundscape+stage
        default_biometrics = BiometricPacket(
            recorded_at="2026-01-01T00:00:00Z",
            heart_rate=60, hrv=40, spo2=97,
            respiratory_rate=14, motion_intensity=0.1,
        )
        params = map_parameters(default_biometrics, stage, soundscape)

        return StemResponse(
            stem_id=stem_id,
            stem_url=stem_url,
            soundscape_id=soundscape_id,
            stage=stage,
            audio_parameters=params,
        )

    def compute_parameters(
        self,
        biometrics: BiometricPacket,
        stage: SleepStage,
        soundscape: Soundscape,
    ) -> AudioParameters:
        return map_parameters(biometrics, stage, soundscape)
