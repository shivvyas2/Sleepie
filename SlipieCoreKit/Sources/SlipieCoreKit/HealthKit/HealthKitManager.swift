import HealthKit
import Foundation

public final class HealthKitManager: @unchecked Sendable {
    private let store = HKHealthStore()

    public var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    public init() {}

    private var readTypes: Set<HKObjectType> {
        var types = Set<HKObjectType>()
        let ids: [HKQuantityTypeIdentifier] = [.heartRate, .heartRateVariabilitySDNN, .oxygenSaturation, .respiratoryRate, .stepCount]
        for id in ids {
            if let t = HKQuantityType.quantityType(forIdentifier: id) { types.insert(t) }
        }
        if let t = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(t) }
        return types
    }

    private var writeTypes: Set<HKSampleType> {
        var types = Set<HKSampleType>()
        if let t = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(t) }
        return types
    }

    public func requestAuthorization() async throws {
        guard isAvailable else { throw HealthKitError.notAvailable }
        try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    public func fetchRecentSleepSamples(days: Int = 30) async throws -> [HKCategorySample] {
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
            self.store.execute(query)
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
