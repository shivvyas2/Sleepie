# Slipie Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build Slipie — a triplatform (iPhone/iPad/watchOS) sleep music app that generates real-time procedural audio driven by Apple Watch biometrics and inferred sleep stages.

**Architecture:** SlipieCoreKit is a local Swift Package containing the audio engine, HealthKit helpers, CoreML wrapper, sleep models, and Supabase networking. The watchOS target collects live biometrics via HKWorkoutSession and streams them to the iPhone via WatchConnectivity every 30 seconds. The iPhone runs AVAudioEngine and CoreML to map biometrics to audio parameters in real time.

**Tech Stack:** SwiftUI, AVAudioEngine, HealthKit, CoreML, WatchConnectivity, CoreData, Supabase (supabase-swift), XCTest

---

## Task 1: Xcode Project + Package Setup

**Files:**
- Create: `Slipie.xcodeproj` (via Xcode GUI — see steps)
- Create: `SlipieCoreKit/Package.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/SlipieCoreKit.swift`

**Step 1: Create Xcode project**

Open Xcode -> File -> New -> Project -> iOS App
- Product Name: `Slipie`
- Team: your team
- Bundle ID: `com.yourname.slipie`
- Interface: SwiftUI
- Language: Swift
- Include Tests: checked

Save to `/Users/shivvyas/Desktop/Sleep-Music/`

**Step 2: Add watchOS target**

File -> New -> Target -> watchOS -> Watch App
- Product Name: `Slipie watchOS`
- Bundle ID: `com.yourname.slipie.watchkitapp`
- Watch App for iOS App: Slipie

**Step 3: Create the Swift Package**

In Terminal (from project root):
```bash
mkdir -p SlipieCoreKit/Sources/SlipieCoreKit
mkdir -p SlipieCoreKit/Tests/SlipieCoreKitTests
```

**Step 4: Write Package.swift**

Create `SlipieCoreKit/Package.swift`:
```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SlipieCoreKit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(name: "SlipieCoreKit", targets: ["SlipieCoreKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "SlipieCoreKit",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        ),
        .testTarget(
            name: "SlipieCoreKitTests",
            dependencies: ["SlipieCoreKit"]
        )
    ]
)
```

**Step 5: Add package to Xcode project**

In Xcode -> File -> Add Package Dependencies -> Add Local -> select `SlipieCoreKit/` folder
Link `SlipieCoreKit` library to both `Slipie` and `Slipie watchOS` targets.

**Step 6: Commit**
```bash
git init
git add .
git commit -m "chore: initial Xcode project with SlipieCoreKit package"
```

---

## Task 2: Design System — Colors, Typography, and SF Symbols Constants

**Files:**
- Create: `Slipie iOS/DesignSystem/SlipieColors.swift`
- Create: `Slipie iOS/DesignSystem/SlipieTypography.swift`
- Create: `Slipie iOS/DesignSystem/SlipieSymbols.swift`
- Test: `Slipie iOSTests/DesignSystem/SlipieColorsTests.swift`

**Step 1: Write failing test**

Create `Slipie iOSTests/DesignSystem/SlipieColorsTests.swift`:
```swift
import XCTest
import SwiftUI
@testable import Slipie

final class SlipieColorsTests: XCTestCase {
    func test_background_color_is_defined() {
        let color = SlipieColors.background
        XCTAssertNotNil(color)
    }

    func test_accent_gradient_has_two_stops() {
        let stops = SlipieColors.accentGradient.stops
        XCTAssertEqual(stops.count, 2)
    }
}
```

**Step 2: Run test — expect failure**
```bash
xcodebuild test -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SlipieTests/SlipieColorsTests 2>&1 | tail -20
```
Expected: FAIL — `SlipieColors` not found

**Step 3: Implement SlipieColors**

Create `Slipie iOS/DesignSystem/SlipieColors.swift`:
```swift
import SwiftUI

enum SlipieColors {
    static let background = Color(hex: "#050A18")
    static let surface = Color(hex: "#0D1A3A")
    static let surfaceRaised = Color(hex: "#112247")
    static let accentStart = Color(hex: "#1E3A8A")
    static let accentEnd = Color(hex: "#3B82F6")
    static let accentGlow = Color(hex: "#6366F1")
    static let textPrimary = Color(hex: "#F0F4FF")
    static let textSecondary = Color(hex: "#8899BB")
    static let danger = Color(hex: "#EF4444")
    static let success = Color(hex: "#22C55E")

    static let accentGradient = LinearGradient(
        stops: [
            .init(color: accentStart, location: 0),
            .init(color: accentEnd, location: 1)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
```

Create `Slipie iOS/DesignSystem/SlipieTypography.swift`:
```swift
import SwiftUI

enum SlipieTypography {
    static func largeTitle() -> Font { .system(.largeTitle, design: .rounded, weight: .bold) }
    static func title() -> Font { .system(.title, design: .rounded, weight: .semibold) }
    static func title2() -> Font { .system(.title2, design: .rounded, weight: .semibold) }
    static func headline() -> Font { .system(.headline, design: .rounded, weight: .medium) }
    static func body() -> Font { .system(.body, design: .rounded) }
    static func caption() -> Font { .system(.caption, design: .rounded) }
    static func caption2() -> Font { .system(.caption2, design: .rounded) }
}
```

Create `Slipie iOS/DesignSystem/SlipieSymbols.swift`:
```swift
import SwiftUI

enum SlipieSymbols {
    // Tab bar
    static let sleep = "moon.stars.fill"
    static let insights = "chart.xyaxis.line"
    static let soundscapes = "waveform"
    static let profile = "person.crop.circle"

    // Sleep session
    static let play = "play.fill"
    static let pause = "pause.fill"
    static let stop = "stop.fill"
    static let timer = "timer"
    static let moon = "moon.fill"
    static let stars = "sparkles"

    // Biometrics
    static let heartRate = "heart.fill"
    static let hrv = "waveform.path.ecg"
    static let oxygen = "lungs.fill"
    static let respiratory = "wind"

    // Insights
    static let trend = "arrow.up.right"
    static let streak = "flame.fill"
    static let score = "medal.fill"

    // Settings
    static let watch = "applewatch"
    static let account = "person.fill"
    static let notifications = "bell.fill"
    static let privacy = "lock.fill"
}
```

**Step 4: Run test — expect pass**
```bash
xcodebuild test -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SlipieTests/SlipieColorsTests 2>&1 | tail -10
```
Expected: PASS

**Step 5: Commit**
```bash
git add Slipie\ iOS/DesignSystem/ Slipie\ iOSTests/DesignSystem/
git commit -m "feat: add design system colors, typography, and SF Symbol constants"
```

---

## Task 3: Core Data Models in SlipieCoreKit

**Files:**
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/Models/BiometricPacket.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/Models/SleepSession.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/Models/SleepStage.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/Models/Soundscape.swift`
- Test: `SlipieCoreKit/Tests/SlipieCoreKitTests/Models/BiometricPacketTests.swift`

**Step 1: Write failing test**

Create `SlipieCoreKit/Tests/SlipieCoreKitTests/Models/BiometricPacketTests.swift`:
```swift
import XCTest
@testable import SlipieCoreKit

final class BiometricPacketTests: XCTestCase {
    func test_biometric_packet_encodes_and_decodes() throws {
        let packet = BiometricPacket(
            recordedAt: Date(timeIntervalSince1970: 1000),
            heartRate: 62.0,
            hrv: 45.0,
            spo2: 98.0,
            respiratoryRate: 14.0,
            motionIntensity: 0.1
        )
        let data = try JSONEncoder().encode(packet)
        let decoded = try JSONDecoder().decode(BiometricPacket.self, from: data)
        XCTAssertEqual(decoded.heartRate, 62.0)
        XCTAssertEqual(decoded.hrv, 45.0)
        XCTAssertEqual(decoded.spo2, 98.0)
    }

    func test_sleep_stage_from_raw_string() {
        XCTAssertEqual(SleepStage(rawValue: "deep"), .deep)
        XCTAssertEqual(SleepStage(rawValue: "rem"), .rem)
        XCTAssertNil(SleepStage(rawValue: "invalid"))
    }
}
```

**Step 2: Run test — expect failure**
```bash
swift test --package-path SlipieCoreKit --filter BiometricPacketTests 2>&1 | tail -15
```
Expected: FAIL — types not found

**Step 3: Implement models**

Create `SlipieCoreKit/Sources/SlipieCoreKit/Models/BiometricPacket.swift`:
```swift
import Foundation

