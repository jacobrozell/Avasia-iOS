import Foundation

/// Every location/screen in the game. In the original each was a function;
/// here each maps to a `RoomScript` registered in `World`. Rooms not yet
/// implemented route to `.stub` (see `World`).
public enum RoomID: String, Codable, CaseIterable, Sendable {
    // Oceandale region
    case oceandale
    case beach
    case tradingPost
    case magehouse
    case graveyard
    case church

    // Central hub
    case splitpath

    // Mountain & cave (east)
    case bridge
    case mountain
    case druidTalk          // Dentros
    case westMountain
    case druidPath          // Cataracta gate
    case caveEntrance
    case mainCave
    case northCave
    case fireballRoom
    case eastCave
    case westCave
    case northwestCave
    case northeastCave

    // Forest & tree (north)
    case forestEntrance
    case forestTrap
    case silvarium
    case treeFloor1
    case treeFloor2
    case treeButcher
    case treeArmory
    case treeFloor3
    case treeChurch
    case treeLibrary
    case treeFloor4

    // Western road (west)
    case westernRoad
    case shoreside
    case beachHut
    case roadToNacastrum
    case teleporter

    // Endgame
    case nacastrum
    case aylova
    case ending

    /// Placeholder for not-yet-implemented destinations so the skeleton runs.
    case stub
}
