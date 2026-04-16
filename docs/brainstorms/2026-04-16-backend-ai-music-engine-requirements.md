# Sleepie Backend — AI Music Engine & API

**Date:** 2026-04-16
**Status:** Ready for planning
**Scope:** Deep — new backend service with AI music generation

---

## Problem

The Sleepie iOS app currently runs all audio generation on-device using hardcoded AVAudioEngine noise presets (8 soundscapes). It talks directly to Supabase from the client. This limits the app in three ways:

1. **No intelligent music** — The audio is procedural noise, not compositionally interesting adaptive music. The vision is Endel-style AI-generated sleep music that responds to real-time biometrics.
2. **Platform-locked** — Everything runs on iOS. There's no way to serve Alexa, Android, or a web dashboard without reimplementing the entire audio + business logic stack.
3. **No server-side intelligence** — Sleep score computation, analytics aggregation, and future AI features have nowhere to live.

## Solution

Build a FastAPI backend (`backend/` in the monorepo) that serves as the brain of Sleepie:

- **AI music engine** — Server-side model (MusicGen/Riffusion or similar via HuggingFace Inference API) generates adaptive music compositions based on biometric input
- **Hybrid audio architecture** — Server generates base compositions/stems; clients do real-time micro-adjustments (volume, filter, tempo) for low-latency biometric responsiveness
- **Platform-agnostic API** — Any client (iOS, Alexa, web) sends biometrics, receives audio stems + parameters
- **Supabase behind the API** — Clients never talk to Supabase directly; the backend owns all data access

## Architecture

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   iOS App   │  │  Alexa Skill│  │ Web Dashboard│
│  (future)   │  │  (future)   │  │  (future)    │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └────────────────┼────────────────┘
                        │
                   ┌────▼────┐
                   │ FastAPI │  ← Railway/Render (free tier)
                   │ Backend │
                   └────┬────┘
                        │
            ┌───────────┼───────────┐
            │           │           │
      ┌─────▼─────┐ ┌──▼───┐ ┌────▼─────┐
      │ Supabase  │ │ HF   │ │ Redis/   │
      │ Auth + DB │ │ Infer │ │ Queue    │
      │ (free)    │ │ API   │ │ (future) │
      └───────────┘ └──────┘ └──────────┘
```

### Hybrid Audio Flow

```
1. Client starts session → POST /sessions/start {soundscape, biometric_baseline}
2. Server generates initial stems via AI model → returns audio URLs/streams
3. Client plays stems locally, applies real-time micro-adjustments
4. Client streams biometrics → WebSocket /ws/biometrics
5. Server classifies sleep stage, decides if composition needs to change
6. If adaptation needed → Server generates new stems → pushes via WebSocket
7. Client crossfades to new stems while maintaining local micro-adjustments
8. Session ends → POST /sessions/end → server computes sleep score, saves
```

## User Outcomes

1. **Users hear AI-generated adaptive sleep music** instead of static noise presets
2. **Music evolves with their sleep stages** — compositional changes (not just filter tweaks) as they move through light → deep → REM
3. **Works on any platform** — same API serves iOS today, Alexa and web tomorrow
4. **Sleep insights are computed server-side** — scores, trends, recommendations

## Scope

### In Scope (MVP)

- FastAPI project structure in `backend/` with Docker containerization
- Supabase Auth JWT validation middleware
- User profile CRUD (synced from Supabase Auth)
- Sleep session lifecycle API (start, end, get history)
- Biometric event ingestion (REST + WebSocket)
- Sleep stage classification server-side (port existing heuristic)
- AI music generation via HuggingFace Inference API (MusicGen)
- Audio stem serving (generate → store → serve URLs)
- Sleep score computation server-side
- Soundscape catalog API (serve the 8 presets + AI-generated options)
- Swagger/OpenAPI documentation (automatic with FastAPI)
- Basic analytics endpoints (sleep trends, averages)
- Free-tier deployment config (Railway + HuggingFace Inference API)

### Out of Scope (Future Phases)

- Alexa Skill integration
- Web dashboard
- Social features / sharing
- Push notifications
- Custom AI model training (use off-the-shelf HF models for now)
- Payment / subscription system
- Android app
- Real-time collaborative sessions

## Non-Goals

- The backend does NOT replace the client-side audio engine — clients still synthesize/play audio locally
- The backend does NOT do real-time audio streaming (it serves stems/files, not a live PCM stream)
- No custom ML model training in MVP — use existing HuggingFace models

## Success Criteria

1. iOS app can authenticate, start a session, receive AI-generated stems, and play adaptive music through the backend API
2. Backend computes sleep scores that match or improve on the current client-side heuristic
3. API responds fast enough that stem generation doesn't create noticeable gaps (< 5s for initial stems)
4. Swagger docs are complete and usable for future Alexa/web development
5. Deploys on free tier (Railway + HuggingFace) with no cost for development/testing

## Key Decisions Made

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Audio architecture | Hybrid (server stems + client micro-adjust) | Low latency for biometric response, rich compositions from AI, works like Endel |
| AI inference | HuggingFace Inference API | Free tier, no GPU hosting needed, swap for SageMaker later |
| Backend framework | FastAPI | Async, auto Swagger docs, Python ML ecosystem |
| Deployment (now) | Railway/Render free tier | Zero cost for development |
| Deployment (future) | AWS ECS + SageMaker | Production scale with GPU |
| DB / Auth | Supabase (keep existing) | Already set up, free tier, no migration needed |

## Open Questions

1. Which specific HuggingFace model for music generation? (MusicGen-small is a strong default — 300M params, generates 12s clips)
2. Audio format for stems — WAV (quality) vs MP3/AAC (size) vs OPUS (modern, small)?
3. How many stems per adaptation cycle? (1 base + 2-3 layers suggested)
4. Storage for generated audio files — Supabase Storage (free 1GB) vs S3?

## Dependencies

- Supabase project (already exists and configured)
- HuggingFace account + API token (free)
- Railway or Render account (free tier)
- Python 3.11+
