import Foundation

// The Western Road region (west of Splitpath) and the road-to-Nacastrum
// gauntlet. Progress through the gauntlet is driven by `state.roadProgress`
// (one integer, replacing the original's broken road flags — ENGINE_SPEC §A.4).
// See WORLD_MAP §6.

/// Western Road hub. In escort mode it funnels the Old Mage toward the platform.
struct WesternRoadRoom: RoomScript {
    let id: RoomID = .westernRoad

    func describe(_ state: GameState) -> [StyledLine] {
        if state.escortActive {
            return [
                .body("The Old Mage walks beside you, leaning on her blue-gemmed staff."),
                .body("To the NORTH, the road runs on toward the teleporter platform."),
                .hint("Lead her NORTH.")
            ]
        }
        return [
            .body("A long road runs west from the Splitpath."),
            .body("To the NORTH lies the road to Nacastrum. To the WEST, a quiet shore. To the EAST, the Splitpath."),
            .hint("Which way? (NORTH, WEST, EAST)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.north) { return TurnResult([], .move(state.escortActive ? .teleporter : .roadToNacastrum)) }
        if state.escortActive { return TurnResult([.hint("Lead her NORTH.")]) }
        if input.contains(Verb.west) { return TurnResult([], .move(.shoreside)) }
        if input.contains(Verb.east) || input.contains(Verb.back) { return TurnResult([], .move(.splitpath)) }
        return TurnResult([.hint("Go NORTH, WEST, or EAST.")])
    }
}

/// Shoreside — the beach hut (fishing rod) and fishing.
struct ShoresideRoom: RoomScript {
    let id: RoomID = .shoreside

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A calm shore. An abandoned hut leans against the dunes."),
            state.has(.rod)
                ? .hint("You could FISH, or go BACK.")
                : .hint("You could search the HUT, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["HUT", "SEARCH", "ENTER"]) { return TurnResult([], .move(.beachHut)) }
        if input.contains("FISH") {
            guard state.has(.rod) else { return TurnResult([.hint("You have nothing to fish with.")]) }
            return Fishing.cast(&state)
        }
        if input.contains(Verb.back) || input.contains(Verb.east) { return TurnResult([], .move(.westernRoad)) }
        return TurnResult([.hint("Search the HUT, FISH (with a rod), or go BACK.")])
    }
}

/// Beach hut — the fishing rod.
struct BeachHutRoom: RoomScript {
    let id: RoomID = .beachHut

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.rod) {
            return [.body("The hut is bare now. You've taken what was useful."), .hint("Go BACK.")]
        }
        return [
            .body("Inside the hut, dust and netting — and a fishing rod leaning by the door."),
            .hint("You could TAKE the rod, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if !state.has(.rod) && (input.contains(Verb.take) || input.contains(["ROD"])) {
            state.gain(.rod)
            return TurnResult([.item("You take the FISHING ROD.")], .move(.shoreside))
        }
        return TurnResult([], .move(.shoreside))
    }
}

/// The road to Nacastrum — a three-stage gauntlet keyed to `roadProgress`:
/// 0/1 = Agromanian ambush (only Inflame wins), 2 = stone spires (Stonebend),
/// 3 = dream bridge (swim/jump), 4 = platform reached.
struct RoadToNacastrumRoom: RoomScript {
    let id: RoomID = .roadToNacastrum
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: GameState) -> [StyledLine] {
        switch state.roadProgress {
        case 0, 1:
            return [
                .body("Agromanian raiders boil out of the brush, blades drawn, and surround you."),
                state.roadProgress == 1
                    ? .hint("They have you cornered. There is no running now.")
                    : .hint("What do you do?")
            ]
        case 2:
            return [
                .body("The road is blocked by a wall of jagged stone spires, far too tall to climb."),
                .hint("What do you do?")
            ]
        case 3:
            return [
                .body("The road ends at a chasm and a broken bridge — exactly like the one in the mountains."),
                .body("The world here feels thin, dreamlike, the wind unmoving."),
                .hint("What do you do?")
            ]
        default:
            if state.teleporterDiscovered && !state.escortActive {
                return [
                    .body("Beneath the floating city, the silver ring waits — but you cannot work it alone."),
                    .hint("Return for the Old Mage. Go BACK (south).")
                ]
            }
            return [.body("Beneath the floating city, a ring of silver waits."), .hint("Step onto the platform (NORTH), or go BACK.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        switch state.roadProgress {
        case 0, 1:
            return handleAmbush(input, &state)
        case 2:
            if input.contains(Flag.stonebend.castSynonyms) && state.has(.stonebend) {
                state.roadProgress = 3
                return TurnResult([.body("You wrench the spires aside like reeds. The road runs on.")])
            }
            if input.contains(Flag.fireball.castSynonyms) { return TurnResult([.hint("Fire washes over the stone to no effect.")]) }
            if input.contains(Flag.levitate.castSynonyms) { return TurnResult([.hint("They are far too tall to rise over.")]) }
            return TurnResult([.hint("Solid stone bars the way. Only the earth itself might move it.")])
        case 3:
            if input.contains(["SWIM", "JUMP", "DIVE", "LEAP"]) {
                state.roadProgress = 4
                return TurnResult([
                    .body("Against all sense, you throw yourself into the water — and the dream shatters."),
                    .body("You look up. Nacastrum hangs in the sky above you, and a Ring of Malkos gleams ahead.")
                ], .move(.teleporter))
            }
            if input.contains(Flag.levitate.castSynonyms) && state.has(.levitate) {
                return TurnResult([.hint("You drift across — but arrive back where you started, somehow unfinished.")])
            }
            if input.contains(["LOOK", "EXAMINE"]) {
                return TurnResult([.body("The water below is glassy and still. It does not behave like water at all.")])
            }
            return TurnResult([.hint("This place is not what it seems. What did the real bridge punish? Perhaps do the opposite.")])
        default:
            if input.contains(["BACK", "SOUTH", "RETURN", "LEAVE"]) {
                return TurnResult([], .move(.westernRoad))
            }
            return TurnResult([], .move(.teleporter))
        }
    }

    private func handleAmbush(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        // Inflame is the only winning move at any stage.
        if input.contains(Flag.fireball.castSynonyms) {
            guard state.has(.fireball) else { return TurnResult([.hint("You don't know that spell.")]) }
            state.roadProgress = 2
            return TurnResult([.body("You loose a roaring gout of flame. The raiders scatter, burning, into the brush.")])
        }
        if state.roadProgress == 0 {
            // First round: any other action merely corners you.
            state.roadProgress = 1
            if input.contains(["RUN", "FLEE", "ESCAPE", "BACK"]) {
                return TurnResult([.body("You bolt — but they herd you back against the spires. Cornered.")])
            }
            return TurnResult([.body("You lash out and drop one, but the rest close in and pin you. Cornered.")])
        }
        // Cornered: anything but Inflame is fatal.
        if input.contains(["SWORD"]) {
            return TurnResult([.body("You swing your sword; a raider lops your arm off at the shoulder.")],
                              .death(reason: "Cut down on the road, a blade for a blade."))
        }
        if input.contains(Flag.levitate.castSynonyms) {
            return TurnResult([.body("You rise — and a dozen hands drag you back down into the blades.")],
                              .death(reason: "Pulled from the air and finished on the ground."))
        }
        if input.contains(Flag.stonebend.castSynonyms) {
            return TurnResult([.hint("There's no rock here to pull from. The raiders laugh and close in.")],
                              .death(reason: "Out of options on the road."))
        }
        return TurnResult([.body("Whatever you try, it isn't enough. They cut you down.")],
                          .death(reason: "Overwhelmed by the Agromanian ambush. You needed fire."))
    }
}

/// The Ring of Malkos. First visit sends you back for the Old Mage; the escorted
/// return triggers the memory flashback into Nacastrum.
struct TeleporterRoom: RoomScript {
    let id: RoomID = .teleporter

    func describe(_ state: GameState) -> [StyledLine] {
        if state.escortActive {
            return [
                .body("The Old Mage steps onto the ring and plants her staff. The blue gem flares."),
                .speech("Hold on to something only you remember. This will hurt."),
                .hint("Step through. (CONTINUE)")
            ]
        }
        if state.teleporterDiscovered {
            return [
                .body("The silver ring hums, but you cannot work it alone."),
                .hint("Return to the Old Mage. (Go BACK.)")
            ]
        }
        return [
            .body("A teleporter platform — a Ring of Malkos — rests in the floating city's shadow."),
            .body("You step onto it and feel its power, but it will not answer to you alone."),
            .hint("Examine it. (CONTINUE)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if state.escortActive {
            return TurnResult([
                .body("You step through the ring — and your whole life floods back at once."),
                .body("Taken from your parents at eight. Crowned Vashirr at thirteen. The Academy. Your students."),
                .body("And the last night: the blinding light, the courtyard, the portal taking the women and children."),
                .body("Your mother, dragged toward it. Your father breaking free to reach her — and Vashirr's magic striking him dead."),
                .body("Then the scattering. Then the beach."),
                .speech("Take as long as you need. We will move on when you are ready.")
            ], .move(.nacastrum))
        }
        if state.teleporterDiscovered {
            return TurnResult([], .move(.roadToNacastrum))
        }
        // First discovery: unlock the return trip for the staff.
        state.teleporterDiscovered = true
        state.magehouseLocked = false
        return TurnResult([
            .body("You'll need help to make this work — and you know who has it."),
            .speech("(You should return to the Old Mage in Oceandale.)")
        ], .move(.roadToNacastrum))
    }
}
