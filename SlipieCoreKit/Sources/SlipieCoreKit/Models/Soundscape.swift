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
        Soundscape(id: "rain", name: "Rain", description: "Gentle rainfall on glass",
            baseParameters: SoundscapeParameters(noiseColor: .pink, baseFrequency: 80, reverbPreset: 4, oscillatorMix: 0.3)),
        Soundscape(id: "ocean", name: "Ocean", description: "Deep ocean waves",
            baseParameters: SoundscapeParameters(noiseColor: .brown, baseFrequency: 60, reverbPreset: 6, oscillatorMix: 0.4)),
        Soundscape(id: "white_noise", name: "White Noise", description: "Pure white noise for focus and sleep",
            baseParameters: SoundscapeParameters(noiseColor: .white, baseFrequency: 100, reverbPreset: 2, oscillatorMix: 0.1)),
        Soundscape(id: "forest", name: "Forest", description: "Night forest with gentle wind",
            baseParameters: SoundscapeParameters(noiseColor: .pink, baseFrequency: 110, reverbPreset: 5, oscillatorMix: 0.5)),
        Soundscape(id: "space", name: "Space", description: "Vast cosmic ambience",
            baseParameters: SoundscapeParameters(noiseColor: .brown, baseFrequency: 40, reverbPreset: 8, oscillatorMix: 0.7)),
        Soundscape(id: "arctic", name: "Arctic Wind", description: "Cold wind across frozen tundra",
            baseParameters: SoundscapeParameters(noiseColor: .white, baseFrequency: 90, reverbPreset: 7, oscillatorMix: 0.2)),
        Soundscape(id: "cave", name: "Cave", description: "Deep cave resonance and dripping water",
            baseParameters: SoundscapeParameters(noiseColor: .brown, baseFrequency: 55, reverbPreset: 9, oscillatorMix: 0.6)),
        Soundscape(id: "desert_night", name: "Desert Night", description: "Warm desert stillness under stars",
            baseParameters: SoundscapeParameters(noiseColor: .pink, baseFrequency: 70, reverbPreset: 3, oscillatorMix: 0.35))
    ]
}
