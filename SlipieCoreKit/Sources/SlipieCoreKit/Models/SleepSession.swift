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
