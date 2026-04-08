import SwiftUI

enum SlipieTypography {
    static func largeTitle() -> Font { .system(.largeTitle, design: .rounded, weight: .bold) }
    static func title() -> Font { .system(.title, design: .rounded, weight: .semibold) }
    static func title2() -> Font { .system(.title2, design: .rounded, weight: .semibold) }
    static func headline() -> Font { .system(.headline, design: .rounded, weight: .medium) }
    static func body() -> Font { .system(.body, design: .rounded) }
    static func caption() -> Font { .system(.caption, design: .rounded) }
    static func caption2() -> Font { .system(.caption2, design: .rounded) }
}