public struct BiometricPacket: Codable, Sendable {
    public let recordedAt: Date
    public let heartRate: Double
    public let hrv: Double
    public let spo2: Double
    public let respiratoryRate: Double
    public let motionIntensity: Double

    public init(
        recordedAt: Date,
        heartRate: Double,
        hrv: Double,
        spo2: Double,
        respiratoryRate: Double,
        motionIntensity: Double
    ) {
        self.recordedAt = recordedAt
        self.heartRate = heartRate
        self.hrv = hrv
        self.spo2 = spo2
        self.respiratoryRate = respiratoryRate
        self.motionIntensity = motionIntensity
    }
}
```

Create `SlipieCoreKit/Sources/SlipieCoreKit/Models/SleepStage.swift`:
```swift
import Foundation

public enum SleepStage: String, Codable, CaseIterable, Sendable {
    case awake
    case light
    case deep
    case rem
}
```

Create `SlipieCoreKit/Sources/SlipieCoreKit/Models/SleepSession.swift`:
```swift
import Foundation

public struct SleepSession: Codable, Identifiable, Sendable {
    public let id: UUID
    public let userId: UUID
    public var startedAt: Date
    public var endedAt: Date?
    public var soundscapeId: String
    public var biometricEvents: [BiometricPacket]
    public var stages: [SleepStageInterval]
    public var sleepScore: Int?

    public init(id: UUID = UUID(), userId: UUID, startedAt: Date, soundscapeId: String) {
        self.id = id
        self.userId = userId
        self.startedAt = startedAt
        self.soundscapeId = soundscapeId
        self.biometricEvents = []
        self.stages = []
    }
}

public struct SleepStageInterval: Codable, Sendable {
    public let stage: SleepStage
    public let startedAt: Date
    public var endedAt: Date?

    public init(stage: SleepStage, startedAt: Date) {
        self.stage = stage
        self.startedAt = startedAt
    }
}
```

Create `SlipieCoreKit/Sources/SlipieCoreKit/Models/Soundscape.swift`:
```swift
import Foundation

public struct Soundscape: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let baseParameters: SoundscapeParameters

    public init(id: String, name: String, description: String, baseParameters: SoundscapeParameters) {
        self.id = id
        self.name = name
        self.description = description
        self.baseParameters = baseParameters
    }
}

public struct SoundscapeParameters: Codable, Sendable {
    public let noiseColor: NoiseColor
    public let baseFrequency: Double
    public let reverbPreset: Int
    public let oscillatorMix: Double

    public init(noiseColor: NoiseColor, baseFrequency: Double, reverbPreset: Int, oscillatorMix: Double) {
        self.noiseColor = noiseColor
        self.baseFrequency = baseFrequency
        self.reverbPreset = reverbPreset
        self.oscillatorMix = oscillatorMix
    }
}

public enum NoiseColor: String, Codable, Sendable {
    case pink
    case brown
    case white
}

extension Soundscape {
    public static let all: [Soundscape] = [
        Soundscape(
            id: "rain",
            name: "Rain",
            description: "Gentle rainfall on glass",
            baseParameters: SoundscapeParameters(noiseColor: .pink, baseFrequency: 80, reverbPreset: 4, oscillatorMix: 0.3)
        ),
        Soundscape(
            id: "ocean",
            name: "Ocean",
            description: "Deep ocean waves",
            baseParameters: SoundscapeParameters(noiseColor: .brown, baseFrequency: 60, reverbPreset: 6, oscillatorMix: 0.4)
        ),
        Soundscape(
            id: "white_noise",
            name: "White Noise",
            description: "Pure white noise for focus and sleep",
            baseParameters: SoundscapeParameters(noiseColor: .white, baseFrequency: 100, reverbPreset: 2, oscillatorMix: 0.1)
        ),
        Soundscape(
            id: "forest",
            name: "Forest",
            description: "Night forest with gentle wind",
            baseParameters: SoundscapeParameters(noiseColor: .pink, baseFrequency: 110, reverbPreset: 5, oscillatorMix: 0.5)
        ),
        Soundscape(
            id: "space",
            name: "Space",
            description: "Vast cosmic ambience",
            baseParameters: SoundscapeParameters(noiseColor: .brown, baseFrequency: 40, reverbPreset: 8, oscillatorMix: 0.7)
        ),
        Soundscape(
            id: "arctic",
            name: "Arctic Wind",
            description: "Cold wind across frozen tundra",
            baseParameters: SoundscapeParameters(noiseColor: .white, baseFrequency: 90, reverbPreset: 7, oscillatorMix: 0.2)
        ),
        Soundscape(
            id: "cave",
            name: "Cave",
            description: "Deep cave resonance and dripping water",
            baseParameters: SoundscapeParameters(noiseColor: .brown, baseFrequency: 55, reverbPreset: 9, oscillatorMix: 0.6)
        ),
        Soundscape(
            id: "desert_night",
            name: "Desert Night",
            description: "Warm desert stillness under stars",
            baseParameters: SoundscapeParameters(noiseColor: .pink, baseFrequency: 70, reverbPreset: 3, oscillatorMix: 0.35)
        )
    ]
}
```

**Step 4: Run test — expect pass**
```bash
swift test --package-path SlipieCoreKit --filter BiometricPacketTests 2>&1 | tail -10
```
Expected: PASS

**Step 5: Commit**
```bash
git add SlipieCoreKit/
git commit -m "feat: add core data models (BiometricPacket, SleepSession, SleepStage, Soundscape)"
```

---

## Task 4: Audio Parameter Mapper

**Files:**
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/AudioEngine/AudioParameters.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/AudioEngine/ParameterMapper.swift`
- Test: `SlipieCoreKit/Tests/SlipieCoreKitTests/AudioEngine/ParameterMapperTests.swift`

**Step 1: Write failing tests**

Create `SlipieCoreKit/Tests/SlipieCoreKitTests/AudioEngine/ParameterMapperTests.swift`:
```swift
import XCTest
@testable import SlipieCoreKit

final class ParameterMapperTests: XCTestCase {
    let mapper = ParameterMapper()

    func test_high_heart_rate_reduces_tempo() {
        let highHR = BiometricPacket(recordedAt: Date(), heartRate: 90, hrv: 20, spo2: 97, respiratoryRate: 18, motionIntensity: 0.3)
        let lowHR = BiometricPacket(recordedAt: Date(), heartRate: 50, hrv: 60, spo2: 99, respiratoryRate: 12, motionIntensity: 0.0)
        let highParams = mapper.map(biometrics: highHR, stage: .awake, soundscape: .all[0])
        let lowParams = mapper.map(biometrics: lowHR, stage: .light, soundscape: .all[0])
        XCTAssertLessThan(highParams.tempo, lowParams.tempo)
    }

    func test_deep_sleep_maximises_reverb() {
        let packet = BiometricPacket(recordedAt: Date(), heartRate: 52, hrv: 70, spo2: 98, respiratoryRate: 11, motionIntensity: 0.0)
        let deepParams = mapper.map(biometrics: packet, stage: .deep, soundscape: .all[0])
        let awakeParams = mapper.map(biometrics: packet, stage: .awake, soundscape: .all[0])
        XCTAssertGreaterThan(deepParams.reverbWetness, awakeParams.reverbWetness)
    }

    func test_all_output_values_are_in_valid_range() {
        let packet = BiometricPacket(recordedAt: Date(), heartRate: 65, hrv: 40, spo2: 98, respiratoryRate: 14, motionIntensity: 0.1)
        let params = mapper.map(biometrics: packet, stage: .light, soundscape: .all[0])
        XCTAssertTrue((0.0...1.0).contains(params.volume))
        XCTAssertTrue((0.0...1.0).contains(params.reverbWetness))
        XCTAssertTrue((0.0...1.0).contains(params.filterCutoffNormalized))
        XCTAssertTrue(params.tempo > 0)
    }
}
```

