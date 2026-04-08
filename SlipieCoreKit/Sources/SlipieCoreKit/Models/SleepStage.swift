import Foundation

public enum SleepStage: String, Codable, CaseIterable, Sendable {
    case awake
    case light
    case deep
    case rem
}
