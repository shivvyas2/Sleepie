---
title: "refactor: MVVM Cleanup and Architecture"
type: refactor
status: completed
date: 2026-04-15
---

# refactor: MVVM Cleanup and Architecture

## Overview

The Slipie iOS app has folder structure resembling MVVM but the implementation is hollow. ViewModels are empty shells, 10+ components are buried inside view files, AppEnvironment is a god object, 4 features are orphaned from navigation, and duplicate code is scattered across features. This plan transforms the codebase from "MVVM folders with flat code" into actual MVVM with proper separation of concerns.

## Problem Statement

### What's wrong today

**1. Hollow ViewModels** -- ViewModels exist in folders but don't do anything meaningful:
- `LibraryViewModel` -- 1 property (`selectedFilter`) that doesn't even filter anything
- `OnboardingViewModel` -- has `toggleGoal()` that is never called; the View bypasses it via direct `$binding`
- `HomeViewModel` -- holds `timerMinutes` and `greeting`, but all session logic (`startSession`/`endSession`) is called directly on `AppEnvironment` from the View
- `ActiveSessionViewModel` -- has `currentHR=65` and `currentStage=.awake` hardcoded, never connected to real biometric pipeline

**2. AppEnvironment is a god object** (`App/AppEnvironment.swift`):
Owns audio engine, HealthKit, Supabase client, session state, watch connectivity setup, sleep stage classification, parameter mapping, and network persistence -- all in one 68-line class.

**3. 10+ reusable components buried inline in feature views:**

| Component | Defined in | Used by |
|---|---|---|
| `SoundscapeChip` | `WindDownView.swift:107` | WindDown + Home |
| `TimerPickerSheet` | `WindDownView.swift:130` | WindDown + Home |
| `PageDotsView` | `SplashView.swift:84` | Splash + Onboarding |
| `RecentSoundscapeCard` | `HomeTabView.swift:189` | Home |
| `SleepScoreCard` | `InsightsTabView.swift:67` | Insights |
| `SessionRowView` | `InsightsTabView.swift:100` | Insights |
| `FilterChipView` | `LibraryTabView.swift:112` | Library |
| `LibraryCardView` | `LibraryTabView.swift:139` | Library |
| `SoundscapeCard` | `SoundscapesTabView.swift:28` | Soundscapes |
| `SignInView` | `ProfileTabView.swift:61` | Profile |

**4. Models inline in view files:**
- `GoalItem` in `GoalSelectionView.swift:3`
- `SoundscapeCardData` + `AvatarItem` in `LibraryTabView.swift:3,25`
- `StarParticle` in `StarFieldView.swift:3`
- Global constants `libraryCards`, `libraryAvatars`, `filterChips` as module-level vars

**5. Duplicate code:**
- Soundscape selector appears identically in `HomeTabView.swift:142-164` and `WindDownView.swift:52-73`
- Timer card appears identically in `HomeTabView.swift:166-186` and `WindDownView.swift:75-97`
- Background gradient pattern repeated across 5+ views

**6. Dead and orphaned code:**
- `SleepTabView`, `InsightsTabView`, `SoundscapesTabView`, `ProfileTabView` -- fully built, not in tab bar
- `CreateTabView`, `AlarmTabView`, `AwardsTabView` -- identical AI placeholder stubs in `RootView.swift:27-96`
- `OnboardingViewModel.toggleGoal()` -- never called
- `AppEnvironment.applyBiometrics()` -- never called
- `HealthKitManager` -- instantiated, never used
- `MiniPlayerView.progress` -- hardcoded 0.3, decorative only
- `SleepTabView.swift` -- exists as file, referenced nowhere

**7. Project hygiene:**
- No `.gitignore` (xcuserstate, DerivedData, .build all tracked)
- `Secrets.swift` has hardcoded Supabase credentials committed to git
- No CLAUDE.md
- `Color(hex:)` extension buried in `SlipieColors.swift`
- `SlipieTypography` uses functions `title()` instead of static properties `title`

## Proposed Solution

Six phases, ordered by dependency. Each phase is a standalone PR that leaves the app compiling and functional.

---

### Phase 0: Project Hygiene (do first, blocks nothing)

Add the missing infrastructure that should have existed from day one.

