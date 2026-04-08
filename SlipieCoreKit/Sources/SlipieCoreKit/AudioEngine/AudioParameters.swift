import Foundation

public struct AudioParameters: Sendable {
    public var volume: Double
    public var tempo: Double
    public var filterCutoffNormalized: Double
    public var reverbWetness: Double
    public var oscillatorMix: Double
    public var pitchShift: Double

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
