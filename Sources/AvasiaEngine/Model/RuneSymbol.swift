import Foundation

/// The four runes of the cave fireball puzzle. In the original the glyphs are
/// `^'`, `~'`, `>'`, `;'` and the *order* is shuffled per game, while the
/// glyph→digit legend (`^=1, ~=2, >=3, ;=4`) is fixed. Reproduce both exactly
/// or the puzzle becomes unsolvable. See ENGINE_SPEC §A.5 puzzle D.
public enum RuneSymbol: String, Codable, CaseIterable, Sendable {
    case caret = "^'"   // 1
    case tilde = "~'"   // 2
    case gt    = ">'"   // 3
    case semi  = ";'"   // 4

    /// Fixed legend digit for this glyph.
    public var digit: Int {
        switch self {
        case .caret: return 1
        case .tilde: return 2
        case .gt:    return 3
        case .semi:  return 4
        }
    }

    /// The glyph as shown to the player.
    public var glyph: String { rawValue }

    /// A freshly shuffled sequence of all four runes (the per-game answer order).
    public static func shuffled<G: RandomNumberGenerator>(using gen: inout G) -> [RuneSymbol] {
        allCases.shuffled(using: &gen)
    }

    /// The correct digit-string answer for a given shuffled sequence — the
    /// player reads the four revealed glyphs in slot order and converts each via
    /// the fixed legend. Equivalent to the original `decodesymbols`.
    public static func decode(_ sequence: [RuneSymbol]) -> String {
        sequence.map { String($0.digit) }.joined()
    }
}
