# Slipie iOS App

Sleep tracking app with adaptive soundscapes, Apple Watch biometrics, and Supabase backend.

## Architecture

**MVVM** with feature-based folders. Each feature has `Views/` and `ViewModels/` subfolders.

```
Slipie/
  App/            App entry point, dependency container (AppEnvironment)
  Models/         Shared data models
  Services/       Business logic services (audio, session, auth)
  Features/       Feature modules (Home, Sleep, Soundscapes, etc.)
    <Feature>/
      Views/      SwiftUI views
      ViewModels/ ObservableObject ViewModels
  Components/     Reusable UI components
  DesignSystem/   Colors, typography, symbols
  Configuration/  Secrets and config
  Extensions/     Swift extensions
  Resources/      Asset catalogs
```

## Conventions

- **Design system**: Use `SlipieColors`, `SlipieTypography`, `SlipieSymbols` everywhere. Never hardcode colors or fonts.
- **ViewModels**: `@MainActor final class`, use `@StateObject` in views. ViewModels own state and logic; views are display-only.
- **Services**: Concrete classes (no protocols unless testing requires it). Injected into ViewModels.
- **Components**: One type per file. If a view is used by more than one feature, it belongs in `Components/`.
- **Models**: One model per file in `Models/`. Never define models inline in view files.
- **Naming**: Views end with `View` (e.g. `HomeTabView`), ViewModels end with `ViewModel` (e.g. `HomeViewModel`).

## Dependencies

- **SlipieCoreKit** (local Swift package): Domain models, audio engine, Supabase client, HealthKit, sleep stage classifier.
- **Supabase**: Backend for auth, session storage, biometric events.

## Build

```bash
xcodebuild -project Slipie.xcodeproj -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.4' build
```

## Secrets

Copy `Slipie/Configuration/Secrets.swift.example` to `Secrets.swift` and fill in Supabase credentials.
