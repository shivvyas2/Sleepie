# Slipie — Sleep Music App Design

**Date:** 2026-04-07
**Status:** Approved

---

## Overview

Slipie is an iOS/iPadOS/watchOS app that generates real-time, procedurally synthesized sleep-inducing music — similar to Endel — driven by live biometric data from Apple Watch. The music adapts continuously to the user's heart rate, HRV, SpO2, respiratory rate, motion, and inferred sleep stage throughout the night.

---

## Platform Targets

- iPhone (primary)
- iPad (companion, split-view adapted layouts)
- Apple Watch (biometric collection, live session control, complications)

---

## Architecture

**Approach: Native Triplatform + Supabase**

A shared Swift Package (`SlipieCoreKit`) contains the audio engine, sleep models, HealthKit helpers, and networking. Each platform target is a separate but tightly integrated Swift/SwiftUI app. The Watch collects biometrics and streams them to iPhone via WatchConnectivity. The iPhone drives the AVAudioEngine generative music pipeline in real time.

```
Apple Watch
  HealthKit (HR, HRV, SpO2, RespiratoryRate, Motion)
  HKWorkoutSession (keeps Watch alive overnight)
  WCSession.sendMessageData() every 30s
        |
iPhone / iPad
  WatchConnectivity receiver
  CoreML SleepStageClassifier (awake | light | deep | rem)
  Parameter Mapper (biometrics -> audio parameters)
  AVAudioEngine Signal Chain
        |
Supabase Backend
  Auth (Sign in with Apple + email)
  Postgres (sleep sessions, stages, biometric events)
  Edge Functions (future: subscription webhooks)
```

---

## App Structure

### Tab Bar (iPhone/iPad)

| Tab | SF Symbol | Description |
|-----|-----------|-------------|
| Sleep | `moon.stars.fill` | Wind-down and active session screen |
| Insights | `chart.xyaxis.line` | Sleep history, stage breakdown, trends |
| Soundscapes | `waveform` | Browse and select generative sound environments |
| Profile | `person.crop.circle` | Account, settings, Apple Watch pairing |

### Key Flows

**Wind-down Flow**
Select soundscape -> optional sleep timer -> music begins (biometric-adaptive) -> screen dims -> Watch takes over live biometric streaming.

**All-night Adaptive Mode**
Watch streams biometric packet every 30s -> iPhone infers sleep stage via CoreML -> audio parameters adjust in real time -> morning gentle crescendo -> session saved to Supabase.

**Insights**
Sleep score (0-100), stage timeline chart, HR overlay, weekly/monthly trends, streak tracking.

### Apple Watch App
- Glanceable complication showing sleep score and current HR
- Wind-down trigger button (mirrors iPhone)
- Live session view: current HR + inferred sleep stage

---

## Design Language

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#050A18` | Deep midnight black-blue |
| Surface | `#0D1A3A` | Dark navy |
| Surface Raised | `#112247` | Cards, modals |
| Accent Start | `#1E3A8A` | Gradient start (deep indigo) |
| Accent End | `#3B82F6` | Gradient end (electric blue) |
| Accent Glow | `#6366F1` | Live biometric indicators |
| Text Primary | `#F0F4FF` | Primary labels |
| Text Secondary | `#8899BB` | Secondary labels |
| Danger | `#EF4444` | Alerts |
| Success | `#22C55E` | Sleep quality good |

### Typography
- SF Pro Rounded throughout (approachable, soft for sleep context)

### Visual Motifs
- Soft radial gradients emanating from center (moon/star glow)
- Frosted glass cards using `.ultraThinMaterial`
- Subtle animated star-particle background on sleep screen
- Biometric data as soft glowing waveforms, not harsh charts
- Spring animations throughout, no jarring transitions

### Icons
- SF Symbols exclusively for system icons
- Figma file assets for brand-specific icons and illustrations
- Source Figma: https://www.figma.com/design/BUaqRLmpMuQnn5dh1KGm1G/Slipie
- No emojis anywhere — not in UI, code, comments, logs, or documentation

### Components
- Buttons: pill-shaped with indigo gradient fill or ghost outline variant
- Cards: 16pt corner radius, frosted glass on dark navy base
- No third-party icon packs

---

## Generative Audio Engine

### Signal Chain (AVAudioEngine)

```
Oscillators (sine + triangle) + Noise generator (pink/brown)
+ Sample player (ambient texture stems)
        |
Low-pass filter (cutoff frequency shifts with sleep stage depth)
        |
AVAudioUnitReverb (room size grows as user enters deeper sleep)
        |
Delay + Chorus (subtle shimmer layer)
        |
Master limiter + volume envelope
        |
Audio output (Speaker / Bluetooth / AirPlay)
```

