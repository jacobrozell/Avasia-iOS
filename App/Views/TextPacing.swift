import Foundation
import AvasiaEngine

/// Typewriter timing for the game transcript.
enum TextPacing {
    /// Pause after a line finishes typing (TextDelay.on).
    static let blankLineDelaySeconds: Double = 0.35

    static func characterDelay(for style: StyledLine.Style) -> Double {
        let base: Double
        switch style {
        case .hint: base = 0.014
        case .title: base = 0.030
        case .symbol: base = 0.018
        case .item, .death: base = 0.022
        default: base = 0.024
        }
        return base * AppSettings.typewriterSpeed.delayMultiplier
    }

    static var interLineDelaySeconds: Double {
        0.75 * AppSettings.typewriterSpeed.delayMultiplier
    }
}

struct TranscriptDisplayLine: Identifiable, Equatable {
    let id: Int
    let line: StyledLine
    /// When set, only this many characters of `line.text` are shown.
    let partialLength: Int?
    let showsCursor: Bool

    init(id: Int, line: StyledLine, partialLength: Int?, showsCursor: Bool = false) {
        self.id = id
        self.line = line
        self.partialLength = partialLength
        self.showsCursor = showsCursor
    }
}
