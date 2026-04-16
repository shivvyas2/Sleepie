import pytest
from jose import jwt
from unittest.mock import patch, MagicMock


TEST_JWT_SECRET = "test-jwt-secret"
TEST_USER_ID = "a1b2c3d4-e5f6-7890-abcd-ef1234567890"


def make_test_token(user_id: str = TEST_USER_ID, expired: bool = False) -> str:
    import time

    payload = {
        "sub": user_id,
        "email": "test@example.com",
        "exp": (time.time() - 3600) if expired else (time.time() + 3600),
        "iat": time.time(),
    }
    return jwt.encode(payload, TEST_JWT_SECRET, algorithm="HS256")


@pytest.mark.asyncio
async def test_me_without_auth_returns_401(client):
    response = await client.get("/api/v1/auth/me")
    assert response.status_code in (401, 403)  # Missing auth header


@pytest.mark.asyncio
async def test_me_with_malformed_token_returns_401(client):
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": "Bearer not-a-valid-jwt"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_me_with_expired_token_returns_401(client):
    token = make_test_token(expired=True)
    response = await client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_me_with_valid_token_returns_user(client):
    token = make_test_token()

    mock_user = MagicMock()
    mock_user.id = TEST_USER_ID
    mock_user.email = "test@example.com"
    mock_user.created_at = "2026-01-01T00:00:00"

    mock_response = MagicMock()
    mock_response.user = mock_user

    with patch("app.auth.service.AuthService.get_user") as mock_get:
        mock_get.return_value = {
            "id": TEST_USER_ID,
            "email": "test@example.com",
            "created_at": "2026-01-01T00:00:00",
        }
        response = await client.get(
            "/api/v1/auth/me",
            headers={"Authorization": f"Bearer {token}"},
        )
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == TEST_USER_ID
    assert data["email"] == "test@example.com"


@pytest.mark.asyncio
async def test_signin_with_invalid_credentials_returns_400(client):
    with patch("app.auth.service.AuthService.sign_in") as mock_sign_in:
        mock_sign_in.side_effect = Exception("Invalid login credentials")
        response = await client.post(
            "/api/v1/auth/signin",
            json={"email": "wrong@test.com", "password": "wrong"},
        )
    assert response.status_code == 400