**Tasks:**
- [ ] Add `.gitignore` for Xcode/Swift projects (DerivedData, .build, xcuserstate, .DS_Store)
- [ ] Add `Secrets.swift` to `.gitignore` and create `Secrets.swift.example` with placeholder values
- [ ] Create `scripts/generate-secrets.sh` that generates `Secrets.swift` from env vars or `.env`
- [ ] Create `CLAUDE.md` documenting project conventions:
  - MVVM pattern with Views/ViewModels per feature
  - Design system usage (SlipieColors, SlipieTypography, SlipieSymbols)
  - SlipieCoreKit as the domain logic package
  - Naming conventions
- [ ] Move `Color(hex:)` extension from `SlipieColors.swift` into `Extensions/Color+Hex.swift`
- [ ] Convert `SlipieTypography` from functions to static properties (`title()` -> `title`)
- [ ] Remove `SlipieCoreKit.swift` empty namespace file if not needed

**New files:**
- `.gitignore`
- `Secrets.swift.example`
- `scripts/generate-secrets.sh`
- `CLAUDE.md`
- `Slipie/Extensions/Color+Hex.swift`

---

### Phase 1: Extract Components and Models (independent, low risk)

Pull every inline component and model into its proper file and folder. No logic changes -- just moving code.

**Extract components to `Components/`:**
- [ ] `SoundscapeChip.swift` -- from `WindDownView.swift:107-128`
- [ ] `TimerPickerSheet.swift` -- from `WindDownView.swift:130-165`
- [ ] `PageDotsView.swift` -- from `SplashView.swift:84-97`
- [ ] `RecentSoundscapeCard.swift` -- from `HomeTabView.swift:189-236`
- [ ] `SleepScoreCard.swift` -- from `InsightsTabView.swift:67-104`
- [ ] `SessionRowView.swift` -- from `InsightsTabView.swift:106-128`
- [ ] `FilterChipView.swift` -- from `LibraryTabView.swift:112-137`
- [ ] `LibraryCardView.swift` -- from `LibraryTabView.swift:139-217`
- [ ] `SoundscapeCard.swift` -- from `SoundscapesTabView.swift:28-49`
- [ ] `MoonView.swift` -- from `HeroHeaderView.swift:39-54` (standalone file)
- [ ] `PagodaSilhouette.swift` -- from `HeroHeaderView.swift:56-97` (standalone file)

**Extract to `Features/Profile/Views/SignInView.swift`:**
- [ ] `SignInView` from `ProfileTabView.swift:61-129`

**Extract models to `Models/`:**
- [ ] `GoalItem.swift` -- from `GoalSelectionView.swift:3-8`
- [ ] `SoundscapeCardData.swift` -- from `LibraryTabView.swift:3-10` (include `libraryCards` constant)
- [ ] `AvatarItem.swift` -- from `LibraryTabView.swift:25-29` (include `libraryAvatars` constant)
- [ ] `StarParticle.swift` -- from `StarFieldView.swift:3-9`

**Extract placeholder tabs to their own feature folders:**
- [ ] `Features/Create/Views/CreateTabView.swift` -- from `RootView.swift:27-50`
- [ ] `Features/Alarm/Views/AlarmTabView.swift` -- from `RootView.swift:52-73`
- [ ] `Features/Awards/Views/AwardsTabView.swift` -- from `RootView.swift:75-96`
- [ ] Clean `RootView.swift` to only contain the `TabView` body

**Update pbxproj** for every file add/move.

**Verification:** App compiles, all views render identically to before.

---

### Phase 2: Decompose AppEnvironment into Services

Break the god object into focused, protocol-defined services.

**Define protocols in `Services/`:**

```swift
// Services/AudioServiceProtocol.swift
@MainActor
protocol AudioServiceProtocol: ObservableObject {
    var isPlaying: Bool { get }
    func startSoundscape(_ soundscape: Soundscape) throws
    func stop()
    func apply(parameters: AudioParameters)
    func preview(soundscape: Soundscape) throws
    func stopPreview()
}
```

```swift
// Services/SessionServiceProtocol.swift
@MainActor
protocol SessionServiceProtocol: ObservableObject {
    var currentSession: SleepSession? { get }
    var isSessionActive: Bool { get }
    var selectedSoundscape: Soundscape { get set }
    func startSession()
    func endSession()
}
```

