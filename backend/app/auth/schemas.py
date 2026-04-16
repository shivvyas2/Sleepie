from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class SignInRequest(BaseModel):
    email: str
    password: str


class SignInResponse(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    access_token: str = Field(alias="accessToken")
    refresh_token: str = Field(alias="refreshToken")
    user: "UserProfile"


class UserProfile(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    id: UUID
    email: str | None = None
    created_at: str | None = Field(None, alias="createdAt")
