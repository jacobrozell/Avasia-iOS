import Foundation
import AvasiaEngine

// Linking rooms — descriptions verbatim from `Avasia-SoC/Cataracta/*.py`.

struct SoCCataractaHousing: SoCRoomScript {
    let id: SoCRoomID = .cataractaHousing

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Southwest Cataracta"),
            .body("You feel the wind on your face and smell the familiar scent of the Cataractan air."),
            .body("To the NORTH, a large, ornate wooden bridge leads across the beautiful Varatho river to the upper part of the town."),
            .body("To the WEST, is the Hunter's Path."),
            .body("To the EAST, is the shopping district of Cataracta."),
            .hint("OBJECTIVES lists optional errands before the courtyard."),
            .hint("Which way would you like to investigate?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.courtyardComplete {
            return SoCTurnResult([.body("Your home is gone.")], .stay)
        }
        if input.contains(Verb.look) || input.contains("SEARCH") {
            return SoCTurnResult(SoCCataractaFlavor.housingLookLines(state))
        }
        if input.contains(Verb.north) {
            let lines = SoCCataractaFlavor.varathoCrossingLines(&state)
            return SoCTurnResult(lines, .move(.cataractaNorth))
        }
        if input.contains(Verb.west) { return SoCTurnResult([], .move(.cataractaHunterPath)) }
        if input.contains(Verb.east) { return SoCTurnResult([], .move(.cataractaShopping)) }
        return SoCTurnResult([.hint("You can go NORTH, WEST, or EAST.")])
    }
}

struct SoCCataractaNorth: SoCRoomScript {
    let id: SoCRoomID = .cataractaNorth

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if !state.courtyardComplete {
            return [
                .title("Northern Cataracta"),
                .body("To the EAST is the Cataractan Legion courtyard, where you will begin your training."),
                .body("To the NORTH is the castle garden."),
                .body("To the SOUTH, a large, ornate wooden bridge that leads across the beautiful Varatho River to the housing district."),
                .body("To the WEST is a barracks used to house Cataracta's guards."),
                .hint("Which way would you like to investigate?")
            ]
        }
        return [
            .title("Northern Cataracta"),
            .body("The district is silent. Ash drifts on the wind."),
            .hint("There is nothing left here.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.courtyardComplete {
            return SoCTurnResult([.body("Cataracta is in ashes.")], .move(.cataractaHousing))
        }
        if input.contains(Verb.look) || input.contains("SEARCH") {
            return SoCTurnResult(SoCCataractaFlavor.northLookLines())
        }
        if input.contains(Verb.south) {
            let lines = SoCCataractaFlavor.varathoCrossingLines(&state)
            return SoCTurnResult(lines, .move(.cataractaHousing))
        }
        if input.contains(Verb.north) { return SoCTurnResult([], .move(.cataractaGarden)) }
        if input.contains(Verb.east) { return SoCTurnResult([], .move(.cataractaCourtyard)) }
        if input.contains(Verb.west) { return SoCTurnResult([], .move(.cataractaBarracks)) }
        return SoCTurnResult([.hint("You can go EAST, NORTH, SOUTH, or WEST.")])
    }
}

struct SoCCataractaShopping: SoCRoomScript {
    let id: SoCRoomID = .cataractaShopping

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Shopping District"),
            .body("The shopping district has a few small locations."),
            .body("To the NORTH is a pier accompanied by a small shop owned by Doran, the resident fisherman."),
            .body("To the SOUTH is a general store owned by Athalos, a stout and peculiar shopkeeper."),
            .body("To the EAST is a blacksmith run by Ulric."),
            .body("To the WEST is the Housing district."),
            .hint("Which way would you like to investigate?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.courtyardComplete {
            return SoCTurnResult([.body("The shops are burned out.")], .move(.cataractaHousing))
        }
        if input.contains(Verb.look) || input.contains("SEARCH") {
            return SoCTurnResult(SoCCataractaFlavor.shoppingLookLines())
        }
        if input.contains(Verb.north) { return SoCTurnResult([], .move(.cataractaPier)) }
        if input.contains(Verb.south) { return SoCTurnResult([], .move(.cataractaAthalos)) }
        if input.contains(Verb.east) { return SoCTurnResult([], .move(.cataractaBlacksmith)) }
        if input.contains(Verb.west) { return SoCTurnResult([], .move(.cataractaHousing)) }
        return SoCTurnResult([.hint("You can go NORTH, SOUTH, EAST, or WEST.")])
    }
}

