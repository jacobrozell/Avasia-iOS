import Foundation

/// Which game in the saga the player selected from the home screen.
public enum AvasiaProduct: String, Codable, Sendable, CaseIterable {
    case kon = "kon"
    case soc = "soc"

    public var menuTitle: String {
        switch self {
        case .kon: return "King of Nacastrum"
        case .soc: return "Sword of Courage"
        }
    }

    public var subtitle: String {
        switch self {
        case .kon: return "The amnesiac mage. Restore Nacastrum."
        case .soc: return "A druid's war. You crowned Kaefden in game one."
        }
    }

    public var saveDirectoryName: String {
        switch self {
        case .kon: return "AvasiaKoN"
        case .soc: return "AvasiaSoC"
        }
    }
}
