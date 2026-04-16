from uuid import UUID

from supabase import Client


class AuthService:
    def __init__(self, supabase: Client):
        self.supabase = supabase

    async def sign_in(self, email: str, password: str) -> dict:
        response = self.supabase.auth.sign_in_with_password(
            {"email": email, "password": password}
        )
        return {
            "access_token": response.session.access_token,
            "refresh_token": response.session.refresh_token,
            "user": {
                "id": response.user.id,
                "email": response.user.email,
                "created_at": str(response.user.created_at) if response.user.created_at else None,
            },
        }

    async def sign_out(self, access_token: str) -> None:
        self.supabase.auth.sign_out()

    async def get_user(self, user_id: UUID) -> dict:
        response = self.supabase.auth.get_user()
        user = response.user
        return {
            "id": user.id,
            "email": user.email,
            "created_at": str(user.created_at) if user.created_at else None,
        }
