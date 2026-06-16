import Foundation

/// Splitpath — the central overworld hub. In escort mode only WEST is valid.
struct SplitpathRoom: RoomScript {
    let id: RoomID = .splitpath

    func describe(_ state: GameState) -> [StyledLine] {
        if state.escortActive {
            return [
                .body("You stand at the Splitpath with the Old Mage at your side."),
                .body("To the WEST, the road runs on toward Nacastrum."),
                .hint("Lead her WEST.")
            ]
        }
        return [
            .body("The road forks into a wide crossing — the Splitpath."),
            .body("To the NORTH, a dark forest. To the EAST, a mountain bridge. To the WEST, a long road. To the SOUTH, the city."),
            .hint("Which way? (NORTH, EAST, WEST, SOUTH) — or LOOK at the crossing.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if !state.escortActive,
           input.contains(["LOOK", "EXAMINE", "CROSSING", "ROADS"]) {
            return TurnResult([
                .body("Four roads, four anchors of empire — forest, mountain, sky-road, and the sea behind you."),
                .body("Someday men will chart these paths on paper and charge tolls in blue crystal. Today you walk them barefoot in grief.")
            ])
        }
        if input.contains(Verb.west) { return TurnResult([], .move(.westernRoad)) }
        if state.escortActive { return TurnResult([.hint("Lead her WEST toward Nacastrum.")]) }
        if input.contains(Verb.north) { return TurnResult([], .move(.forestEntrance)) }
        if input.contains(Verb.east) { return TurnResult([], .move(.bridge)) }
        if input.contains(Verb.south) { return TurnResult([], .move(.graveyard)) }
        return TurnResult([.hint("You can go NORTH, EAST, WEST, or SOUTH.")])
    }
}

/// Bridge — the first hard spell gate: only Levitate crosses; jumping kills you.
/// Uses raw input mode like the original. Demonstrates a lethal puzzle.
struct BridgeRoom: RoomScript {
    let id: RoomID = .bridge
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A deep chasm splits the earth. The bridge across it has long since collapsed."),
            .body("Far below, white water roars between the rocks. The bridge is impassable."),
            .hint("What do you do?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["JUMP", "SWIM", "DIVE", "LEAP"]) {
            return TurnResult([.body("You jump in the water and then realize, halfway into the jump, that the chasm is VERY deep.")],
                              .death(.chasm))
        }
        if input.contains(Flag.levitate.castSynonyms) {
            guard state.has(.levitate) else {
                return TurnResult([.hint("You don't know that spell.")])
            }
            return TurnResult([
                .body("You rise from the broken ledge and drift across the chasm, robes snapping in the updraft."),
                .body("Your feet find solid stone on the far side.")
            ], .move(.mountain))
        }
        if input.contains(["SWORD"]) {
            return TurnResult([.hint("There are no trees long enough to bridge a gap like this.")])
        }
        if input.contains(["BACK", "WEST", "LEAVE", "RETURN"]) {
            return TurnResult([], .move(.splitpath))
        }
        return TurnResult([.hint("The chasm yawns before you. Perhaps there is another way across...")])
    }
}
