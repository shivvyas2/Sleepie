from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException

from app.audio.musicgen_client import RateLimitError, ModelLoadingError
from app.audio.schemas import GenerateRequest, StemResponse
from app.audio.service import AudioService
from app.dependencies import get_current_user, get_supabase_client

router = APIRouter()


def get_audio_service(supabase=Depends(get_supabase_client)) -> AudioService:
    return AudioService(supabase)


@router.post("/generate", response_model=StemResponse)
async def generate_stem(
    body: GenerateRequest,
    user_id: UUID = Depends(get_current_user),
    service: AudioService = Depends(get_audio_service),
):
    try:
        return await service.generate_stem(body.soundscape_id, body.stage)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RateLimitError:
        raise HTTPException(status_code=429, detail="AI generation rate limit — try again shortly")
    except ModelLoadingError:
        raise HTTPException(
            status_code=503,
            detail="AI model is loading — retry in 20-30 seconds",
            headers={"Retry-After": "30"},
        )
