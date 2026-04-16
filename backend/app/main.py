from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.auth.routes import router as auth_router
from app.sessions.routes import router as sessions_router
from app.soundscapes.routes import router as soundscapes_router
from app.audio.routes import router as audio_router
from app.analytics.routes import router as analytics_router


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_name,
        version="0.1.0",
        description="AI-driven adaptive sleep music backend",
        docs_url="/docs",
        redoc_url="/redoc",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(auth_router, prefix="/api/v1/auth", tags=["Auth"])
    app.include_router(sessions_router, prefix="/api/v1/sessions", tags=["Sessions"])
    app.include_router(soundscapes_router, prefix="/api/v1/soundscapes", tags=["Soundscapes"])
    app.include_router(audio_router, prefix="/api/v1/audio", tags=["Audio"])
    app.include_router(analytics_router, prefix="/api/v1/analytics", tags=["Analytics"])

    @app.get("/health", tags=["System"])
    async def health_check():
        return {"status": "healthy"}

    return app


app = create_app()
