# Sleepie Backend

FastAPI backend for the Sleepie sleep tracking app — AI-driven adaptive music generation with real-time biometric responsiveness.

## Architecture

```
iOS App / Alexa / Web
        |
   FastAPI Backend  (this service)
        |
   +----+----+--------+
   |         |        |
Supabase  HuggingFace  Supabase
Auth+DB   MusicGen     Storage
```

**Hybrid audio model**: Server generates AI music stems via MusicGen, clients play and micro-adjust in real-time based on local biometrics.

## Quick Start

```bash
# 1. Create virtual environment
python3.11 -m venv .venv
source .venv/bin/activate

# 2. Install dependencies
pip install -e ".[dev]"

# 3. Configure environment
cp .env.example .env
# Edit .env with your Supabase and HuggingFace credentials

# 4. Run the server
uvicorn app.main:app --reload --port 8000

# 5. Open Swagger docs
open http://localhost:8000/docs
```

## Docker

```bash
docker compose up --build
```

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `SUPABASE_URL` | Yes | Supabase project URL |
| `SUPABASE_ANON_KEY` | Yes | Supabase anonymous key |
| `SUPABASE_JWT_SECRET` | No | JWT secret for local HS256 fallback |
| `HUGGINGFACE_API_TOKEN` | No | HuggingFace API token for MusicGen |
| `CORS_ORIGINS` | No | Allowed CORS origins (default: `["*"]`) |
| `DEBUG` | No | Enable debug mode (default: `false`) |

## API Endpoints

### Auth (`/api/v1/auth`)
- `POST /signin` — Sign in with email/password
- `POST /signout` — Sign out (requires auth)
- `GET /me` — Get current user profile (requires auth)

### Sessions (`/api/v1/sessions`)
- `POST /start` — Start a sleep session
- `POST /{id}/end` — End a session (computes sleep score)
- `GET /` — List user's sessions
- `GET /{id}` — Get session details
- `WS /{id}/biometrics?token=JWT` — Real-time biometric streaming

### Soundscapes (`/api/v1/soundscapes`)
- `GET /` — List all 8 soundscape presets
- `GET /{id}` — Get soundscape details

### Audio (`/api/v1/audio`)
- `POST /generate` — Generate an AI music stem

### Analytics (`/api/v1/analytics`)
- `GET /summary` — Sleep summary (averages, best/worst)
- `GET /trends?days=30` — Daily scores and rolling averages

### System
- `GET /health` — Health check

## Testing

```bash
pytest -v
```

## Deployment

### Railway (Free Tier)
1. Connect this repo to Railway
2. Set the root directory to `backend/`
3. Add environment variables in Railway dashboard
4. Railway auto-detects the Dockerfile

### AWS (Production)
Swap Railway for ECS, HuggingFace for SageMaker — the code stays the same thanks to the abstraction layer in `audio/musicgen_client.py`.

## Project Structure

```
backend/
├── app/
│   ├── main.py              # FastAPI app factory + lifecycle
│   ├── config.py             # Settings via pydantic-settings
│   ├── dependencies.py       # Shared deps (Supabase, auth)
│   ├── auth/                 # JWT validation, sign in/out
│   ├── sessions/             # Session lifecycle, classifier, scorer, WebSocket
│   ├── soundscapes/          # 8 preset soundscape catalog
│   ├── audio/                # MusicGen AI generation, parameter mapper
│   └── analytics/            # Sleep trends and summaries
├── tests/
├── Dockerfile
├── docker-compose.yml
├── railway.toml
└── pyproject.toml
```