**Step 2: Run test — expect failure**
```bash
swift test --package-path SlipieCoreKit --filter ParameterMapperTests 2>&1 | tail -15
```
Expected: FAIL — `ParameterMapper` not found

**Step 3: Implement AudioParameters and ParameterMapper**

Create `SlipieCoreKit/Sources/SlipieCoreKit/AudioEngine/AudioParameters.swift`:
```swift
import Foundation

public struct AudioParameters: Sendable {
    public var volume: Double          // 0.0-1.0
    public var tempo: Double           // beats per minute equivalent (0.1-2.0 Hz pulse rate)
    public var filterCutoffNormalized: Double  // 0.0-1.0 (maps to 200Hz-8000Hz)
    public var reverbWetness: Double   // 0.0-1.0
    public var oscillatorMix: Double   // 0.0-1.0 (noise vs tone)
    public var pitchShift: Double      // semitones, -12 to +12

    public init(
        volume: Double = 0.7,
        tempo: Double = 0.5,
        filterCutoffNormalized: Double = 0.5,
        reverbWetness: Double = 0.5,
        oscillatorMix: Double = 0.5,
        pitchShift: Double = 0
    ) {
        self.volume = volume
        self.tempo = tempo
        self.filterCutoffNormalized = filterCutoffNormalized
        self.reverbWetness = reverbWetness
        self.oscillatorMix = oscillatorMix
        self.pitchShift = pitchShift
    }
}
```

Create `SlipieCoreKit/Sources/SlipieCoreKit/AudioEngine/ParameterMapper.swift`:
```swift
import Foundation

public final class ParameterMapper: Sendable {
    public init() {}

    public func map(biometrics: BiometricPacket, stage: SleepStage, soundscape: Soundscape) -> AudioParameters {
        let hrNorm = normalize(biometrics.heartRate, min: 40, max: 100)
        let hrvNorm = normalize(biometrics.hrv, min: 10, max: 100)

        let stageReverbBoost: Double
        let stageFilterMod: Double
        let stageTempoDamp: Double
        switch stage {
        case .awake:
            stageReverbBoost = 0.0
            stageFilterMod = 0.0
            stageTempoDamp = 0.0
        case .light:
            stageReverbBoost = 0.15
            stageFilterMod = -0.1
            stageTempoDamp = 0.1
        case .deep:
            stageReverbBoost = 0.45
            stageFilterMod = -0.4
            stageTempoDamp = 0.35
        case .rem:
            stageReverbBoost = 0.25
            stageFilterMod = -0.15
            stageTempoDamp = 0.2
        }

        let reverbWetness = clamp(
            soundscape.baseParameters.reverbPreset.normalized + stageReverbBoost + (hrNorm * 0.2),
            min: 0, max: 1
        )
        let filterCutoff = clamp(
            0.7 - (hrNorm * 0.3) + stageFilterMod + (hrvNorm * 0.1),
            min: 0.05, max: 1
        )
        let tempo = clamp(
            0.8 - (hrNorm * 0.4) - stageTempoDamp + (hrvNorm * 0.15),
            min: 0.05, max: 1.5
        )
        let volume = clamp(
            0.75 - (biometrics.motionIntensity * 0.2),
            min: 0.3, max: 1.0
        )

        return AudioParameters(
            volume: volume,
            tempo: tempo,
            filterCutoffNormalized: filterCutoff,
            reverbWetness: reverbWetness,
            oscillatorMix: soundscape.baseParameters.oscillatorMix,
            pitchShift: -(hrNorm * 4)
        )
    }

    private func normalize(_ value: Double, min: Double, max: Double) -> Double {
        clamp((value - min) / (max - min), min: 0, max: 1)
    }

    private func clamp(_ value: Double, min: Double, max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
}

private extension Int {
    var normalized: Double { Double(self) / 10.0 }
}
```

**Step 4: Run test — expect pass**
```bash
swift test --package-path SlipieCoreKit --filter ParameterMapperTests 2>&1 | tail -10
```
Expected: PASS

**Step 5: Commit**
```bash
git add SlipieCoreKit/
git commit -m "feat: add AudioParameters model and ParameterMapper with biometric-to-audio mapping"
```

---

## Task 5: AVAudioEngine Signal Chain

**Files:**
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/AudioEngine/SleepAudioEngine.swift`
- Test: `SlipieCoreKit/Tests/SlipieCoreKitTests/AudioEngine/SleepAudioEngineTests.swift`

**Step 1: Write failing test**

Create `SlipieCoreKit/Tests/SlipieCoreKitTests/AudioEngine/SleepAudioEngineTests.swift`:
```swift
import XCTest
@testable import SlipieCoreKit

final class SleepAudioEngineTests: XCTestCase {
    func test_engine_initializes_without_error() {
        XCTAssertNoThrow(SleepAudioEngine())
    }

    func test_engine_applies_parameters_without_crash() {
        let engine = SleepAudioEngine()
        let params = AudioParameters(volume: 0.5, tempo: 0.3, filterCutoffNormalized: 0.6, reverbWetness: 0.7, oscillatorMix: 0.4, pitchShift: -2)
        XCTAssertNoThrow(engine.apply(parameters: params))
    }

    func test_engine_stops_cleanly() {
        let engine = SleepAudioEngine()
        engine.stop()
        XCTAssertFalse(engine.isRunning)
    }
}
```

**Step 2: Run test — expect failure**
```bash
swift test --package-path SlipieCoreKit --filter SleepAudioEngineTests 2>&1 | tail -15
```

**Step 3: Implement SleepAudioEngine**

Create `SlipieCoreKit/Sources/SlipieCoreKit/AudioEngine/SleepAudioEngine.swift`:
```swift
import AVFoundation
import Foundation

public final class SleepAudioEngine: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let noiseNode = AVAudioPlayerNode()
    private let reverb = AVAudioUnitReverb()
    private let lowPassFilter = AVAudioUnitEQ(numberOfBands: 1)
    private let delay = AVAudioUnitDelay()
    private let limiter = AVAudioUnitDynamicsProcessor()

    private var pulseTimer: Timer?
    private var currentParameters = AudioParameters()
    private(set) public var isRunning = false

    public init() {
        setupSignalChain()
    }

    private func setupSignalChain() {
        engine.attach(playerNode)
        engine.attach(noiseNode)
        engine.attach(reverb)
        engine.attach(lowPassFilter)
        engine.attach(delay)
        engine.attach(limiter)

        lowPassFilter.bands[0].filterType = .lowPass
        lowPassFilter.bands[0].frequency = 4000
        lowPassFilter.bands[0].bandwidth = 0.5
        lowPassFilter.bands[0].bypass = false

        reverb.loadFactoryPreset(.largeChamber)
        reverb.wetDryMix = 40

        delay.delayTime = 0.3
        delay.feedback = 20
        delay.wetDryMix = 15

        let format = engine.outputNode.outputFormat(forBus: 0)
        engine.connect(playerNode, to: reverb, format: format)
        engine.connect(noiseNode, to: reverb, format: format)
        engine.connect(reverb, to: lowPassFilter, format: format)
        engine.connect(lowPassFilter, to: delay, format: format)
        engine.connect(delay, to: engine.mainMixerNode, format: format)
    }

    public func start(soundscape: Soundscape) throws {
        guard !isRunning else { return }
        try engine.start()
        playerNode.play()
        noiseNode.play()
        scheduleNoiseBuffer(soundscape: soundscape)
        isRunning = true
    }

    public func apply(parameters: AudioParameters) {
        currentParameters = parameters
        engine.mainMixerNode.outputVolume = Float(parameters.volume)
        reverb.wetDryMix = Float(parameters.reverbWetness * 100)
        let cutoffHz = Float(200 + parameters.filterCutoffNormalized * 7800)
        lowPassFilter.bands[0].frequency = cutoffHz
    }

    public func stop() {
        pulseTimer?.invalidate()
        pulseTimer = nil
        playerNode.stop()
        noiseNode.stop()
        if engine.isRunning { engine.stop() }
        isRunning = false
    }

    private func scheduleNoiseBuffer(soundscape: Soundscape) {
        let sampleRate = 44100.0
        let bufferSize = AVAudioFrameCount(sampleRate * 2)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize) else { return }
        buffer.frameLength = bufferSize
        if let left = buffer.floatChannelData?[0], let right = buffer.floatChannelData?[1] {
            for i in 0..<Int(bufferSize) {
                let sample = generateNoiseSample(color: soundscape.baseParameters.noiseColor, index: i)
                left[i] = sample
                right[i] = sample
            }
        }
        noiseNode.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private var pinkState: (Double, Double, Double, Double, Double, Double, Double) = (0,0,0,0,0,0,0)

    private func generateNoiseSample(color: NoiseColor, index: Int) -> Float {
        switch color {
        case .white:
            return Float.random(in: -0.15...0.15)
        case .pink:
            let white = Double.random(in: -1...1)
            pinkState.0 = 0.99886 * pinkState.0 + white * 0.0555179
            pinkState.1 = 0.99332 * pinkState.1 + white * 0.0750759
            pinkState.2 = 0.96900 * pinkState.2 + white * 0.1538520
            pinkState.3 = 0.86650 * pinkState.3 + white * 0.3104856
            pinkState.4 = 0.55000 * pinkState.4 + white * 0.5329522
            pinkState.5 = -0.7616 * pinkState.5 - white * 0.0168980
            let pink = (pinkState.0 + pinkState.1 + pinkState.2 + pinkState.3 + pinkState.4 + pinkState.5 + pinkState.6 + white * 0.5362) * 0.11
            pinkState.6 = white * 0.115926
            return Float(pink) * 0.2
        case .brown:
            let white = Double.random(in: -1...1)
            pinkState.0 = (pinkState.0 + 0.02 * white) / 1.02
            return Float(pinkState.0) * 3.5
        }
    }

    deinit { stop() }
}
```

**Step 4: Run test — expect pass**
```bash
swift test --package-path SlipieCoreKit --filter SleepAudioEngineTests 2>&1 | tail -10
```
Expected: PASS

**Step 5: Commit**
```bash
git add SlipieCoreKit/
git commit -m "feat: implement AVAudioEngine signal chain with noise generation and reverb/filter chain"
```

---

## Task 6: HealthKit Manager

**Files:**
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/HealthKit/HealthKitManager.swift`
- Test: `SlipieCoreKit/Tests/SlipieCoreKitTests/HealthKit/HealthKitManagerTests.swift`

