import Foundation

// The Oceandale starting region — a fully implemented vertical slice that
// demonstrates the room pattern, item/spell gating, NPC dialogue, and the
// escort-mode branch. Remaining areas follow this same shape (see World.swift).

/// Oceandale hub. Exits change once the Old Mage escort begins.
struct OceandaleRoom: RoomScript {
    let id: RoomID = .oceandale

    func describe(_ state: GameState) -> [StyledLine] {
        if state.escortActive {
            return [
                .body("To the NORTH, the road continues into the city."),
                .body("To the SOUTH, the southern gate leads to the shore-front."),
                .blank,
                .body("Your quest is finally coming to an end. Head NORTH towards Nacastrum."),
                .body("On the other hand, maybe the Old Mage would like to see the beach first."),
                .hint("Which way would you like to investigate?")
            ]
        }
        return [
            .body("To the NORTH, a blood-stained road continues through the city."),
            .body("To the EAST, there is debris barely distinguishable as a trading post."),
            .body("To the WEST, you see a house that appears untouched, unmarked by the Agroman faction."),
            .body("To the SOUTH, the southern gate leads to the shore-front."),
            .hint("Which way would you like to investigate?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.north) { return TurnResult([.body("You venture NORTH into the outskirts of the city.")], .move(.graveyard)) }
        if input.contains(Verb.south) { return TurnResult([.body("You venture SOUTH to the beach.")], .move(.beach)) }
        if state.escortActive {
            return TurnResult([.hint("Head NORTH towards Nacastrum, or SOUTH to the beach.")])
        }
        if input.contains(Verb.east) { return TurnResult([], .move(.tradingPost)) }
        if input.contains(Verb.west) { return TurnResult([], .move(.magehouse)) }
        return TurnResult([.hint("You can go NORTH, EAST, WEST, or SOUTH.")])
    }
}

/// Beach (south of Oceandale). Optional fishing if the rod is held.
struct BeachRoom: RoomScript {
    let id: RoomID = .beach

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The southern gate opens onto a cold, wind-bitten shore."),
            .body("Distant ships sit along the horizon, fishing."),
            state.has(.rod)
                ? .hint("You could FISH here, or head BACK into the city.")
                : .hint("You could take a moment to STRETCH, or head BACK into the city.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.back) || input.contains(Verb.north) {
            return TurnResult([], .move(.oceandale))
        }
        if input.contains("FISH") {
            guard state.has(.rod) else {
                return TurnResult([.hint("You have nothing to fish with. Items don't just appear out of thin air ya'know?")])
            }
            return Fishing.cast(&state)
        }
        if input.contains("STRETCH") || input.contains("YOGA") {
            return TurnResult([.body("You stretch out the aches of your strange journey. You feel a little better. Namaste.")])
        }
        return TurnResult([.hint("You can FISH, STRETCH, or go BACK.")])
    }
}

/// Trading post (east). Flavor only. Uses raw input mode like the original.
struct TradingPostRoom: RoomScript {
    let id: RoomID = .tradingPost
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("As you near the broken remnants of a trading post, the stench of fish and burnt wood fills the air."),
            .body("A few people are attempting to make the place a bit more organized."),
            .hint("You could TALK to them, or LEAVE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.talk) {
            return TurnResult([
                .body("You approach one of the men cleaning up the debris and announce yourself."),
                .speech("Trading post is closed, mage, if you couldn't tell already."),
                .speech("The damn Agromanians burned my beloved store to the ground!"),
                .speech("They showed up in the middle of the night, the cowards!"),
                .speech("My wife, they took my wife!"),
                .speech("I.. I need to be alone now."),
                .body("You leave the trading post.")
            ], .move(.oceandale))
        }
        if input.contains(["LEAVE", "BACK", "EXIT", "RETURN"]) {
            return TurnResult([.body("You leave the trading post.")], .move(.oceandale))
        }
        return TurnResult([.hint("You can TALK or LEAVE.")])
    }
}

/// Magehouse (west) — the quest hub. Priority-ordered branches replace the
/// original's non-mutually-exclusive if-chain (ENGINE_SPEC §A.9 #2):
/// no-levitate (learn it) > staff (escort begins) > escort (depart) > locked.
struct MagehouseRoom: RoomScript {
    let id: RoomID = .magehouse

