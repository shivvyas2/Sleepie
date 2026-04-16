import pytest

from app.audio.prompt_builder import build_prompt
from app.audio.musicgen_client import _float_array_to_wav
from app.sessions.schemas import SleepStage


def test_prompt_builder_creates_distinct_prompts():
    rain_deep = build_prompt("rain", SleepStage.deep)
    ocean_light = build_prompt("ocean", SleepStage.light)
    assert rain_deep != ocean_light
    assert "rain" in rain_deep
    assert "ocean" in ocean_light
    assert "sleep music" in rain_deep
    assert "sleep music" in ocean_light


def test_prompt_builder_includes_stage_mood():
    deep = build_prompt("rain", SleepStage.deep)
    assert "deep" in deep.lower() or "minimal" in deep.lower()

    light = build_prompt("rain", SleepStage.light)
    assert "dreamy" in light.lower() or "soft" in light.lower()


def test_prompt_builder_unknown_soundscape_fallback():
    prompt = build_prompt("unknown_soundscape", SleepStage.light)
    assert "sleep music" in prompt


def test_float_array_to_wav_produces_valid_wav():
    # Generate a simple sine wave
    import math
    samples = [math.sin(2 * math.pi * 440 * i / 32000) * 0.5 for i in range(32000)]
    wav_bytes = _float_array_to_wav(samples)

    # Check WAV header
    assert wav_bytes[:4] == b"RIFF"
    assert wav_bytes[8:12] == b"WAVE"
    assert wav_bytes[12:16] == b"fmt "
    assert len(wav_bytes) > 44  # Header + some data


def test_float_array_to_wav_empty_input():
    wav_bytes = _float_array_to_wav([])
    assert wav_bytes[:4] == b"RIFF"
    assert wav_bytes[8:12] == b"WAVE"