```swift
// Services/AuthServiceProtocol.swift
@MainActor
protocol AuthServiceProtocol: ObservableObject {
    var currentUser: User? { get }
    func signIn(email: String, password: String) async throws
    func signOut() async throws
}
```

**Create concrete implementations:**
- [ ] `Services/AudioService.swift` -- wraps `SleepAudioEngine` + `ParameterMapper`, handles preview vs. session audio conflict
- [ ] `Services/SessionManager.swift` -- owns session lifecycle, persists to Supabase, collects biometric events
- [ ] `Services/AuthService.swift` -- wraps `SlipieSupabaseClient` auth methods

**Refactor `AppEnvironment`:**
- [ ] Reduce to a lightweight dependency container that creates and holds services
- [ ] Keep as `@EnvironmentObject` for SwiftUI injection, but delegate all work to services
- [ ] Remove `setupWatchConnectivity()` body -- move to `SessionManager`
- [ ] Remove `startSession()`/`endSession()` -- delegate to `SessionManager`
- [ ] Remove `applyBiometrics()` -- dead code, delete entirely

**Move `PhoneConnectivityReceiver` integration:**
- [ ] `SessionManager` owns the biometric pipeline: receives packets, classifies stages, adjusts audio, publishes current HR/stage for UI

**Verification:** App compiles, session start/end/audio still works identically via AppEnvironment forwarding to services.

---

### Phase 3: Make ViewModels Real

Inject services into ViewModels. ViewModels become the single point of contact for their Views.

**HomeViewModel:**
- [ ] Inject `SessionServiceProtocol`
- [ ] Move session start/end actions from view into ViewModel methods
- [ ] Move soundscape selection into ViewModel
- [ ] Timer minutes become meaningful (passed to session service)

**ActiveSessionViewModel:**
- [ ] Inject `SessionServiceProtocol` to observe `currentSession.biometricEvents`
- [ ] Subscribe to published `currentHR`, `currentStage` from session manager instead of hardcoding
- [ ] Keep elapsed timer logic (already correct)

**InsightsViewModel:**
- [ ] Inject `SlipieSupabaseClient` at init (not method parameter)
- [ ] Load sessions in `init()` task, not via method call from View

**SignInViewModel:**
- [ ] Inject `AuthServiceProtocol` at init
- [ ] `signIn()` becomes parameterless (uses own email/password properties)

**SoundscapeDetailViewModel:**
- [ ] Inject `AudioServiceProtocol` at init
- [ ] `togglePreview` and `stopPreviewIfNeeded` no longer take `audioEngine` parameter
- [ ] Handle preview/session audio conflict via service protocol

**LibraryViewModel:**
- [ ] Add actual filtering logic (filter `libraryCards` by `selectedFilter`)
- [ ] Or connect to real `Soundscape.all` data instead of hardcoded `SoundscapeCardData`

**OnboardingViewModel:**
- [ ] Delete dead `toggleGoal()` method
- [ ] Keep `selectedGoals` as `@Published` (view uses `$binding` directly, which is fine)

**WindDownView -- create WindDownViewModel:**
- [ ] Extract `timerMinutes`, `showTimerPicker` from `@State` into a ViewModel
- [ ] Inject `SessionServiceProtocol`
- [ ] Remove duplication with Home by using shared `SoundscapeChip` component

**View updates:**
- [ ] Views only reference their ViewModel and environment for navigation
- [ ] No more `env.startSession()`, `env.audioEngine.stop()`, `env.supabaseClient.signIn()` from views

**Verification:** App compiles. Every feature uses ViewModel -> Service -> Engine data flow.

---

### Phase 4: Wire Navigation and Remove Dead Code

**Decide tab bar composition (5 tabs):**
```
Home | Soundscapes | Sleep | Insights | Profile
```

