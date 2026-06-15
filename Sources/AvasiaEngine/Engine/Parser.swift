import Foundation

/// Reproduces the original's two input-handling behaviors (ENGINE_SPEC §B.4):
/// - `.normalized` (= `userinput`): uppercase, strip "USE"/"CAST"/spaces.
/// - `.raw` (= raw `input().upper()`): uppercase only.
/// Matching is substring-based (= `containsAny`).
public struct Parser {
    public enum Mode: Sendable { case normalized, raw }

    public static func parse(_ raw: String, mode: Mode) -> ParsedInput {
        let upper = raw.uppercased()
        let normalized: String
        switch mode {
        case .raw:
            normalized = upper
        case .normalized:
            normalized = upper
                .replacingOccurrences(of: "USE", with: "")
                .replacingOccurrences(of: "CAST", with: "")
                .replacingOccurrences(of: " ", with: "")
        }
        return ParsedInput(original: raw, normalized: normalized)
    }
}

/// A parsed command. `contains` is the substring matcher used for all dispatch.
public struct ParsedInput: Sendable, Equatable {
    public let original: String
    public let normalized: String

    public var isEmpty: Bool { normalized.isEmpty }

    /// True if any option appears as a (case-insensitive) substring — faithful
    /// to the original `containsAny`. Note: short options match broadly, so
    /// rooms should pass full-word lists where that matters.
    public func contains(_ options: [String]) -> Bool {
        for option in options where normalized.contains(option.uppercased()) {
            return true
        }
        return false
    }

    public func contains(_ option: String) -> Bool { contains([option]) }

    /// Exact-match helper for the raw-mode cave hub (`"NORTH"`/`"GO NORTH"`/`"N"`).
    public func equalsAny(_ options: [String]) -> Bool {
        options.contains { normalized == $0.uppercased() }
    }
}
