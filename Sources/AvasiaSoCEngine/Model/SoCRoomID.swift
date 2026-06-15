import Foundation
import AvasiaEngine

/// Every location in *Avasia: Sword of Courage*. IDs match the Python prototype
/// (`Avasia-SoC/`) `config.current_room_id` strings.
public enum SoCRoomID: String, Codable, CaseIterable, Sendable {
    case cataractaHousing = "Cataracta_Housing"
    case cataractaNorth = "Cataracta_North"
    case cataractaShopping = "Cataracta_Shopping"
    case cataractaHunterPath = "Cataracta_Hunter_Path"
    case cataractaBarracks = "Cataracta_Barracks"
    case cataractaAthalos = "Cataracta_Athalos"
    case cataractaBlacksmith = "Cataracta_Blacksmith"
    case cataractaPier = "Cataracta_Pier"
    case cataractaFishing = "Cataracta_Fishing"
    case cataractaGarden = "Cataracta_Garden"
    case cataractaCourtyard = "Cataracta_Courtyard"
    case portalRoom = "c_portal_room"
    case library = "n_library"
    case westHallway = "west_hallway"
    case throneRoom = "throne_room"
    case aylovaWarCamp = "aylova_war_camp"
    case northernMarch = "northern_march"
    case oceandaleFront = "oceandale_front"
    case mageOutpost = "mage_outpost"
    case vashirrStand = "vashirr_stand"
    case ageEpilogue = "soc_epilogue"
    case cataractaRuins = "cataracta_ruins"
}

public extension SoCRoomID {
    var region: Region {
        switch self {
        case .portalRoom, .library, .westHallway, .throneRoom:
            return .nacastrum
        case .aylovaWarCamp, .northernMarch:
            return .aylova
        case .oceandaleFront:
            return .oceandale
        case .mageOutpost:
            return .mountain
        case .vashirrStand:
            return .shore
        case .ageEpilogue:
            return .aylova
        case .cataractaRuins:
            return .cataracta
        default:
            return .cataracta
        }
    }
}
