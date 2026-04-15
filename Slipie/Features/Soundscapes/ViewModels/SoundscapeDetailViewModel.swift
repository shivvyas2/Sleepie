import SwiftUI
import SlipieCoreKit

@MainActor
final class SoundscapeDetailViewModel: ObservableObject {
    @Published var isPreviewing = false

    func togglePreview(soundscape: Soundscape, audioService: AudioService) {
        if isPreviewing {
            audioService.stopPreview()
        } else {
            try? audioService.preview(soundscape: soundscape)
        }
        isPreviewing.toggle()
    }

    func stopPreviewIfNeeded(audioService: AudioService) {
        if isPreviewing {
            audioService.stopPreview()
            isPreviewing = false
        }
    }
}
