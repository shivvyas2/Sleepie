import time

import httpx
from jose import jwt, JWTError, jwk

from app.config import settings


class SupabaseJWTValidator:
    def __init__(self):
        self._jwks_cache: dict | None = None
        self._cache_time: float = 0
        self._cache_ttl: float = 600  # 10 minutes

    @property
    def jwks_url(self) -> str:
        return f"{settings.supabase_url}/auth/v1/.well-known/jwks.json"

    async def _fetch_jwks(self) -> dict:
        now = time.time()
        if self._jwks_cache and (now - self._cache_time) < self._cache_ttl:
            return self._jwks_cache

        async with httpx.AsyncClient() as client:
            response = await client.get(self.jwks_url, timeout=10.0)
            response.raise_for_status()
            self._jwks_cache = response.json()
            self._cache_time = now
            return self._jwks_cache

    async def verify(self, token: str) -> dict:
        """Verify a Supabase JWT and return its claims.

        Tries JWKS (RS256) first, falls back to HS256 with JWT secret for local dev.
        """
        # Try JWKS first
        try:
            jwks_data = await self._fetch_jwks()
            keys = jwks_data.get("keys", [])
            if keys:
                header = jwt.get_unverified_header(token)
                kid = header.get("kid")
                key_data = next((k for k in keys if k.get("kid") == kid), keys[0])
                public_key = jwk.construct(key_data)
                claims = jwt.decode(
                    token,
                    public_key,
                    algorithms=["RS256"],
                    options={"verify_aud": False},
                )
                return claims
        except (httpx.HTTPError, JWTError, StopIteration):
            pass

        # Fallback to HS256 with JWT secret
        if settings.supabase_jwt_secret:
            claims = jwt.decode(
                token,
                settings.supabase_jwt_secret,
                algorithms=["HS256"],
                options={"verify_aud": False},
            )
            return claims

        raise JWTError("Unable to validate token")


jwt_validator = SupabaseJWTValidator()
