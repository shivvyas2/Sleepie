"""
Local procedural audio generator for sleep music stems.

Generates layered ambient audio using noise synthesis + filtering,
matching the soundscape characteristics. No external API required.

This is the default generator. Swap for MusicGen/SageMaker when
a paid inference endpoint is available.
"""
import io
import struct
import math

import numpy as np
from scipy import signal as sp_signal

from app.sessions.schemas import SleepStage
from app.soundscapes.schemas import NoiseColor

SAMPLE_RATE = 32000
DURATION_SECONDS = 15  # Each stem is 15 seconds


def generate_stem(
    noise_color: NoiseColor,
    base_frequency: float,
    reverb_preset: int,
    oscillator_mix: float,
    stage: SleepStage,
) -> bytes:
    """Generate a WAV audio stem based on soundscape parameters and sleep stage."""
    num_samples = SAMPLE_RATE * DURATION_SECONDS

    # Generate base noise
    noise = _generate_noise(noise_color, num_samples)

    # Generate tonal oscillator at base frequency
    t = np.linspace(0, DURATION_SECONDS, num_samples, endpoint=False)
    oscillator = np.sin(2 * np.pi * base_frequency * t)

    # Add harmonics for richness
    oscillator += 0.3 * np.sin(2 * np.pi * base_frequency * 1.5 * t)
    oscillator += 0.15 * np.sin(2 * np.pi * base_frequency * 2.0 * t)

    # Mix noise and oscillator
    mixed = noise * (1 - oscillator_mix) + oscillator * oscillator_mix

    # Apply stage-based filtering
    mixed = _apply_stage_filter(mixed, stage, base_frequency)

    # Apply reverb-like effect (convolution with exponential decay)
    mixed = _apply_reverb(mixed, reverb_preset)

    # Fade in/out to avoid clicks
    fade_samples = SAMPLE_RATE  # 1 second fade
    fade_in = np.linspace(0, 1, fade_samples)
    fade_out = np.linspace(1, 0, fade_samples)
    mixed[:fade_samples] *= fade_in
    mixed[-fade_samples:] *= fade_out

    # Normalize
    peak = np.max(np.abs(mixed))
    if peak > 0:
        mixed = mixed / peak * 0.7

    return _to_wav(mixed)


def _generate_noise(color: NoiseColor, num_samples: int) -> np.ndarray:
    """Generate colored noise."""
    white = np.random.randn(num_samples).astype(np.float32)

    if color == NoiseColor.white:
        return white * 0.15

    if color == NoiseColor.pink:
        # Pink noise: 1/f spectrum via filtering
        b = np.array([0.049922035, -0.095993537, 0.050612699, -0.004709510])
        a = np.array([1.0, -2.494956002, 2.017265875, -0.522189400])
        pink = sp_signal.lfilter(b, a, white)
        return pink * 0.3

    if color == NoiseColor.brown:
        # Brown noise: integrated white noise
        brown = np.cumsum(white)
        brown = brown - np.mean(brown)
        peak = np.max(np.abs(brown))
        if peak > 0:
            brown = brown / peak
        return brown * 0.3

    return white * 0.15


def _apply_stage_filter(audio: np.ndarray, stage: SleepStage, base_freq: float) -> np.ndarray:
    """Apply low-pass filter based on sleep stage. Deeper sleep = more filtering."""
    cutoff_map = {
        SleepStage.awake: 8000,
        SleepStage.light: 4000,
        SleepStage.deep: 1500,
        SleepStage.rem: 3000,
    }
    cutoff = cutoff_map.get(stage, 4000)
    nyquist = SAMPLE_RATE / 2
    normalized = min(cutoff / nyquist, 0.99)
    b, a = sp_signal.butter(4, normalized, btype="low")
    return sp_signal.lfilter(b, a, audio).astype(np.float32)


def _apply_reverb(audio: np.ndarray, reverb_preset: int) -> np.ndarray:
    """Simple reverb effect using exponential decay impulse response."""
    decay_time = 0.1 + reverb_preset * 0.15  # 0.1s to 1.45s
    decay_samples = int(SAMPLE_RATE * decay_time)

    if decay_samples < 10:
        return audio

    impulse = np.exp(-np.linspace(0, 5, decay_samples))
    impulse = impulse / np.sum(impulse)

    wet = np.convolve(audio, impulse, mode="same")
    wetness = reverb_preset / 10.0  # 0.0 to 1.0
    return (audio * (1 - wetness) + wet * wetness).astype(np.float32)


def _to_wav(samples: np.ndarray) -> bytes:
    """Convert float32 audio to WAV bytes."""
    samples = np.clip(samples, -1.0, 1.0)
    int_samples = (samples * 32767).astype(np.int16)

    buf = io.BytesIO()
    data_size = len(int_samples) * 2

    buf.write(b"RIFF")
    buf.write(struct.pack("<I", 36 + data_size))
    buf.write(b"WAVE")
    buf.write(b"fmt ")
    buf.write(struct.pack("<I", 16))
    buf.write(struct.pack("<H", 1))  # PCM
    buf.write(struct.pack("<H", 1))  # mono
    buf.write(struct.pack("<I", SAMPLE_RATE))
    buf.write(struct.pack("<I", SAMPLE_RATE * 2))
    buf.write(struct.pack("<H", 2))
    buf.write(struct.pack("<H", 16))
    buf.write(b"data")
    buf.write(struct.pack("<I", data_size))
    buf.write(int_samples.tobytes())

    return buf.getvalue()