### Biometric -> Audio Parameter Mapping

| Biometric State | Audio Response |
|-----------------|---------------|
| HR high (anxious) | Slower pulse, lower frequency, heavier reverb |
| HR low (calm) | Gentle pads, higher harmonics, open spatial feel |
| HRV high (relaxed) | Complex layering, richer texture |
| HRV low (stressed) | Simpler drone, minimal stimulation |
| Light sleep stage | Soft melodic movement, gentle rhythm |
| Deep sleep stage | Near-silence, sub-bass drones, 0.5Hz pulse |
| REM stage | Surreal pads, dreamlike complexity |
| Waking (morning) | Slow harmonic rise, gentle crescendo |

### Soundscapes
Each soundscape is a preset defining base waveforms, noise color, reverb impulse response, and parameter mapping curves. All soundscapes available (subscription gating deferred to later release).

---

## Apple Watch Integration

### HealthKit Permissions

**Read:** HeartRate, HeartRateVariabilitySDNN, OxygenSaturation, RespiratoryRate, SleepAnalysis, StepCount

**Write:** SleepAnalysis (write back inferred stages)

### Background Modes
- `audio` — keeps AVAudioEngine alive overnight
- `background-fetch`
- `watchkit-complication`

### CoreML Sleep Stage Classifier

| Field | Value |
|-------|-------|
| Input features | hr, hrv, spo2, motion_intensity, time_since_sleep_onset, time_of_night |
| Output classes | awake, light, deep, rem |
| Output type | Softmax probabilities |
| Model format | .mlmodel bundled in app |
| Training source | MESA / SHHS public sleep datasets |

---

## Backend (Supabase)

### Schema

```sql
users
  id uuid primary key
  email text
  created_at timestamptz
  -- subscription_tier deferred

sleep_sessions
  id uuid primary key
  user_id uuid references users
  started_at timestamptz
  ended_at timestamptz
  duration_minutes int
  avg_hr float
  avg_hrv float
  avg_spo2 float
  sleep_score int  -- 0-100
  soundscape_used text

sleep_stages
  id uuid primary key
  session_id uuid references sleep_sessions
  stage text  -- awake | light | deep | rem
  started_at timestamptz
  ended_at timestamptz
  duration_seconds int

biometric_events
  id uuid primary key
  session_id uuid references sleep_sessions
  recorded_at timestamptz
  hr float
  hrv float
  spo2 float
  respiratory_rate float
  motion_intensity float

soundscapes
  id uuid primary key
  name text
  description text
  base_parameters jsonb
```

### Auth
- Sign in with Apple (primary)
- Email + password (fallback)
- Supabase Auth with JWT + refresh tokens

### Offline Strategy
- Biometric events written to CoreData during active session
- Batch upload to Supabase when session ends
- Full offline support — syncs when online

### Subscription (Deferred)
RevenueCat integration and freemium gating are excluded from v1. All soundscapes are available to all users. Subscription infrastructure to be added in a future release.

---

## Project Structure

```
Slipie/
├── SlipieCoreKit/                   (Swift Package — shared logic)
│   ├── Sources/
│   │   ├── AudioEngine/
│   │   │   ├── SleepAudioEngine.swift
│   │   │   ├── ParameterMapper.swift
│   │   │   ├── SignalChain.swift
│   │   │   └── Soundscape.swift
│   │   ├── SleepTracking/
│   │   │   ├── SleepStageClassifier.swift
│   │   │   ├── BiometricPacket.swift
│   │   │   └── SleepSession.swift
│   │   ├── HealthKit/
│   │   │   └── HealthKitManager.swift
│   │   └── Networking/
│   │       └── SupabaseClient.swift
│
├── Slipie iOS/                      (iPhone + iPad target)
│   ├── App/
│   ├── Features/
│   │   ├── Sleep/
│   │   ├── Insights/
│   │   ├── Soundscapes/
│   │   └── Profile/
│   ├── Components/
│   └── Resources/
│
├── Slipie watchOS/                  (Apple Watch target)
│   ├── App/
│   ├── Session/
│   ├── Connectivity/
│   └── Complications/
│
└── Slipie iPadOS/                   (iPad-specific layouts)
    └── Features/
```

### Swift Package Manager Dependencies
- `supabase-swift` — Supabase iOS SDK
- `swift-numerics` — DSP math helpers

---

## Key Constraints

- No emojis anywhere: UI, code, comments, logs, documentation
- SF Symbols + Figma file assets only for icons
- RevenueCat and subscription code excluded from v1
- All audio generation on-device (zero-latency biometric response)
- Offline-first: local CoreData cache, Supabase sync on session end