- [ ] Update `RootView.swift` TabView with final 5 tabs
- [ ] Remove placeholder stubs `CreateTabView`, `AlarmTabView`, `AwardsTabView` (and their feature folders)
- [ ] Wire `SoundscapesTabView`, `InsightsTabView`, `ProfileTabView` into tabs
- [ ] Wire `SleepTabView` as the dedicated sleep tab (shows WindDown or ActiveSession)
- [ ] Decide Home vs. Sleep overlap: Home's "Start Session" navigates to Sleep tab, or Home keeps its own start button and Sleep tab is the full experience

**Remove dead code:**
- [ ] Delete `HealthKitManager` instantiation from AppEnvironment (unused on iOS)
- [ ] Delete `SleepTabView` if merged into Sleep tab's Views/ (or keep if it's the tab root)
- [ ] Clean up `MiniPlayerView.progress` -- either wire to real elapsed/duration or remove the fake progress bar
- [ ] Remove old `libraryCards`/`libraryAvatars` globals if Library is connected to real data

**Verification:** All 5 tabs work. No orphaned features. No dead code.

---

### Phase 5: Deduplication and Polish

**Shared soundscape selector:**
- [ ] Create `Components/SoundscapeSelectorView.swift` that takes a `Binding<Soundscape>` and displays chips
- [ ] Replace duplicate implementations in HomeTabView and WindDownView

**Shared timer card:**
- [ ] Create `Components/SleepTimerCard.swift` that takes a `Binding<Int>` for minutes
- [ ] Replace duplicate implementations in HomeTabView and WindDownView

**Shared background gradient:**
- [ ] Create `Components/SlipieBackgroundView.swift` for the radial gradient + background pattern used in 5+ views

**Consistency:**
- [ ] Ensure all models are in `Models/`, all components in `Components/`, all services in `Services/`
- [ ] One type per file for all public types
- [ ] Remove any remaining inline sub-views that are used by more than one parent

**Verification:** No duplicate code. Clean imports. Every file has a clear purpose.

---

## System-Wide Impact

- **Interaction graph:** View -> ViewModel -> Service -> Engine/Network. No more View -> AppEnvironment -> Everything.
- **Error propagation:** Service layer handles errors and exposes state. ViewModels publish error strings. Views display them. No `try?` swallowing errors silently.
- **State lifecycle risks:** SessionManager owns session lifecycle end-to-end. No more partial state where audio is stopped but `isSessionActive` is still true.
- **API surface parity:** AudioService handles both session audio and preview audio, preventing the conflict where previewing kills an active session.
- **pbxproj churn:** Every phase modifies the project file. Consider migrating to Xcode 16 folder-based project format in Phase 0 to eliminate this ongoing cost.

## Acceptance Criteria

- [ ] Every feature folder has `Views/` and `ViewModels/` subfolders with actual content
- [ ] No ViewModel is a "1-property shell" -- each one owns meaningful state or logic
- [ ] AppEnvironment is under 20 lines -- a dependency container, not a god object
- [ ] Zero components defined inline in feature view files
- [ ] Zero models defined inline in view files
- [ ] Zero duplicate UI code blocks
- [ ] All 5 real features reachable from tab bar
- [ ] Zero dead code (no unreachable methods, no unused files)
- [ ] `.gitignore` exists and `Secrets.swift` is not tracked
- [ ] `CLAUDE.md` documents project conventions
- [ ] App compiles and runs after each phase independently

## Dependencies & Risks

**Risk: pbxproj merge conflicts** -- Every phase touches the project file. Mitigate by doing phases sequentially with clean merges, or migrate to Xcode 16 folder-based project first.

**Risk: Behavioral regression** -- Extracting components and rewiring ViewModels can break subtle layout/state behavior. Mitigate by running the app after each extraction and testing the happy path.

**Risk: Service protocol over-engineering** -- The app is early stage. Don't create protocols for things that only have one implementation. Use concrete classes and extract protocols later if testing demands it.

**Dependency: Tab bar decision** -- Phase 4 requires a decision on which 5 tabs to show. This should be decided before starting Phase 3 so ViewModels are created for the right features.

## Sources & References

- Similar patterns: `SlipieCoreKit/` demonstrates clean separation (Models, Audio, Networking, HealthKit, SleepTracking as separate directories)
- Existing design system: `SlipieColors`, `SlipieTypography`, `SlipieSymbols` are well-structured and should be the template for consistency
- Supabase schema: `docs/supabase/` contains the database design
