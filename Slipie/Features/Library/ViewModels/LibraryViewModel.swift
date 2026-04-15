import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published var selectedFilter = "All"
}