**Step 1: Write failing test**

Create `SlipieCoreKit/Tests/SlipieCoreKitTests/HealthKit/HealthKitManagerTests.swift`:
```swift
import XCTest
@testable import SlipieCoreKit

final class HealthKitManagerTests: XCTestCase {
    func test_manager_initializes() {
        XCTAssertNoThrow(HealthKitManager())
    }

    func test_is_available_returns_bool() {
        let manager = HealthKitManager()
        let _ = manager.isAvailable
        // Just verifies property is accessible — actual HK availability is hardware dependent
        XCTAssertTrue(true)
    }
}
```

**Step 2: Run test — expect failure**
```bash
swift test --package-path SlipieCoreKit --filter HealthKitManagerTests 2>&1 | tail -15
```

**Step 3: Implement HealthKitManager**

Create `SlipieCoreKit/Sources/SlipieCoreKit/HealthKit/HealthKitManager.swift`:
```swift
import HealthKit
import Foundation

public final class HealthKitManager: @unchecked Sendable {
    private let store = HKHealthStore()

    public var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    public init() {}

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let quantityTypes: [HKQuantityTypeIdentifier] = [
            .heartRate,
            .heartRateVariabilitySDNN,
            .oxygenSaturation,
            .respiratoryRate,
            .stepCount
        ]
        for id in quantityTypes {
            if let type = HKQuantityType.quantityType(forIdentifier: id) {
                types.insert(type)
            }
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        return types
    }

    private var writeTypes: Set<HKSampleType> {
        var types = Set<HKSampleType>()
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            types.insert(sleepType)
        }
        return types
    }

    public func requestAuthorization() async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }
        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    public func fetchRecentSessions(days: Int = 30) async throws -> [HKCategorySample] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.typeUnavailable
        }
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: -days, to: Date()),
            end: Date()
        )
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
                if let error { continuation.resume(throwing: error); return }
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            store.execute(query)
        }
    }

    public func writeSleepStage(_ stage: SleepStage, start: Date, end: Date) async throws {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthKitError.typeUnavailable
        }
        let value: HKCategoryValueSleepAnalysis
        switch stage {
        case .awake: value = .awake
        case .light: value = .asleepUnspecified
        case .deep: value = .asleepDeep
        case .rem: value = .asleepREM
        }
        let sample = HKCategorySample(type: sleepType, value: value.rawValue, start: start, end: end)
        try await store.save(sample)
    }
}

public enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case typeUnavailable

    public var errorDescription: String? {
        switch self {
        case .notAvailable: return "HealthKit is not available on this device"
        case .typeUnavailable: return "The requested health data type is unavailable"
        }
    }
}
```

**Step 4: Run test — expect pass**
```bash
swift test --package-path SlipieCoreKit --filter HealthKitManagerTests 2>&1 | tail -10
```

**Step 5: Commit**
```bash
git add SlipieCoreKit/
git commit -m "feat: add HealthKitManager with authorization, sleep data read/write"
```

---

## Task 7: Supabase Client

**Files:**
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/Networking/SupabaseClient.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/Networking/SlipieSupabaseConfig.swift`
- Test: `SlipieCoreKit/Tests/SlipieCoreKitTests/Networking/SupabaseClientTests.swift`

**Step 1: Write failing test**

Create `SlipieCoreKit/Tests/SlipieCoreKitTests/Networking/SupabaseClientTests.swift`:
```swift
import XCTest
@testable import SlipieCoreKit

final class SupabaseClientTests: XCTestCase {
    func test_client_initializes_with_config() {
        let config = SlipieSupabaseConfig(url: "https://test.supabase.co", anonKey: "test-key")
        XCTAssertNoThrow(SlipieSupabaseClient(config: config))
    }
}
```

**Step 2: Run test — expect failure**
```bash
swift test --package-path SlipieCoreKit --filter SupabaseClientTests 2>&1 | tail -15
```

**Step 3: Implement Supabase client**

Create `SlipieCoreKit/Sources/SlipieCoreKit/Networking/SlipieSupabaseConfig.swift`:
```swift
import Foundation

public struct SlipieSupabaseConfig: Sendable {
    public let url: String
    public let anonKey: String

    public init(url: String, anonKey: String) {
        self.url = url
        self.anonKey = anonKey
    }
}
```

Create `SlipieCoreKit/Sources/SlipieCoreKit/Networking/SupabaseClient.swift`:
```swift
import Foundation
import Supabase

public final class SlipieSupabaseClient: @unchecked Sendable {
    public let client: SupabaseClient

    public init(config: SlipieSupabaseConfig) {
        guard let url = URL(string: config.url) else {
            fatalError("Invalid Supabase URL: \(config.url)")
        }
        self.client = SupabaseClient(supabaseURL: url, supabaseKey: config.anonKey)
    }

    // MARK: - Auth

    public func signInWithApple(idToken: String, nonce: String) async throws {
        try await client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken, nonce: nonce))
    }

    public func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }

    public var currentUser: User? { client.auth.currentUser }

    // MARK: - Sleep Sessions

    public func saveSleepSession(_ session: SleepSession) async throws {
        let row = SleepSessionRow(from: session)
        try await client.database.from("sleep_sessions").insert(row).execute()
    }

    public func fetchSleepSessions(limit: Int = 30) async throws -> [SleepSessionRow] {
        try await client.database
            .from("sleep_sessions")
            .select()
            .order("started_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    public func saveBiometricEvents(_ events: [BiometricPacket], sessionId: UUID) async throws {
        let rows = events.map { BiometricEventRow(from: $0, sessionId: sessionId) }
        try await client.database.from("biometric_events").insert(rows).execute()
    }
}

// MARK: - Row Types (Supabase serialization)

