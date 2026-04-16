from app.sessions.schemas import SleepStage

# Prompt templates per soundscape and stage
_STAGE_MOODS: dict[SleepStage, str] = {
    SleepStage.awake: "calm and relaxing, preparing for sleep, gentle ambient",
    SleepStage.light: "soft and dreamy, drifting into sleep, ethereal and peaceful",
    SleepStage.deep: "very slow and deep, minimal and immersive, ultra-low frequency, deeply calming",
    SleepStage.rem: "gently flowing and surreal, dreamlike atmosphere, floating and weightless",
}

_SOUNDSCAPE_THEMES: dict[str, str] = {
    "rain": "gentle rain on glass, soft rainfall ambience",
    "ocean": "deep ocean waves, distant sea sounds",
    "white_noise": "smooth ambient noise, continuous calming tone",
    "forest": "night forest atmosphere, gentle wind through trees, distant crickets",
    "space": "vast cosmic ambience, deep space tones, stellar drift",
    "arctic": "cold arctic wind, frozen tundra atmosphere, icy resonance",
    "cave": "deep cave resonance, distant water drops, underground echo",
    "desert_night": "warm desert stillness, night sky ambience, subtle warmth",
}


def build_prompt(soundscape_id: str, stage: SleepStage) -> str:
    theme = _SOUNDSCAPE_THEMES.get(soundscape_id, "ambient sleep music")
    mood = _STAGE_MOODS.get(stage, _STAGE_MOODS[SleepStage.light])
    return f"{theme}, {mood}, instrumental, no vocals, sleep music"
