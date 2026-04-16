from uuid import uuid4

from supabase import Client

from app.audio.musicgen_client import MusicGenClient, RateLimitError, ModelLoadingError, GenerationError
from app.audio.procedural import generate_stem as generate_procedural_stem
from app.audio.prompt_builder import build_prompt
from app.audio.parameter_mapper import map_parameters
from app.audio.schemas import AudioParameters, StemResponse
from app.config import settings
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

        # Try MusicGen if token is configured, otherwise use procedural
        audio_bytes = await self._generate_audio(soundscape_id, soundscape, stage)

        # Upload to Supabase Storage
        stem_id = str(uuid4())
        file_path = f"{stem_id}.wav"

        self.supabase.storage.from_(STEMS_BUCKET).upload(
            file_path, audio_bytes, {"content-type": "audio/wav"}
        )

        url_response = self.supabase.storage.from_(STEMS_BUCKET).create_signed_url(
            file_path, 3600
        )
        stem_url = url_response.get("signedURL", "")

        # Compute default audio parameters
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

    async def generate_stem_local(
        self,
        soundscape_id: str,
        stage: SleepStage,
    ) -> tuple[bytes, AudioParameters]:
        """Generate a stem locally without uploading. Returns (wav_bytes, params)."""
        soundscape = SOUNDSCAPES_BY_ID.get(soundscape_id)
        if not soundscape:
            raise ValueError(f"Invalid soundscape_id: {soundscape_id}")

        audio_bytes = await self._generate_audio(soundscape_id, soundscape, stage)

        default_biometrics = BiometricPacket(
            recorded_at="2026-01-01T00:00:00Z",
            heart_rate=60, hrv=40, spo2=97,
            respiratory_rate=14, motion_intensity=0.1,
        )
        params = map_parameters(default_biometrics, stage, soundscape)
        return audio_bytes, params

    async def _generate_audio(
        self,
        soundscape_id: str,
        soundscape: Soundscape,
        stage: SleepStage,
    ) -> bytes:
        """Generate audio — tries MusicGen first, falls back to procedural."""
        if settings.huggingface_api_token and settings.huggingface_api_token != "hf_test_token":
            try:
                prompt = build_prompt(soundscape_id, stage)
                return await self.musicgen.generate(prompt)
            except (RateLimitError, ModelLoadingError, GenerationError, Exception):
                pass  # Fall through to procedural

        # Procedural generation (always available, no API needed)
        return generate_procedural_stem(
            noise_color=soundscape.base_parameters.noise_color,
            base_frequency=soundscape.base_parameters.base_frequency,
            reverb_preset=soundscape.base_parameters.reverb_preset,
            oscillator_mix=soundscape.base_parameters.oscillator_mix,
            stage=stage,
        )

    def compute_parameters(
        self,
        biometrics: BiometricPacket,
        stage: SleepStage,
        soundscape: Soundscape,
    ) -> AudioParameters:
        return map_parameters(biometrics, stage, soundscape)