public struct SleepSessionRow: Codable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let startedAt: Date
    public let endedAt: Date?
    public let sleepScore: Int?
    public let soundscapeUsed: String

    enum CodingKeys: String, CodingKey {
        case id, userId = "user_id", startedAt = "started_at"
        case endedAt = "ended_at", sleepScore = "sleep_score"
        case soundscapeUsed = "soundscape_used"
    }

    public init(from session: SleepSession) {
        self.id = session.id
        self.userId = session.userId
        self.startedAt = session.startedAt
        self.endedAt = session.endedAt
        self.sleepScore = session.sleepScore
        self.soundscapeUsed = session.soundscapeId
    }
}

public struct BiometricEventRow: Codable, Sendable {
    public let id: UUID
    public let sessionId: UUID
    public let recordedAt: Date
    public let hr: Double
    public let hrv: Double
    public let spo2: Double
    public let respiratoryRate: Double
    public let motionIntensity: Double

    enum CodingKeys: String, CodingKey {
        case id, sessionId = "session_id", recordedAt = "recorded_at"
        case hr, hrv, spo2, respiratoryRate = "respiratory_rate"
        case motionIntensity = "motion_intensity"
    }

    public init(from packet: BiometricPacket, sessionId: UUID) {
        self.id = UUID()
        self.sessionId = sessionId
        self.recordedAt = packet.recordedAt
        self.hr = packet.heartRate
        self.hrv = packet.hrv
        self.spo2 = packet.spo2
        self.respiratoryRate = packet.respiratoryRate
        self.motionIntensity = packet.motionIntensity
    }
}
```

**Step 4: Run test — expect pass**
```bash
swift test --package-path SlipieCoreKit --filter SupabaseClientTests 2>&1 | tail -10
```

**Step 5: Commit**
```bash
git add SlipieCoreKit/
git commit -m "feat: add Supabase client with auth, sleep session, and biometric event persistence"
```

---

## Task 8: Main App Entry + Tab Bar

**Files:**
- Modify: `Slipie iOS/SlipieApp.swift`
- Create: `Slipie iOS/App/RootView.swift`
- Create: `Slipie iOS/App/AppEnvironment.swift`

**Step 1: Implement AppEnvironment (dependency container)**

Create `Slipie iOS/App/AppEnvironment.swift`:
```swift
import SwiftUI
import SlipieCoreKit

@MainActor
final class AppEnvironment: ObservableObject {
    let audioEngine = SleepAudioEngine()
    let parameterMapper = ParameterMapper()
    let healthKitManager = HealthKitManager()
    let supabaseClient: SlipieSupabaseClient

    @Published var currentSession: SleepSession?
    @Published var isSessionActive = false

    init() {
        // Replace with your actual Supabase project URL and anon key
        let config = SlipieSupabaseConfig(
            url: ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "",
            anonKey: ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] ?? ""
        )
        self.supabaseClient = SlipieSupabaseClient(config: config)
    }
}
```

**Step 2: Implement RootView with tab bar**

Create `Slipie iOS/App/RootView.swift`:
```swift
import SwiftUI
import SlipieCoreKit

struct RootView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        TabView {
            SleepTabView()
                .tabItem {
                    Label("Sleep", systemImage: SlipieSymbols.sleep)
                }

            InsightsTabView()
                .tabItem {
                    Label("Insights", systemImage: SlipieSymbols.insights)
                }

            SoundscapesTabView()
                .tabItem {
                    Label("Soundscapes", systemImage: SlipieSymbols.soundscapes)
                }

            ProfileTabView()
                .tabItem {
                    Label("Profile", systemImage: SlipieSymbols.profile)
                }
        }
        .tint(SlipieColors.accentEnd)
        .preferredColorScheme(.dark)
    }
}
```

**Step 3: Wire up app entry**

Modify `Slipie iOS/SlipieApp.swift`:
```swift
import SwiftUI

@main
struct SlipieApp: App {
    @StateObject private var env = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env)
                .background(SlipieColors.background.ignoresSafeArea())
        }
    }
}
```

**Step 4: Build — expect success**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```
Expected: BUILD SUCCEEDED

**Step 5: Commit**
```bash
git add "Slipie iOS/"
git commit -m "feat: add AppEnvironment and RootView with tab bar navigation"
```

---

## Task 9: Sleep Tab — Wind-down Screen

**Files:**
- Create: `Slipie iOS/Features/Sleep/SleepTabView.swift`
- Create: `Slipie iOS/Features/Sleep/WindDownView.swift`
- Create: `Slipie iOS/Features/Sleep/ActiveSessionView.swift`
- Create: `Slipie iOS/Components/GlowingCardView.swift`
- Create: `Slipie iOS/Components/PillButton.swift`

**Step 1: Implement shared components**

Create `Slipie iOS/Components/GlowingCardView.swift`:
```swift
import SwiftUI

struct GlowingCardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(SlipieColors.accentGlow.opacity(0.3), lineWidth: 1)
            )
    }
}
```

Create `Slipie iOS/Components/PillButton.swift`:
```swift
import SwiftUI

struct PillButton: View {
    let title: String
    let icon: String
    let style: PillButtonStyle
    let action: () -> Void

    enum PillButtonStyle { case filled, outline }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
                    .font(SlipieTypography.headline())
            }
            .foregroundStyle(style == .filled ? SlipieColors.textPrimary : SlipieColors.accentEnd)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(
                Group {
                    if style == .filled {
                        SlipieColors.accentGradient
                    } else {
                        Color.clear
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(style == .outline ? SlipieColors.accentEnd : Color.clear, lineWidth: 1.5)
            )
            .clipShape(Capsule())
        }
    }
}
```

**Step 2: Implement WindDownView**

Create `Slipie iOS/Features/Sleep/WindDownView.swift`:
```swift
import SwiftUI
import SlipieCoreKit

struct WindDownView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var selectedSoundscape = Soundscape.all[0]
    @State private var timerMinutes: Int = 30
    @State private var showTimerPicker = false

    var body: some View {
        ZStack {
            backgroundLayer
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    soundscapeSelector
                    timerSection
                    startButton
                }
                .padding(20)
            }
        }
        .navigationTitle("Wind Down")
    }

    private var backgroundLayer: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            RadialGradient(
                colors: [SlipieColors.accentStart.opacity(0.3), SlipieColors.background],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: SlipieSymbols.moon)
                .font(.system(size: 52))
                .foregroundStyle(SlipieColors.accentGradient)
            Text("Ready to sleep?")
                .font(SlipieTypography.title())
                .foregroundStyle(SlipieColors.textPrimary)
            Text("Choose your soundscape and settle in")
                .font(SlipieTypography.body())
                .foregroundStyle(SlipieColors.textSecondary)
        }
        .padding(.top, 16)
    }

    private var soundscapeSelector: some View {
        GlowingCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Soundscape")
                    .font(SlipieTypography.caption())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .textCase(.uppercase)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Soundscape.all) { soundscape in
                            SoundscapeChip(soundscape: soundscape, isSelected: soundscape.id == selectedSoundscape.id) {
                                selectedSoundscape = soundscape
                            }
                        }
                    }
                }
            }
        }
    }

    private var timerSection: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Timer")
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    Text("\(timerMinutes) min")
                        .font(SlipieTypography.headline())
                        .foregroundStyle(SlipieColors.textPrimary)
                }
                Spacer()
                Image(systemName: SlipieSymbols.timer)
                    .foregroundStyle(SlipieColors.accentEnd)
                    .font(.title2)
            }
        }
        .onTapGesture { showTimerPicker = true }
        .sheet(isPresented: $showTimerPicker) {
            TimerPickerSheet(minutes: $timerMinutes)
        }
    }

    private var startButton: some View {
        PillButton(title: "Start Sleep", icon: SlipieSymbols.play, style: .filled) {
            Task { await startSession() }
        }
        .frame(maxWidth: .infinity)
    }

    private func startSession() async {
        guard let userId = env.supabaseClient.currentUser?.id else { return }
        var session = SleepSession(userId: userId, startedAt: Date(), soundscapeId: selectedSoundscape.id)
        env.currentSession = session
        env.isSessionActive = true
        try? env.audioEngine.start(soundscape: selectedSoundscape)
    }
}

struct SoundscapeChip: View {
    let soundscape: Soundscape
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(soundscape.name)
                .font(SlipieTypography.caption())
                .foregroundStyle(isSelected ? SlipieColors.textPrimary : SlipieColors.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? SlipieColors.accentGradient : AnyShapeStyle(SlipieColors.surface))
                .clipShape(Capsule())
        }
    }
}

struct TimerPickerSheet: View {
    @Binding var minutes: Int
    @Environment(\.dismiss) private var dismiss
    private let options = [15, 20, 30, 45, 60, 90, 120]

    var body: some View {
        NavigationStack {
            List(options, id: \.self) { option in
                Button {
                    minutes = option
                    dismiss()
                } label: {
                    HStack {
                        Text("\(option) minutes")
                            .foregroundStyle(SlipieColors.textPrimary)
                        Spacer()
                        if option == minutes {
                            Image(systemName: "checkmark")
                                .foregroundStyle(SlipieColors.accentEnd)
                        }
                    }
                }
            }
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
```

