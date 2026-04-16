from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import Response

from app.audio.musicgen_client import RateLimitError, ModelLoadingError
from app.audio.schemas import GenerateRequest, StemResponse
from app.audio.service import AudioService
from app.dependencies import get_current_user, get_supabase_client
from app.sessions.schemas import SleepStage

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


@router.get("/preview/{soundscape_id}")
async def preview_audio(
    soundscape_id: str,
    stage: SleepStage = SleepStage.light,
):
    """Preview a generated audio stem — no auth required, returns WAV directly."""
    service = AudioService(supabase=None)
    try:
        audio_bytes, _params = await service.generate_stem_local(soundscape_id, stage)
        return Response(
            content=audio_bytes,
            media_type="audio/wav",
            headers={"Content-Disposition": f"inline; filename={soundscape_id}_{stage.value}.wav"},
        )
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
