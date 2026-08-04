import SwiftUI

enum AppTypography {
    static func serifTitle(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .serif)
    }

    static func serifHeadline(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold, design: .serif)
    }

    static func monoStat(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .monospaced)
    }
}