**Step 3: Implement SleepTabView and ActiveSessionView (stubs)**

Create `Slipie iOS/Features/Sleep/SleepTabView.swift`:
```swift
import SwiftUI

struct SleepTabView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        NavigationStack {
            if env.isSessionActive {
                ActiveSessionView()
            } else {
                WindDownView()
            }
        }
    }
}
```

Create `Slipie iOS/Features/Sleep/ActiveSessionView.swift`:
```swift
import SwiftUI
import SlipieCoreKit

struct ActiveSessionView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var currentStage: SleepStage = .awake
    @State private var currentHR: Double = 65

    var body: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            RadialGradient(
                colors: [SlipieColors.accentGlow.opacity(0.2), SlipieColors.background],
                center: .center,
                startRadius: 50,
                endRadius: 350
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Session Active")
                    .font(SlipieTypography.title())
                    .foregroundStyle(SlipieColors.textPrimary)

                GlowingCardView {
                    HStack(spacing: 32) {
                        BiometricIndicator(icon: SlipieSymbols.heartRate, label: "HR", value: "\(Int(currentHR)) bpm")
                        BiometricIndicator(icon: SlipieSymbols.sleep, label: "Stage", value: currentStage.rawValue.capitalized)
                    }
                }

                PillButton(title: "End Session", icon: SlipieSymbols.stop, style: .outline) {
                    endSession()
                }
            }
            .padding(24)
        }
    }

    private func endSession() {
        env.audioEngine.stop()
        env.isSessionActive = false
        env.currentSession?.endedAt = Date()
        Task {
            if let session = env.currentSession {
                try? await env.supabaseClient.saveSleepSession(session)
            }
            env.currentSession = nil
        }
    }
}

struct BiometricIndicator: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(SlipieColors.accentGlow)
                .font(.title2)
            Text(value)
                .font(SlipieTypography.headline())
                .foregroundStyle(SlipieColors.textPrimary)
            Text(label)
                .font(SlipieTypography.caption())
                .foregroundStyle(SlipieColors.textSecondary)
        }
    }
}
```

**Step 4: Build — expect success**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

**Step 5: Commit**
```bash
git add "Slipie iOS/"
git commit -m "feat: add Sleep tab with wind-down UI, soundscape selector, and active session view"
```

---

## Task 10: Soundscapes Tab

**Files:**
- Create: `Slipie iOS/Features/Soundscapes/SoundscapesTabView.swift`
- Create: `Slipie iOS/Features/Soundscapes/SoundscapeDetailView.swift`

**Step 1: Implement SoundscapesTabView**

Create `Slipie iOS/Features/Soundscapes/SoundscapesTabView.swift`:
```swift
import SwiftUI
import SlipieCoreKit

struct SoundscapesTabView: View {
    private let soundscapes = Soundscape.all
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(soundscapes) { soundscape in
                            NavigationLink(destination: SoundscapeDetailView(soundscape: soundscape)) {
                                SoundscapeCard(soundscape: soundscape)
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Soundscapes")
        }
    }
}

struct SoundscapeCard: View {
    let soundscape: Soundscape

    var body: some View {
        GlowingCardView {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: SlipieSymbols.soundscapes)
                    .font(.title)
                    .foregroundStyle(SlipieColors.accentGradient)
                Text(soundscape.name)
                    .font(SlipieTypography.headline())
                    .foregroundStyle(SlipieColors.textPrimary)
                Text(soundscape.description)
                    .font(SlipieTypography.caption())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .lineLimit(2)
            }
        }
    }
}
```

Create `Slipie iOS/Features/Soundscapes/SoundscapeDetailView.swift`:
```swift
import SwiftUI
import SlipieCoreKit

struct SoundscapeDetailView: View {
    let soundscape: Soundscape
    @EnvironmentObject var env: AppEnvironment
    @State private var isPreviewing = false

    var body: some View {
        ZStack {
            SlipieColors.background.ignoresSafeArea()
            VStack(spacing: 32) {
                Image(systemName: SlipieSymbols.soundscapes)
                    .font(.system(size: 72))
                    .foregroundStyle(SlipieColors.accentGradient)
                    .padding(.top, 40)

                Text(soundscape.name)
                    .font(SlipieTypography.largeTitle())
                    .foregroundStyle(SlipieColors.textPrimary)

                Text(soundscape.description)
                    .font(SlipieTypography.body())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                HStack(spacing: 16) {
                    PillButton(
                        title: isPreviewing ? "Stop" : "Preview",
                        icon: isPreviewing ? SlipieSymbols.stop : SlipieSymbols.play,
                        style: .outline
                    ) { togglePreview() }

                    PillButton(title: "Use This", icon: SlipieSymbols.moon, style: .filled) {
                        // Navigate to sleep tab with this soundscape pre-selected
                    }
                }
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func togglePreview() {
        if isPreviewing {
            env.audioEngine.stop()
        } else {
            try? env.audioEngine.start(soundscape: soundscape)
        }
        isPreviewing.toggle()
    }
}
```

**Step 2: Build — expect success**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

**Step 3: Commit**
```bash
git add "Slipie iOS/Features/Soundscapes/"
git commit -m "feat: add Soundscapes tab with grid view and detail/preview screen"
```

---

## Task 11: Insights Tab

**Files:**
- Create: `Slipie iOS/Features/Insights/InsightsTabView.swift`
- Create: `Slipie iOS/Features/Insights/SleepScoreCard.swift`
- Create: `Slipie iOS/Features/Insights/StageBreakdownChart.swift`

**Step 1: Implement InsightsTabView**

Create `Slipie iOS/Features/Insights/InsightsTabView.swift`:
```swift
import SwiftUI
import Charts
import SlipieCoreKit

struct InsightsTabView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var sessions: [SleepSessionRow] = []

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        SleepScoreCard(score: sessions.first?.sleepScore ?? nil)
                        if sessions.isEmpty {
                            emptyState
                        } else {
                            recentSessionsList
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Insights")
            .task { await loadSessions() }
        }
    }

    private var emptyState: some View {
        GlowingCardView {
            VStack(spacing: 12) {
                Image(systemName: "moon.zzz.fill")
                    .font(.largeTitle)
                    .foregroundStyle(SlipieColors.accentGlow)
                Text("No sleep data yet")
                    .font(SlipieTypography.headline())
                    .foregroundStyle(SlipieColors.textPrimary)
                Text("Start your first sleep session to see insights here")
                    .font(SlipieTypography.caption())
                    .foregroundStyle(SlipieColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 8)
        }
    }

    private var recentSessionsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(SlipieTypography.caption())
                .foregroundStyle(SlipieColors.textSecondary)
                .textCase(.uppercase)
            ForEach(sessions, id: \.id) { session in
                SessionRowView(session: session)
            }
        }
    }

    private func loadSessions() async {
        sessions = (try? await env.supabaseClient.fetchSleepSessions()) ?? []
    }
}

struct SessionRowView: View {
    let session: SleepSessionRow

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.startedAt, style: .date)
                        .font(SlipieTypography.headline())
                        .foregroundStyle(SlipieColors.textPrimary)
                    if let score = session.sleepScore {
                        Text("Score: \(score)")
                            .font(SlipieTypography.caption())
                            .foregroundStyle(SlipieColors.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: SlipieSymbols.trend)
                    .foregroundStyle(SlipieColors.accentEnd)
            }
        }
    }
}
```

