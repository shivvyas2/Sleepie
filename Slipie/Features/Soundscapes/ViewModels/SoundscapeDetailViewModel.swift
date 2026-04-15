import SwiftUI
import SlipieCoreKit

@MainActor
final class SoundscapeDetailViewModel: ObservableObject {
    @Published var isPreviewing = false

    func togglePreview(soundscape: Soundscape, audioEngine: SleepAudioEngine) {
        if isPreviewing {
            audioEngine.stop()
        } else {
            try? audioEngine.start(soundscape: soundscape)
        }
        isPreviewing.toggle()
    }

    func stopPreviewIfNeeded(audioEngine: SleepAudioEngine) {
        if isPreviewing {
            audioEngine.stop()
            isPreviewing = false
        }
    }
}
