"""
Test audio generation — works without any API keys.

Usage:
    cd backend/
    source .venv/bin/activate
    python scripts/test_musicgen.py
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault("SUPABASE_URL", "http://localhost:54321")
os.environ.setdefault("SUPABASE_ANON_KEY", "test")

from app.audio.procedural import generate_stem
from app.sessions.schemas import SleepStage
from app.soundscapes.catalog import SOUNDSCAPES
from app.soundscapes.schemas import NoiseColor

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def main():
    print("Generating audio stems for all soundscapes...\n")

    for soundscape in SOUNDSCAPES:
        for stage in [SleepStage.light, SleepStage.deep]:
            filename = f"{soundscape.id}_{stage.value}.wav"
            filepath = os.path.join(OUTPUT_DIR, filename)

            audio = generate_stem(
                noise_color=soundscape.base_parameters.noise_color,
                base_frequency=soundscape.base_parameters.base_frequency,
                reverb_preset=soundscape.base_parameters.reverb_preset,
                oscillator_mix=soundscape.base_parameters.oscillator_mix,
                stage=stage,
            )

            with open(filepath, "wb") as f:
                f.write(audio)

            size_kb = len(audio) / 1024
            print(f"  {filename:35s} {size_kb:6.0f} KB")

    print(f"\nAll stems saved to {OUTPUT_DIR}/")
    print(f"\nPlay one:  open {os.path.join(OUTPUT_DIR, 'rain_deep.wav')}")
    print("Or start the server and visit: http://localhost:8000/api/v1/audio/preview/rain?stage=deep")


if __name__ == "__main__":
    main()