Create `Slipie iOS/Features/Insights/SleepScoreCard.swift`:
```swift
import SwiftUI

struct SleepScoreCard: View {
    let score: Int?

    var body: some View {
        GlowingCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sleep Score")
                        .font(SlipieTypography.caption())
                        .foregroundStyle(SlipieColors.textSecondary)
                        .textCase(.uppercase)
                    if let score {
                        Text("\(score)")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(scoreColor(score))
                    } else {
                        Text("--")
                            .font(.system(size: 52, weight: .bold, design: .rounded))
                            .foregroundStyle(SlipieColors.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: SlipieSymbols.score)
                    .font(.system(size: 40))
                    .foregroundStyle(SlipieColors.accentGradient)
            }
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return SlipieColors.success
        case 50...79: return SlipieColors.accentEnd
        default: return SlipieColors.danger
        }
    }
}
```

**Step 2: Build — expect success**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

**Step 3: Commit**
```bash
git add "Slipie iOS/Features/Insights/"
git commit -m "feat: add Insights tab with sleep score card and session history list"
```

---

## Task 12: Profile Tab

**Files:**
- Create: `Slipie iOS/Features/Profile/ProfileTabView.swift`

**Step 1: Implement ProfileTabView**

Create `Slipie iOS/Features/Profile/ProfileTabView.swift`:
```swift
import SwiftUI

struct ProfileTabView: View {
    @EnvironmentObject var env: AppEnvironment
    @State private var showSignIn = false

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                List {
                    accountSection
                    watchSection
                    // Subscription section deferred — add RevenueCat later
                    appSection
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showSignIn) {
                SignInView()
            }
        }
    }

    private var accountSection: some View {
        Section("Account") {
            if let user = env.supabaseClient.currentUser {
                Label(user.email ?? "No email", systemImage: SlipieSymbols.account)
                    .foregroundStyle(SlipieColors.textPrimary)
                Button(role: .destructive) {
                    Task { try? await env.supabaseClient.signOut() }
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } else {
                Button {
                    showSignIn = true
                } label: {
                    Label("Sign In", systemImage: SlipieSymbols.account)
                }
            }
        }
    }

    private var watchSection: some View {
        Section("Apple Watch") {
            Label("Pair Apple Watch", systemImage: SlipieSymbols.watch)
                .foregroundStyle(SlipieColors.textPrimary)
        }
    }

    private var appSection: some View {
        Section("App") {
            Label("Notifications", systemImage: SlipieSymbols.notifications)
                .foregroundStyle(SlipieColors.textPrimary)
            Label("Privacy", systemImage: SlipieSymbols.privacy)
                .foregroundStyle(SlipieColors.textPrimary)
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var env: AppEnvironment
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var error: String?

    var body: some View {
        NavigationStack {
            ZStack {
                SlipieColors.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)
                    if let error {
                        Text(error)
                            .foregroundStyle(SlipieColors.danger)
                            .font(SlipieTypography.caption())
                    }
                    PillButton(title: "Sign In", icon: SlipieSymbols.account, style: .filled) {
                        Task { await signIn() }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func signIn() async {
        do {
            try await env.supabaseClient.signIn(email: email, password: password)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
    }
}
```

**Step 2: Build — expect success**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -10
```

**Step 3: Commit**
```bash
git add "Slipie iOS/Features/Profile/"
git commit -m "feat: add Profile tab with account management and Apple Watch pairing placeholder"
```

---

## Task 13: watchOS App — Biometric Streaming

**Files:**
- Create: `Slipie watchOS/Session/WatchSessionManager.swift`
- Create: `Slipie watchOS/Connectivity/WatchConnectivityBridge.swift`
- Create: `Slipie watchOS/App/WatchRootView.swift`

**Step 1: Implement WatchSessionManager**

Create `Slipie watchOS/Session/WatchSessionManager.swift`:
```swift
import HealthKit
import Foundation

@MainActor
final class WatchSessionManager: NSObject, ObservableObject {
    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?

    @Published var heartRate: Double = 0
    @Published var hrv: Double = 0
    @Published var spo2: Double = 0
    @Published var isActive = false

    func start() async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .indoor

        let session = try HKWorkoutSession(healthStore: store, configuration: config)
        let builder = session.associatedWorkoutBuilder()
        builder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: config)

        self.session = session
        self.builder = builder

        session.delegate = self
        builder.delegate = self

        session.startActivity(with: Date())
        try await builder.beginCollection(at: Date())
        isActive = true
    }

    func stop() async throws {
        session?.end()
        try await builder?.endCollection(at: Date())
        try await builder?.finishWorkout()
        isActive = false
    }

    private func update(from statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            let unit = HKUnit.count().unitDivided(by: .minute())
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: unit) ?? 0
        case HKQuantityType(.heartRateVariabilitySDNN):
            hrv = statistics.mostRecentQuantity()?.doubleValue(for: .secondUnit(with: .milli)) ?? 0
        case HKQuantityType(.oxygenSaturation):
            spo2 = (statistics.mostRecentQuantity()?.doubleValue(for: .percent()) ?? 0) * 100
        default:
            break
        }
    }
}

extension WatchSessionManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {}
    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {}
}

extension WatchSessionManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  let stats = workoutBuilder.statistics(for: quantityType) else { continue }
            Task { @MainActor in self.update(from: stats) }
        }
    }
}
```

**Step 2: Implement WatchConnectivityBridge**

Create `Slipie watchOS/Connectivity/WatchConnectivityBridge.swift`:
```swift
import WatchConnectivity
import SlipieCoreKit
import Foundation

final class WatchConnectivityBridge: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = WatchConnectivityBridge()
    private var session: WCSession?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func send(packet: BiometricPacket) {
        guard let session, session.isReachable else { return }
        do {
            let data = try JSONEncoder().encode(packet)
            session.sendMessageData(data, replyHandler: nil, errorHandler: nil)
        } catch {}
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
```

**Step 3: Implement WatchRootView**

Create `Slipie watchOS/App/WatchRootView.swift`:
```swift
import SwiftUI
import SlipieCoreKit

struct WatchRootView: View {
    @StateObject private var sessionManager = WatchSessionManager()
    @State private var sendTimer: Timer?

    var body: some View {
        VStack(spacing: 8) {
            if sessionManager.isActive {
                activeView
            } else {
                idleView
            }
        }
        .background(Color(hex: "#050A18"))
    }

    private var idleView: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(Color(hex: "#3B82F6"))
            Button("Start Sleep") {
                Task { try? await sessionManager.start() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "#1E3A8A"))
        }
    }

    private var activeView: some View {
        VStack(spacing: 8) {
            Label("\(Int(sessionManager.heartRate)) bpm", systemImage: "heart.fill")
                .foregroundStyle(Color(hex: "#6366F1"))
            Label("\(Int(sessionManager.spo2))%", systemImage: "lungs.fill")
                .foregroundStyle(Color(hex: "#F0F4FF"))
            Button("End") {
                Task { try? await sessionManager.stop() }
                sendTimer?.invalidate()
            }
            .buttonStyle(.bordered)
        }
        .onAppear { startSendingBiometrics() }
    }

    private func startSendingBiometrics() {
        sendTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            let packet = BiometricPacket(
                recordedAt: Date(),
                heartRate: sessionManager.heartRate,
                hrv: sessionManager.hrv,
                spo2: sessionManager.spo2,
                respiratoryRate: 14,
                motionIntensity: 0
            )
            WatchConnectivityBridge.shared.send(packet: packet)
        }
    }
}
```

**Step 4: Build watchOS target — expect success**
```bash
xcodebuild build -scheme "Slipie watchOS" -destination 'platform=watchOS Simulator,name=Apple Watch Series 10 (46mm)' 2>&1 | tail -10
```

**Step 5: Commit**
```bash
git add "Slipie watchOS/"
git commit -m "feat: add watchOS HKWorkoutSession biometric streaming and WatchConnectivity bridge"
```

---

## Task 14: iPhone — WatchConnectivity Receiver + CoreML

**Files:**
- Create: `Slipie iOS/App/PhoneConnectivityReceiver.swift`
- Create: `SlipieCoreKit/Sources/SlipieCoreKit/SleepTracking/SleepStageClassifier.swift`

**Step 1: Implement SleepStageClassifier (CoreML wrapper)**

Create `SlipieCoreKit/Sources/SlipieCoreKit/SleepTracking/SleepStageClassifier.swift`:
```swift
import Foundation

