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

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let types: Set<HKSampleType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.heartRateVariabilitySDNN),
            HKQuantityType(.oxygenSaturation),
            HKQuantityType(.respiratoryRate)
        ]
        try? await store.requestAuthorization(toShare: [], read: types)
    }

    func start() async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = .mindAndBody
        config.locationType = .indoor

        let newSession = try HKWorkoutSession(healthStore: store, configuration: config)
        let newBuilder = newSession.associatedWorkoutBuilder()
        newBuilder.dataSource = HKLiveWorkoutDataSource(healthStore: store, workoutConfiguration: config)

        self.session = newSession
        self.builder = newBuilder

        newSession.delegate = self
        newBuilder.delegate = self

        newSession.startActivity(with: Date())
        try await newBuilder.beginCollection(at: Date())
        isActive = true
    }

    func stop() async {
        session?.end()
        try? await builder?.endCollection(at: Date())
        try? await builder?.finishWorkout()
        isActive = false
    }

    func updateFromStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType(.heartRate):
            let unit = HKUnit.count().unitDivided(by: .minute())
            heartRate = statistics.mostRecentQuantity()?.doubleValue(for: unit) ?? heartRate
        case HKQuantityType(.heartRateVariabilitySDNN):
            hrv = statistics.mostRecentQuantity()?.doubleValue(for: .secondUnit(with: .milli)) ?? hrv
        case HKQuantityType(.oxygenSaturation):
            let raw = statistics.mostRecentQuantity()?.doubleValue(for: .percent()) ?? (spo2 / 100)
            spo2 = raw * 100
        default:
            break
        }
    }
}

extension WatchSessionManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {}

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {}
}

extension WatchSessionManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  let stats = workoutBuilder.statistics(for: quantityType) else { continue }
            Task { @MainActor in self.updateFromStatistics(stats) }
        }
    }
}