struct SoCCataractaWestHallway: SoCRoomScript {
    let id: SoCRoomID = .westHallway

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("West Castle Hallway"),
            .body("To the NORTH is the Nacastrum Library."),
            .body("To the EAST is a grand luxurious door that is encrusted in jewels."),
            .body("To the WEST is the Cataractan portal room."),
            .hint("Which way would you like to investigate?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if input.contains(Verb.north) { return SoCTurnResult([], .move(.library)) }
        if input.contains(Verb.east) { return SoCTurnResult([], .move(.throneRoom)) }
        if input.contains(Verb.west) { return SoCTurnResult([], .move(.portalRoom)) }
        return SoCTurnResult([.hint("You can go NORTH, EAST, or WEST.")])
    }
}

/// From `Avasia-SoC/Cataracta/Cataracta_Hunter_Path.py` — expanded with wolf-trail lore.
struct SoCCataractaHunterPath: SoCRoomScript {
    let id: SoCRoomID = .cataractaHunterPath

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Hunter's Path"),
            .body("That's the trail hunters use to go hunt."),
            .body("Wolf tracks mark the mud — spirit animals run ahead of the Legion here."),
            .body("Dentros would tell recruits this path leads nowhere useful today."),
            .hint("The courtyard is east through town. LEAVE to return home.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }
        if input.contains(Verb.look) || input.contains("SEARCH") || input.contains("TRACK") {
            return SoCTurnResult([
                .body("Fresh wolf sign leads into the forest."),
                .body("Hunters train with their spirit animals out here — not on enlistment day.")
            ])
        }
        if input.contains("LEAVE") || input.contains("BACK") || input.contains(Verb.west) || input.contains(Verb.east) {
            return SoCTurnResult([.body("You head back toward housing.")], .move(.cataractaHousing))
        }
        return SoCTurnResult([.hint("LOOK at the tracks, or LEAVE.")])
    }
}

/// Guard barracks — turned away, but guards share muster gossip.
struct SoCCataractaBarracks: SoCRoomScript {
    let id: SoCRoomID = .cataractaBarracks

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Guard Barracks"),
            .body("The guard barracks are built of stone brick."),
            .body("Two Cataractan legionnaires block the entrance with crossed spears."),
            .hint("TALK to the guards, LOOK around, or LEAVE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }

        if input.contains("TALK") || input.contains("SPEAK") || input.contains("GUARD") {
            var lines: [StyledLine] = [
                .speech("Legionnaire: Civilians aren't allowed inside."),
                .speech("Legionnaire: Muster's at the courtyard. Your officer is Dentros."),
                .speech("Legionnaire: King Kimious called up hidden reserves — something big is moving.")
            ]
            if !state.barracksTalked {
                state.barracksTalked = true
                lines.append(contentsOf: SoCQuestProgress.grantQuestExp(8, state: &state))
            }
            return SoCTurnResult(lines)
        }

        if input.contains(Verb.look) || input.contains("SEARCH") {
            return SoCTurnResult([
                .body("Spear racks and practice dummies line the yard behind the guards."),
                .body("You catch the scent of oil and iron — Cataracta preparing for war.")
            ])
        }

        if input.contains("LEAVE") || input.contains("BACK") || input.contains(Verb.west) || input.contains(Verb.east) {
            return SoCTurnResult([.body("You leave the barracks.")], .move(.cataractaNorth))
        }

        return SoCTurnResult([.hint("TALK to the guards, LOOK, or LEAVE.")])
    }
}
