import Foundation

/// Which game in the saga the player selected from the home screen.
public enum AvasiaProduct: String, Codable, Sendable, CaseIterable {
    case kon = "kon"
    case soc = "soc"
    case stories = "stories"

    public var menuTitle: String {
        switch self {
        case .kon: return "King of Nacastrum"
        case .soc: return "Blade of Courage"
        case .stories: return "Short Stories"
        }
    }

    public var subtitle: String {
        switch self {
        case .kon: return "The amnesiac mage. Restore Nacastrum."
        case .soc: return "A druid's war. Win the Blade, win the coalition."
        case .stories: return "Parallel tales. Choose sides — or refuse both."
        }
    }

    public var saveDirectoryName: String {
        switch self {
        case .kon: return "AvasiaKoN"
        case .soc: return "AvasiaSoC"
        case .stories: return "AvasiaStories"
        }
    }
}
