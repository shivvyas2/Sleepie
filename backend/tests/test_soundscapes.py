import pytest


@pytest.mark.asyncio
async def test_list_soundscapes_returns_all_8(client):
    response = await client.get("/api/v1/soundscapes")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 8
    ids = [s["id"] for s in data]
    assert "rain" in ids
    assert "ocean" in ids
    assert "desert_night" in ids


@pytest.mark.asyncio
async def test_get_rain_soundscape_matches_swift(client):
    response = await client.get("/api/v1/soundscapes/rain")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "rain"
    assert data["name"] == "Rain"
    assert data["description"] == "Gentle rainfall on glass"
    # FastAPI serializes with aliases (camelCase) for iOS compatibility
    params = data["baseParameters"]
    assert params["noiseColor"] == "pink"
    assert params["baseFrequency"] == 80.0
    assert params["reverbPreset"] == 4
    assert params["oscillatorMix"] == 0.3


@pytest.mark.asyncio
async def test_get_nonexistent_soundscape_returns_404(client):
    response = await client.get("/api/v1/soundscapes/nonexistent")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_all_soundscapes_have_valid_parameters(client):
    response = await client.get("/api/v1/soundscapes")
    data = response.json()
    for s in data:
        params = s["baseParameters"]
        assert params["noiseColor"] in ("pink", "brown", "white")
        assert params["baseFrequency"] > 0
        assert 0 <= params["oscillatorMix"] <= 1.0
        assert params["reverbPreset"] >= 0
