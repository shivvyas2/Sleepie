import Foundation

public final class SleepStageClassifier: Sendable {
    public init() {}

    public func classify(_ packet: BiometricPacket, timeSinceOnsetMinutes: Double) -> SleepStage {
        if packet.motionIntensity > 0.4 { return .awake }
        if timeSinceOnsetMinutes < 10 { return .light }
        if packet.heartRate < 55 && packet.hrv > 50 && timeSinceOnsetMinutes > 30 {
            let cyclePosition = timeSinceOnsetMinutes.truncatingRemainder(dividingBy: 90)
            return cyclePosition > 60 ? .rem : .deep
        }
        if packet.heartRate < 65 { return .light }
        return .awake
    }
}
