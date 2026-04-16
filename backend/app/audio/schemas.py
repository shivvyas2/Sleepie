from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.sessions.schemas import SleepStage


class AudioParameters(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    volume: float
    tempo: float
    filter_cutoff_normalized: float = Field(alias="filterCutoffNormalized")
    reverb_wetness: float = Field(alias="reverbWetness")
    oscillator_mix: float = Field(alias="oscillatorMix")
    pitch_shift: float = Field(alias="pitchShift")


class GenerateRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    soundscape_id: str = Field(alias="soundscapeId")
    stage: SleepStage = SleepStage.light


class StemResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    stem_id: str = Field(alias="stemId")
    stem_url: str = Field(alias="stemUrl")
    soundscape_id: str = Field(alias="soundscapeId")
    stage: SleepStage
    audio_parameters: AudioParameters = Field(alias="audioParameters")
