from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException

from app.dependencies import get_current_user, get_supabase_client
from app.sessions.schemas import (
    SessionEndResponse,
    SessionStartRequest,
    SessionStartResponse,
    SessionSummary,
)
from app.sessions.service import SessionService

router = APIRouter()


def get_session_service(supabase=Depends(get_supabase_client)) -> SessionService:
    return SessionService(supabase)


@router.post("/start", response_model=SessionStartResponse)
async def start_session(
    body: SessionStartRequest,
    user_id: UUID = Depends(get_current_user),
    service: SessionService = Depends(get_session_service),
):
    try:
        return await service.start_session(user_id, body.soundscape_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/{session_id}/end", response_model=SessionEndResponse)
async def end_session(
    session_id: UUID,
    user_id: UUID = Depends(get_current_user),
    service: SessionService = Depends(get_session_service),
):
    try:
        return await service.end_session(session_id, user_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Session not found")
    except PermissionError:
        raise HTTPException(status_code=403, detail="Not your session")
    except ValueError as e:
        raise HTTPException(status_code=409, detail=str(e))


@router.get("", response_model=list[SessionSummary])
async def list_sessions(
    limit: int = 30,
    user_id: UUID = Depends(get_current_user),
    service: SessionService = Depends(get_session_service),
):
    return await service.get_sessions(user_id, limit)


@router.get("/{session_id}", response_model=SessionSummary)
async def get_session(
    session_id: UUID,
    user_id: UUID = Depends(get_current_user),
    service: SessionService = Depends(get_session_service),
):
    try:
        return await service.get_session(session_id, user_id)
    except LookupError:
        raise HTTPException(status_code=404, detail="Session not found")
    except PermissionError:
        raise HTTPException(status_code=403, detail="Not your session")
