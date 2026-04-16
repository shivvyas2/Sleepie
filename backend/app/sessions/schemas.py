from datetime import datetime
from enum import Enum
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class SleepStage(str, Enum):
    awake = "awake"
    light = "light"
    deep = "deep"
    rem = "rem"


class BiometricPacket(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    recorded_at: datetime = Field(alias="recordedAt")
    heart_rate: float = Field(alias="heartRate")
    hrv: float = Field(alias="hrv")
    spo2: float = Field(alias="spo2")
    respiratory_rate: float = Field(alias="respiratoryRate")
    motion_intensity: float = Field(alias="motionIntensity")


class SleepStageInterval(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    stage: SleepStage
    started_at: datetime = Field(alias="startedAt")
    ended_at: datetime | None = Field(None, alias="endedAt")


class SessionStartRequest(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    soundscape_id: str = Field(alias="soundscapeId")


class SessionStartResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    session_id: UUID = Field(alias="sessionId")
    started_at: datetime = Field(alias="startedAt")
    soundscape_id: str = Field(alias="soundscapeId")


class SessionEndResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    session_id: UUID = Field(alias="sessionId")
    sleep_score: int = Field(alias="sleepScore")
    started_at: datetime = Field(alias="startedAt")
    ended_at: datetime = Field(alias="endedAt")
    stages: list[SleepStageInterval] = []


class SessionSummary(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: UUID
    started_at: datetime = Field(alias="startedAt")
    ended_at: datetime | None = Field(None, alias="endedAt")
    sleep_score: int | None = Field(None, alias="sleepScore")
    soundscape_used: str = Field(alias="soundscapeUsed")
