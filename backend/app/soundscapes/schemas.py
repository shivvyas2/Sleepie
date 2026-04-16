from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class NoiseColor(str, Enum):
    pink = "pink"
    brown = "brown"
    white = "white"


class SoundscapeParameters(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    noise_color: NoiseColor = Field(alias="noiseColor")
    base_frequency: float = Field(alias="baseFrequency")
    reverb_preset: int = Field(alias="reverbPreset")
    oscillator_mix: float = Field(alias="oscillatorMix")


class Soundscape(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: str
    name: str
    description: str
    base_parameters: SoundscapeParameters = Field(alias="baseParameters")