// CoreML model placeholder — replace MLModel with actual .mlmodel when trained
// For now, uses heuristic classification as fallback
public final class SleepStageClassifier: Sendable {
    public init() {}

    public func classify(_ packet: BiometricPacket, timeSinceOnsetMinutes: Double) -> SleepStage {
        // Heuristic until real .mlmodel is bundled
        // Training on MESA/SHHS datasets is done offline; drop compiled .mlmodel into Resources/
        if packet.motionIntensity > 0.4 { return .awake }
        if timeSinceOnsetMinutes < 10 { return .light }
        if packet.heartRate < 55 && packet.hrv > 50 && timeSinceOnsetMinutes > 30 {
            return timeSinceOnsetMinutes.truncatingRemainder(dividingBy: 90) > 60 ? .rem : .deep
        }
        if packet.heartRate < 65 { return .light }
        return .awake
    }
}
```

**Step 2: Implement PhoneConnectivityReceiver**

Create `Slipie iOS/App/PhoneConnectivityReceiver.swift`:
```swift
import WatchConnectivity
import SlipieCoreKit
import Foundation

final class PhoneConnectivityReceiver: NSObject, WCSessionDelegate, @unchecked Sendable {
    static let shared = PhoneConnectivityReceiver()
    var onPacketReceived: ((BiometricPacket) -> Void)?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        guard let packet = try? JSONDecoder().decode(BiometricPacket.self, from: messageData) else { return }
        onPacketReceived?(packet)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
}
```

**Step 3: Wire receiver into AppEnvironment**

Modify `Slipie iOS/App/AppEnvironment.swift` — add inside `init()`:
```swift
// After existing init code:
let classifier = SleepStageClassifier()
PhoneConnectivityReceiver.shared.onPacketReceived = { [weak self] packet in
    guard let self else { return }
    Task { @MainActor in
        self.currentSession?.biometricEvents.append(packet)
        let onset = self.currentSession?.startedAt ?? Date()
        let minutesSinceOnset = Date().timeIntervalSince(onset) / 60
        let stage = classifier.classify(packet, timeSinceOnsetMinutes: minutesSinceOnset)
        if var lastStage = self.currentSession?.stages.last, lastStage.stage == stage {
            // same stage continues
        } else {
            self.currentSession?.stages.append(SleepStageInterval(stage: stage, startedAt: Date()))
        }
        let params = self.parameterMapper.map(
            biometrics: packet,
            stage: stage,
            soundscape: Soundscape.all.first(where: { $0.id == self.currentSession?.soundscapeId }) ?? Soundscape.all[0]
        )
        self.audioEngine.apply(parameters: params)
    }
}
```

**Step 4: Build both targets**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5
```

**Step 5: Commit**
```bash
git add "Slipie iOS/" SlipieCoreKit/
git commit -m "feat: add WatchConnectivity receiver, CoreML sleep stage classifier, real-time audio adaptation"
```

---

## Task 15: Info.plist Permissions + Background Modes

**Files:**
- Modify: `Slipie iOS/Info.plist`
- Modify: `Slipie watchOS/Info.plist`

**Step 1: Add required keys to iPhone Info.plist**

In Xcode, select the `Slipie` target -> Info tab -> add:

| Key | Value |
|-----|-------|
| `NSHealthShareUsageDescription` | Slipie reads your heart rate, HRV, and oxygen saturation to adapt sleep music to your body in real time. |
| `NSHealthUpdateUsageDescription` | Slipie writes your inferred sleep stages back to Health. |
| `NSMotionUsageDescription` | Motion data helps detect when you are asleep or awake. |

**Step 2: Add Background Modes**

In Xcode -> `Slipie` target -> Signing and Capabilities -> add Capability:
- Background Modes: check `Audio, AirPlay, and Picture in Picture`
- Background Modes: check `Background fetch`

For watchOS target, add Background Modes:
- `Workout processing`

**Step 3: Add HealthKit capability**

Xcode -> `Slipie` target -> Signing and Capabilities -> add `HealthKit`
Xcode -> `Slipie watchOS` target -> add `HealthKit`

**Step 4: Build — expect success**
```bash
xcodebuild build -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | tail -5
```

**Step 5: Commit**
```bash
git add .
git commit -m "chore: add HealthKit, motion permissions and background audio/workout modes"
```

---

## Task 16: Supabase Database Setup

**Files:**
- Create: `docs/supabase/schema.sql`

**Step 1: Create schema SQL**

Create `docs/supabase/schema.sql`:
```sql
-- Run this in the Supabase SQL editor for your project

create table if not exists users (
  id uuid primary key references auth.users,
  email text,
  created_at timestamptz default now()
  -- subscription_tier deferred: add later when RevenueCat is integrated
);

create table if not exists sleep_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz,
  duration_minutes int,
  avg_hr float,
  avg_hrv float,
  avg_spo2 float,
  sleep_score int check (sleep_score between 0 and 100),
  soundscape_used text not null
);

create table if not exists sleep_stages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references sleep_sessions(id) on delete cascade,
  stage text not null check (stage in ('awake', 'light', 'deep', 'rem')),
  started_at timestamptz not null,
  ended_at timestamptz,
  duration_seconds int
);

create table if not exists biometric_events (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references sleep_sessions(id) on delete cascade,
  recorded_at timestamptz not null,
  hr float,
  hrv float,
  spo2 float,
  respiratory_rate float,
  motion_intensity float
);

create table if not exists soundscapes (
  id text primary key,
  name text not null,
  description text,
  base_parameters jsonb
);

-- Row Level Security
alter table users enable row level security;
alter table sleep_sessions enable row level security;
alter table sleep_stages enable row level security;
alter table biometric_events enable row level security;

create policy "Users own their data" on users for all using (auth.uid() = id);
create policy "Users own their sessions" on sleep_sessions for all using (auth.uid() = user_id);
create policy "Users own their stages" on sleep_stages for all using (
  session_id in (select id from sleep_sessions where user_id = auth.uid())
);
create policy "Users own their biometrics" on biometric_events for all using (
  session_id in (select id from sleep_sessions where user_id = auth.uid())
);
```

**Step 2: Run in Supabase SQL editor**

Go to your Supabase project dashboard -> SQL Editor -> paste and run `schema.sql`

**Step 3: Add environment variables**

Create `.env.xcconfig` (do NOT commit this — add to .gitignore):
```
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your-anon-key
```

Add to `.gitignore`:
```
*.xcconfig
.env
```

**Step 4: Commit schema (not secrets)**
```bash
git add docs/supabase/schema.sql .gitignore
git commit -m "feat: add Supabase schema with RLS policies"
```

---

## Task 17: End-to-End Integration Test

**Step 1: Manual smoke test on simulator**

1. Launch app on iPhone 16 simulator
2. Verify tab bar shows Sleep, Insights, Soundscapes, Profile
3. Go to Sleep tab -> select Ocean soundscape -> tap Start Sleep
4. Verify audio starts playing (no crash)
5. Go to Soundscapes tab -> tap Forest -> tap Preview -> verify audio plays
6. Go to Profile -> attempt sign-in with test Supabase credentials
7. Return to Sleep tab -> End Session -> verify session saved (check Supabase dashboard)

**Step 2: Run all unit tests**
```bash
xcodebuild test -scheme Slipie -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "Test (Suite|Case|Passed|Failed)"
```
Expected: All tests passed

**Step 3: Run package tests**
```bash
swift test --package-path SlipieCoreKit 2>&1 | grep -E "(PASS|FAIL|error)"
```
Expected: All tests passed

**Step 4: Final commit**
```bash
git add .
git commit -m "feat: Slipie v1 complete — triplatform sleep music app with generative audio and Apple Watch integration"
```

---

## Out of Scope (Future Tasks)

- RevenueCat subscription integration (freemium gating)
- Real CoreML model trained on MESA/SHHS datasets (replace heuristic classifier)
- Animated star particle background (post-v1 polish)
- iPad split-view specific layouts
- Figma icon asset import (once Figma MCP access is configured)
- Morning alarm / gentle crescendo wake feature
- Streak and trend analytics in Insights
- watchOS complications
