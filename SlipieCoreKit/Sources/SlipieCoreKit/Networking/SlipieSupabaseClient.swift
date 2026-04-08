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

    public var currentUser: User? { client.auth.currentUser }

    public func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    public func signOut() async throws {
        try await client.auth.signOut()
    }

    public func saveSleepSession(_ session: SleepSession) async throws {
        let row = SleepSessionRow(from: session)
        try await client.from("sleep_sessions").insert(row).execute()
    }

    public func fetchSleepSessions(limit: Int = 30) async throws -> [SleepSessionRow] {
        try await client
            .from("sleep_sessions")
            .select()
            .order("started_at", ascending: false)
            .limit(limit)
            .execute()
            .value
    }

    public func saveBiometricEvents(_ events: [BiometricPacket], sessionId: UUID) async throws {
        let rows = events.map { BiometricEventRow(from: $0, sessionId: sessionId) }
        try await client.from("biometric_events").insert(rows).execute()
    }
}

public struct SleepSessionRow: Codable, Sendable {
    public let id: UUID
    public let userId: UUID
    public let startedAt: Date
    public let endedAt: Date?
    public let sleepScore: Int?
    public let soundscapeUsed: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case sleepScore = "sleep_score"
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
        case id
        case sessionId = "session_id"
        case recordedAt = "recorded_at"
        case hr, hrv, spo2
        case respiratoryRate = "respiratory_rate"
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
