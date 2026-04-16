from app.soundscapes.schemas import NoiseColor, Soundscape, SoundscapeParameters

SOUNDSCAPES: list[Soundscape] = [
    Soundscape(
        id="rain", name="Rain", description="Gentle rainfall on glass",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.pink, base_frequency=80, reverb_preset=4, oscillator_mix=0.3,
        ),
    ),
    Soundscape(
        id="ocean", name="Ocean", description="Deep ocean waves",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.brown, base_frequency=60, reverb_preset=6, oscillator_mix=0.4,
        ),
    ),
    Soundscape(
        id="white_noise", name="White Noise", description="Pure white noise for focus and sleep",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.white, base_frequency=100, reverb_preset=2, oscillator_mix=0.1,
        ),
    ),
    Soundscape(
        id="forest", name="Forest", description="Night forest with gentle wind",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.pink, base_frequency=110, reverb_preset=5, oscillator_mix=0.5,
        ),
    ),
    Soundscape(
        id="space", name="Space", description="Vast cosmic ambience",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.brown, base_frequency=40, reverb_preset=8, oscillator_mix=0.7,
        ),
    ),
    Soundscape(
        id="arctic", name="Arctic Wind", description="Cold wind across frozen tundra",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.white, base_frequency=90, reverb_preset=7, oscillator_mix=0.2,
        ),
    ),
    Soundscape(
        id="cave", name="Cave", description="Deep cave resonance and dripping water",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.brown, base_frequency=55, reverb_preset=9, oscillator_mix=0.6,
        ),
    ),
    Soundscape(
        id="desert_night", name="Desert Night", description="Warm desert stillness under stars",
        base_parameters=SoundscapeParameters(
            noise_color=NoiseColor.pink, base_frequency=70, reverb_preset=3, oscillator_mix=0.35,
        ),
    ),
]

SOUNDSCAPES_BY_ID: dict[str, Soundscape] = {s.id: s for s in SOUNDSCAPES}
