from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException

from app.auth.schemas import SignInRequest, SignInResponse, UserProfile
from app.auth.service import AuthService
from app.dependencies import get_supabase_client, get_current_user

router = APIRouter()


def get_auth_service(supabase=Depends(get_supabase_client)) -> AuthService:
    return AuthService(supabase)


@router.post("/signin", response_model=SignInResponse)
async def sign_in(body: SignInRequest, service: AuthService = Depends(get_auth_service)):
    try:
        result = await service.sign_in(body.email, body.password)
        return result
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/signout", status_code=204)
async def sign_out(
    user_id: UUID = Depends(get_current_user),
    service: AuthService = Depends(get_auth_service),
):
    await service.sign_out("")
    return None


@router.get("/me", response_model=UserProfile)
async def get_me(
    user_id: UUID = Depends(get_current_user),
    service: AuthService = Depends(get_auth_service),
):
    try:
        return await service.get_user(user_id)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
