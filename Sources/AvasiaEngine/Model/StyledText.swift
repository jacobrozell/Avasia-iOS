import Foundation

/// A single line of game output with a semantic style. The original used ANSI
/// color codes; here we use semantic styles the UI maps to colors/fonts
/// (see ENGINE_SPEC §B.7).
public struct StyledLine: Equatable, Codable, Sendable {
    public enum Style: String, Codable, Sendable {
        case body       // default narration
        case speech     // NPC dialogue (original wrapped these in quotes)
        case item       // green — item/spell acquired
        case death      // red — you have died
        case symbol     // amber monospace — puzzle glyphs
        case title      // cyan — headings
        case hint       // muted — prompts/options
    }

    public let text: String
    public let style: Style

    public init(_ text: String, _ style: Style = .body) {
        self.text = text
        self.style = style
    }
}

public extension StyledLine {
    static func body(_ t: String) -> StyledLine { .init(t, .body) }
    static func speech(_ t: String) -> StyledLine { .init(t, .speech) }
    static func item(_ t: String) -> StyledLine { .init(t, .item) }
    static func death(_ t: String) -> StyledLine { .init(t, .death) }
    static func symbol(_ t: String) -> StyledLine { .init(t, .symbol) }
    static func title(_ t: String) -> StyledLine { .init(t, .title) }
    static func hint(_ t: String) -> StyledLine { .init(t, .hint) }
    /// A blank spacer line.
    static var blank: StyledLine { .init("", .body) }
}
