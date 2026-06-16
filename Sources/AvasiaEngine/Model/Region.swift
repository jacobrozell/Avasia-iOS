import Foundation

/// A visual/audio region. Many rooms share a region so art and ambient audio can
/// be authored per-region rather than per-room (see WIREFRAMES.md "art / asset
/// direction"). The UI keys backgrounds, header illustrations, and ambient
/// loops off this.
public enum Region: String, Codable, CaseIterable, Sendable {
    case oceandale     // ruined seaside town
    case beach         // the southern shore
    case graveyard     // upper town / body-pile
    case splitpath     // overworld crossroads
    case mountain      // ridge, bridge, druids
    case cave          // pink-crystal cavern
    case forest        // approach to Silvarium
    case tree          // inside the great tree
    case road          // western road & gauntlet
    case shore         // western shoreside
    case nacastrum     // the floating city
    case aylova        // capital of Kaefden / endgame
    case cataracta     // Blade of Courage — druid city

    /// Regions reachable in King of Nacastrum (excludes sequel-only areas).
    public static var konPlayable: Set<Region> {
        Set(allCases.filter { $0 != .cataracta })
    }

    /// Human-readable name for any UI label.
    public var title: String {
        switch self {
        case .oceandale: return "Oceandale"
        case .beach:     return "The Shore"
        case .graveyard: return "Oceandale Outskirts"
        case .splitpath: return "The Splitpath"
        case .mountain:  return "The Mountains"
        case .cave:      return "The Crystal Cave"
        case .forest:    return "The Forest"
        case .tree:      return "Silvarium"
        case .road:      return "The Western Road"
        case .shore:     return "Shoreside"
        case .nacastrum: return "Nacastrum"
        case .aylova:    return "Aylova"
        case .cataracta: return "Cataracta"
        }
    }
}

public extension RoomID {
    /// Which region this room belongs to (drives art/audio).
    var region: Region {
        switch self {
        case .oceandale, .magehouse, .tradingPost, .church: return .oceandale
        case .beach: return .beach
        case .graveyard: return .graveyard
        case .splitpath: return .splitpath
        case .bridge, .mountain, .druidTalk, .westMountain, .druidPath: return .mountain
        case .caveEntrance, .mainCave, .northCave, .fireballRoom,
             .eastCave, .westCave, .northwestCave, .northeastCave: return .cave
        case .forestEntrance, .forestTrap, .silvarium: return .forest
        case .treeFloor1, .treeFloor2, .treeButcher, .treeArmory,
             .treeFloor3, .treeChurch, .treeLibrary, .treeFloor4: return .tree
        case .westernRoad, .roadToNacastrum, .teleporter: return .road
        case .shoreside, .beachHut: return .shore
        case .nacastrum: return .nacastrum
        case .aylova, .ending: return .aylova
        case .stub: return .oceandale
        }
    }
}
