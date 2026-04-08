import AVFoundation
import Foundation

public final class SleepAudioEngine: @unchecked Sendable {
    private let engine = AVAudioEngine()
    private let noiseNode = AVAudioPlayerNode()
    private let reverb = AVAudioUnitReverb()
    private let lowPassFilter = AVAudioUnitEQ(numberOfBands: 1)
    private let delay = AVAudioUnitDelay()

    private(set) public var isRunning = false
    private var pinkState: (Double, Double, Double, Double, Double, Double, Double) = (0,0,0,0,0,0,0)

    public init() {
        setupSignalChain()
    }

    private func setupSignalChain() {
        engine.attach(noiseNode)
        engine.attach(reverb)
        engine.attach(lowPassFilter)
        engine.attach(delay)

        lowPassFilter.bands[0].filterType = .lowPass
        lowPassFilter.bands[0].frequency = 4000
        lowPassFilter.bands[0].bandwidth = 0.5
        lowPassFilter.bands[0].bypass = false

        reverb.loadFactoryPreset(.largeChamber)
        reverb.wetDryMix = 40

        delay.delayTime = 0.3
        delay.feedback = 20
        delay.wetDryMix = 15

        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        engine.connect(noiseNode, to: reverb, format: format)
        engine.connect(reverb, to: lowPassFilter, format: format)
        engine.connect(lowPassFilter, to: delay, format: format)
        engine.connect(delay, to: engine.mainMixerNode, format: format)
    }

    public func start(soundscape: Soundscape) throws {
        guard !isRunning else { return }
        try engine.start()
        noiseNode.play()
        scheduleNoiseBuffer(soundscape: soundscape)
        isRunning = true
    }

    public func apply(parameters: AudioParameters) {
        engine.mainMixerNode.outputVolume = Float(parameters.volume)
        reverb.wetDryMix = Float(parameters.reverbWetness * 100)
        lowPassFilter.bands[0].frequency = Float(200 + parameters.filterCutoffNormalized * 7800)
    }

    public func stop() {
        noiseNode.stop()
        if engine.isRunning { engine.stop() }
        isRunning = false
    }

    private func scheduleNoiseBuffer(soundscape: Soundscape) {
        let sampleRate = 44100.0
        let bufferSize = AVAudioFrameCount(sampleRate * 2)
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize) else { return }
        buffer.frameLength = bufferSize
        if let left = buffer.floatChannelData?[0], let right = buffer.floatChannelData?[1] {
            for i in 0..<Int(bufferSize) {
                let sample = generateNoiseSample(color: soundscape.baseParameters.noiseColor)
                left[i] = sample
                right[i] = sample
            }
        }
        noiseNode.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    private func generateNoiseSample(color: NoiseColor) -> Float {
        switch color {
        case .white:
            return Float.random(in: -0.15...0.15)
        case .pink:
            let white = Double.random(in: -1...1)
            pinkState.0 = 0.99886 * pinkState.0 + white * 0.0555179
            pinkState.1 = 0.99332 * pinkState.1 + white * 0.0750759
            pinkState.2 = 0.96900 * pinkState.2 + white * 0.1538520
            pinkState.3 = 0.86650 * pinkState.3 + white * 0.3104856
            pinkState.4 = 0.55000 * pinkState.4 + white * 0.5329522
            pinkState.5 = -0.7616 * pinkState.5 - white * 0.0168980
            let pink = (pinkState.0 + pinkState.1 + pinkState.2 + pinkState.3 + pinkState.4 + pinkState.5 + pinkState.6 + white * 0.5362) * 0.11
            pinkState.6 = white * 0.115926
            return Float(pink) * 0.2
        case .brown:
            let white = Double.random(in: -1...1)
            pinkState.0 = (pinkState.0 + 0.02 * white) / 1.02
            return Float(pinkState.0) * 3.5
        }
    }

    deinit { stop() }
}
