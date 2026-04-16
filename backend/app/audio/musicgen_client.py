import io
import struct

import httpx
import numpy as np

from app.config import settings

MUSICGEN_MODEL = "facebook/musicgen-small"
SAMPLE_RATE = 32000


class MusicGenClient:
    def __init__(self):
        self.api_url = f"https://api-inference.huggingface.co/models/{MUSICGEN_MODEL}"

    async def generate(self, prompt: str) -> bytes:
        """Call HuggingFace Inference API and return WAV bytes."""
        headers = {}
        if settings.huggingface_api_token:
            headers["Authorization"] = f"Bearer {settings.huggingface_api_token}"

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                self.api_url,
                json={"inputs": prompt},
                headers=headers,
            )

            if response.status_code == 429:
                raise RateLimitError("HuggingFace rate limit exceeded")
            if response.status_code == 503:
                raise ModelLoadingError("Model is loading, try again shortly")

            response.raise_for_status()

            # Response is raw audio bytes (FLAC or WAV depending on model)
            content_type = response.headers.get("content-type", "")

            if "audio" in content_type:
                # Direct audio bytes returned
                return response.content

            # JSON response with audio array
            data = response.json()
            if isinstance(data, list) and len(data) > 0:
                audio_data = data[0].get("generated_audio", data[0].get("blob", []))
                if audio_data:
                    return _float_array_to_wav(audio_data)

            raise GenerationError("Unexpected response format from MusicGen")


class RateLimitError(Exception):
    pass


class ModelLoadingError(Exception):
    pass


class GenerationError(Exception):
    pass


def _float_array_to_wav(audio: list[float]) -> bytes:
    """Convert float32 audio array to WAV bytes at 32kHz."""
    samples = np.array(audio, dtype=np.float32)
    # Normalize to int16 range
    samples = np.clip(samples, -1.0, 1.0)
    int_samples = (samples * 32767).astype(np.int16)

    buf = io.BytesIO()
    # Write WAV header
    num_samples = len(int_samples)
    data_size = num_samples * 2  # 16-bit = 2 bytes per sample
    buf.write(b"RIFF")
    buf.write(struct.pack("<I", 36 + data_size))
    buf.write(b"WAVE")
    buf.write(b"fmt ")
    buf.write(struct.pack("<I", 16))  # chunk size
    buf.write(struct.pack("<H", 1))  # PCM format
    buf.write(struct.pack("<H", 1))  # mono
    buf.write(struct.pack("<I", SAMPLE_RATE))
    buf.write(struct.pack("<I", SAMPLE_RATE * 2))  # byte rate
    buf.write(struct.pack("<H", 2))  # block align
    buf.write(struct.pack("<H", 16))  # bits per sample
    buf.write(b"data")
    buf.write(struct.pack("<I", data_size))
    buf.write(int_samples.tobytes())

    return buf.getvalue()