    func describe(_ state: GameState) -> [StyledLine] {
        if !state.has(.levitate) {
            return [
                .body("You draw nearer to the house, when the door bursts open; pages of books fly in every direction."),
                .body("You enter to see stacks of books piled to the ceiling. The heavy door slams shut behind you."),
                .body("You turn to face an elderly brunette woman whose appearance alone sparks recognition."),
                .speech("You recognize one of your own don't you? Mage to mage; Kaefden to Kaefden."),
                .speech("But... YOU are lost, terribly lost. You might have what it takes."),
                .hint("\"Tell me — what faction do the mages represent?\"")
            ]
        }
        if state.teleporterDiscovered && !state.escortActive {
            return [
                .body("The Old Mage is waiting for you, leaning on a tall staff topped with a blue gem."),
                .speech("So you found it. The Ring of Malkos. I will need to come with you."),
                .hint("Are you READY to set out?")
            ]
        }
        if state.escortActive {
            return [.body("There is nothing left here. The Old Mage walks beside you now.")]
        }
        return [
            .body("You return to the mage's house, but the door is locked."),
            .body("The Old Mage is no longer home."),
            .hint("You should head BACK and continue your quest.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        // First meeting: faction question, then the gift of Levitate.
        if !state.has(.levitate) {
            if input.contains("KAEFDEN") {
                state.gain(.levitate)
                state.magehouseLocked = true
                return TurnResult([
                    .speech("Yes. Kaefden. The faction of order and integrity."),
                    .speech("Vashirr scattered our people for a reason. I believe he has sided with the Agromanians."),
                    .speech("This is your quest! You must unlock the gates to Nacastrum and unite our people!"),
                    .item("You have learned the spell LEVITATE."),
                    .body("The door swings open. There is more of the world to see.")
                ], .move(.oceandale))
            }
            return TurnResult([.hint("\"Try again. What faction do the mages represent?\"")])
        }
        // Returning for the staff -> begin escort.
        if state.teleporterDiscovered && !state.escortActive {
            if input.contains(["READY", "YES", "Y"]) {
                state.escortActive = true
                return TurnResult([
                    .item("The Old Mage hands you nothing — she keeps the staff close — but she is with you now."),
                    .speech("Before I die, I want to see the Nacastrum I remember from my childhood. Lead on.")
                ], .move(.oceandale))
            }
            return TurnResult([.hint("\"Are you READY?\"")])
        }
        return TurnResult([], .move(.oceandale))
    }
}

/// Graveyard / upper Oceandale (north). The sword is taken from a corpse here.
struct GraveyardRoom: RoomScript {
    let id: RoomID = .graveyard

    func describe(_ state: GameState) -> [StyledLine] {
        if state.escortActive {
            return [
                .body("The road north leads out of the city, toward the Splitpath."),
                .hint("Head NORTH to continue toward Nacastrum.")
            ]
        }
        return [
            .body("The northern outskirts. To the EAST lies a graveyard — a six-feet-tall, near-endless stack of bodies."),
            .body("To the WEST stands a burned-out church. To the NORTH, the broken gate leads out of the city."),
            .hint("Where would you like to go? (NORTH, EAST, WEST, or SOUTH)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.north) { return TurnResult([.body("You pass through the broken gate.")], .move(.splitpath)) }
        if state.escortActive { return TurnResult([.hint("Head NORTH.")]) }
        if input.contains(Verb.west) { return TurnResult([], .move(.church)) }
        if input.contains(Verb.south) { return TurnResult([], .move(.oceandale)) }
        if input.contains(Verb.east) || input.contains(Verb.look) || input.contains(Verb.take) {
            if state.has(.sword) {
                return TurnResult([.body("You have already looted what you could from the dead. Best not to linger.")])
            }
            if input.contains(Verb.take) {
                state.gain(.sword)
                return TurnResult([.item("You pry a long sword from a fallen soldier's grip. You take the LONG SWORD.")])
            }
            return TurnResult([
                .body("Among the bodies, a soldier still clutches a long sword."),
                .hint("You could TAKE it.")
            ])
        }
        return TurnResult([.hint("You can go NORTH, EAST (graveyard), WEST (church), or SOUTH.")])
    }
}

/// Burned church (west of graveyard). Flavor only.
struct ChurchRoom: RoomScript {
    let id: RoomID = .church

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A rustic church, dedicated to the matron God of the Ocean — now blackened and roofless."),
            .body("There is nothing to be found here but ash and quiet grief."),
            .hint("Head BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .move(.graveyard))
    }
}
