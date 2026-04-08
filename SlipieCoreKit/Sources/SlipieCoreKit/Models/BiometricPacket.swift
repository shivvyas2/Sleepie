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
