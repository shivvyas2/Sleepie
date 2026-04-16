from fastapi import APIRouter, HTTPException

from app.soundscapes.catalog import SOUNDSCAPES, SOUNDSCAPES_BY_ID
from app.soundscapes.schemas import Soundscape

router = APIRouter()


@router.get("", response_model=list[Soundscape])
async def list_soundscapes():
    return SOUNDSCAPES


@router.get("/{soundscape_id}", response_model=Soundscape)
async def get_soundscape(soundscape_id: str):
    soundscape = SOUNDSCAPES_BY_ID.get(soundscape_id)
    if not soundscape:
        raise HTTPException(status_code=404, detail=f"Soundscape '{soundscape_id}' not found")
    return soundscape
