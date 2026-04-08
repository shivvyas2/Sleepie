import Foundation

public struct SlipieSupabaseConfig: Sendable {
    public let url: String
    public let anonKey: String

    public init(url: String, anonKey: String) {
        self.url = url
        self.anonKey = anonKey
    }
}
