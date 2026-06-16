import Foundation

// The Oceandale starting region. Text is reproduced verbatim from the original
// game (deliberate typos and jokes preserved). Mechanics are unchanged from the
// first pass; only the flavor/dialogue is now faithful to GameDriver.py.

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
                .body("On the other hand, maybe the Old Mage would like to see the beach before venturing on."),
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
        if input.contains(Verb.south) {
            var lines: [StyledLine] = [.body("You venture SOUTH to the beach.")]
            if !state.beachIntroShown && !state.escortActive {
                state.beachIntroShown = true
                lines += KoNBeachFlavor.awakeningLines()
            }
            return TurnResult(lines, .move(.beach))
        }
        if state.escortActive {
            return TurnResult([.hint("Head NORTH towards Nacastrum, or SOUTH to the beach.")])
        }
        if input.contains(Verb.look) {
            return TurnResult([
                .body("Oceandale was a fishing colony before it was a faction city — open coast, easy strike."),
                .body("Agromanian raiders knew that. The blood on the northern road is newer than the schism, but born from the same wound."),
                .body("Ash stops in a clean arc west of the magehouse, as if the air itself refuses the burn.")
            ])
        }
        if input.contains(Verb.east) { return TurnResult([], .move(.tradingPost)) }
        if input.contains(Verb.west) { return TurnResult([], .move(.magehouse)) }
        return TurnResult([.hint("You can go NORTH, EAST, WEST, or SOUTH.")])
    }
}

/// Beach (south of Oceandale). Optional fishing; yoga flavor; escort scene.
struct BeachRoom: RoomScript {
    let id: RoomID = .beach

    func describe(_ state: GameState) -> [StyledLine] {
        if state.escortActive {
            return [
                .body("You take the Old Mage to the shore."),
                .body("She gazes outwards and begins to talk to you."),
                .blank,
                .speech("Many, many nights I come out here and ponder how it would be if I didn't leave Nacastrum."),
                .speech("I think I've been waiting... Well."),
                .speech("I've been waiting for someone like you to come along."),
                .speech("Who thought when I did finally go back, I would be assisting such an important cause."),
                .speech("When the war ends, they will open the Rings to more than mages — I am sure of it."),
                .speech("Power tied to stone travels. Power left loose starts wars."),
                .speech("We'd best get to it."),
                .hint("Head BACK to Oceandale.")
            ]
        }
        return [
            .body("You stand along the beach, gazing outward."),
            .body("Distant ships sit along the horizon, fishing."),
            .body("The sea breeze is very calming. To the NORTH, smoke rises beyond what might have been a city gate."),
            state.has(.rod)
                ? .hint("You could FISH, do some YOGA, LOOK at the shore, or walk NORTH.")
                : .hint("You could STRETCH or do some YOGA, LOOK at the shore, or walk NORTH.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if state.escortActive {
            return TurnResult([.body("You and the Old Mage go back into Oceandale.")], .move(.oceandale))
        }
        if input.contains(Verb.back) || input.contains(Verb.north) {
            return TurnResult([.body("You walk north along the shore road into what's left of Oceandale.")], .move(.oceandale))
        }
        if input.contains("FISH") {
            guard state.has(.rod) else {
                return TurnResult([.body("You don't have a fishing rod.")])
            }
            return Fishing.cast(&state)
        }
        if input.contains("STRETCH") || input.contains("YOGA") {
            return TurnResult(KoNBeachFlavor.yogaLines(), events: [.didBeachYoga])
        }
        if input.contains(Verb.look) || input.contains(["SAND", "WAVES", "SHORE"]) {
            return TurnResult(KoNBeachFlavor.lookLines())
        }
        return TurnResult([.hint("You can STRETCH, do YOGA, LOOK at the shore, or walk NORTH.")])
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
            .body("You could try and talk to them."),
            .hint("What would you like to do?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.talk) {
            return TurnResult([
                .body("You approach one of the men cleaning up the debris and announce yourself."),
                .body("He takes a moment to look at you before speaking."),
                .blank,
                .speech("Trading post is closed, mage, if you couldn't tell already."),
                .speech("The damn Agromanians burned my beloved store to the ground!"),
                .speech("They showed up in the middle of the night, the cowards!"),
                .speech("My wife, they took my wife!"),
                .speech("I swear those bastards will get what's coming to them."),
                .speech("And now the crown talks of requisition — Sylvian Anula for the legions, they say. As if crystal could buy her back."),
                .speech("I.. I need to be alone now."),
                .blank,
                .body("There's no other reason for you to continue loitering around here."),
                .body("You leave the trading post.")
            ], .move(.oceandale), events: [.heardTradingPostGrief])
        }
        if input.contains(["LEAVE", "BACK", "EXIT", "RETURN"]) {
            return TurnResult([.body("You leave the trading post.")], .move(.oceandale))
        }
        return TurnResult([.hint("You can TALK or LEAVE.")])
    }
}

/// Magehouse (west) — the quest hub. Priority-ordered branches replace the
/// original's non-mutually-exclusive if-chain (ENGINE_SPEC §A.9 #2).
struct MagehouseRoom: RoomScript {
    let id: RoomID = .magehouse

    func describe(_ state: GameState) -> [StyledLine] {
        if !state.has(.levitate) {
            return [
                .body("The ward still hums at the threshold — old Levitate magic, patient, yours almost by inheritance."),
                .body("You draw nearer to the house, when the door bursts open, pages"),
                .body("of books fly in every direction. The sudden gust of wind startles you."),
                .blank,
                .body("However, no one is there."),
                .body("You enter the house to see stacks of books piled to the ceiling."),
                .body("The heavy door behind you slams shut in an instant."),
                .body("You quickly jump and look to the door to see what caused it."),
                .blank,
                .body("However, you can't find the cause of the paranormal occurrence."),
                .body("You turn back around to be face to face with an elderly brunette woman,"),
                .body("whose appearance alone sparks recognition."),
                .body("You decide that she was the one controlling the door."),
                .blank,
                .body("The woman spoke with intellect and fluency, despite her age."),
                .speech("You recognize one of your own don't you?"),
                .speech("Mage to mage; Kaefden to Kaefden."),
                .speech("But... YOU are lost, terribly lost."),
                .blank,
                .speech("All mages have been exiled from Nacastrum, not just you."),
                .speech("But YOU..."),
                .speech("You might have what it takes."),
                .hint("\"Answer me: what faction do the mages represent?\"")
            ]
        }
        if state.teleporterDiscovered && !state.escortActive {
            return [
                .body("You approach the Mage's house and open the door."),
                .body("As you head inside, the room is eerily quiet."),
                .body("You look around and notice the Old Mage from before sitting at a desk."),
                .body("Before you can utter a word she calls out to you without turning around."),
                .blank,
                .speech("I've been waiting for you."),
                .body("She gets up, leads you to a basement table, and reveals a six-foot silver staff topped with a blue gemstone."),
                .speech("The Rings of Malkos are teleporters, named after our first king."),
                .speech("Malkos taught that power must be tied to a place — or it drifts into war."),
                .speech("These rings are anchors fixed in the earth. Step on one, and the world rearranges around you."),
                .speech("This staff acts as a key to the Rings of Malkos."),
                .speech("You know what we must do next. Let us not waste any time. Our home awaits."),
                .hint("\"But before we go, are you sure you're ready?\"")
            ]
        }
        if state.escortActive {
            return [.speech("We need to go to Nacastrum.")]
        }
        return [
            .body("The door is locked."),
            .body("It seems the Old Mage is no longer home."),
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
                    .speech("Glad you know the simplest of things about our people."),
                    .speech("The Council required sky-heirs to keep roots on the ground — your father held that oath in Oceandale."),
                    .speech("Vashirr shattered sky and earth on purpose. That is why your mother was taken."),
                    .speech("Vashirr, the king of the mages, used his power to teleport Nacastrum's citizens."),
                    .speech("After the fall of Oceandale, Vashirr heard of rumors from the druids."),
                    .speech("Nacastrum was to be attacked by the full force of the barbarians of the north."),
                    .speech("I never trusted Vashirr. Soon after he became King, I left."),
                    .speech("Vashirr didn't save you. His true intentions are certainly clouded."),
                    .speech("He scattered his people for a reason."),
                    .speech("All this seems to me, that he has sided with the Agromanians."),
                    .speech("The mages lived in a floating city... What real threat did the barbarians pose?"),
                    .speech("He preached that the Council made us weak — that Nacastrum was a cage, not a home."),
                    .speech("He called it the Many Hands doctrine: magic for soldiers, not towers."),
                    .speech("I sat on that council. He was wrong — but he believed every word."),
                    .speech("That is what makes him dangerous."),
                    .blank,
                    .speech("I'm too old to venture on this quest. But you... You can reunite our people."),
                    .speech("Before I die, I want to see the Nacastrum I remember from my childhood."),
                    .speech("This is your quest! You must unlock the gates to Nacastrum and unite our people!"),
                    .blank,
                    .body("She yanks a great old book from the middle of a stack; the rest crash to the floor."),
                    .speech("This spell will certainly prove useful in your quest! It's called Levitate."),
                    .item("You obtained the spell Levitate!"),
                    .speech("Use it to simply float or hover."),
                    .body("You thank the Old Mage and continue back into Oceandale, with a new sense of purpose.")
                ], .move(.oceandale))
            }
            return TurnResult([.hint("Try again.")])
        }
        // Returning for the staff -> begin escort.
        if state.teleporterDiscovered && !state.escortActive {
            if input.contains(["READY", "YES", "Y"]) {
                state.escortActive = true
                return TurnResult([
                    .body("You and the Old Mage leave the house on the final journey to Nacastrum.")
                ], .move(.oceandale))
            }
            return TurnResult([.speech("Come back when you are truly ready.")])
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
            .body("To the WEST stands a burned-out rustic church. To the NORTH, the broken gate leads out of the city."),
            state.gateGuardLoreHeard
                ? .blank
                : .body("An old man in common-wear leans on a broken spear at the north gate, watching the road."),
            .hint("Where would you like to go? (NORTH, EAST, WEST, or SOUTH)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.north) {
            if !state.escortActive && !state.gateGuardLoreHeard {
                return TurnResult(KoNGateGuardLore.northGateBlockedLines())
            }
            return TurnResult([.body("You pass through the broken gate.")], .move(.splitpath))
        }
        if state.escortActive { return TurnResult([.hint("Head NORTH.")]) }
        if input.contains(["TALK", "GUARD", "ASK"]) {
            if state.gateGuardLoreHeard {
                return TurnResult([
                    .speech("The old guard leans on his broken spear."),
                    .speech("Same schism, boy. Crown or brotherhood — pick your anchor and pray it holds.")
                ])
            }
            state.gateGuardLoreHeard = true
            return TurnResult(KoNGateGuardLore.fullEncounter(), events: [.heardGateGuardLore])
        }
        if input.contains(Verb.west) { return TurnResult([], .move(.church)) }
        if input.contains(Verb.south) { return TurnResult([], .move(.oceandale)) }
        if input.contains(Verb.east) || input.contains(Verb.take) {
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
        if input.contains(Verb.look) {
            return TurnResult([
                .body("Kaefden blue beside Agromanian black. Mages beside fishers. The stack has no order — only weight."),
                .body("The schism did not invent this graveyard. Oceandale's colony history made it easy to strike.")
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
            .hint("LOOK at the shrine, ASK about the matron, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LOOK", "EXAMINE", "SHRINE"]) {
            return TurnResult([
                .body("The matron's statue lies cracked on its side — hands outstretched to the sea, not the sky."),
                .body("Oceandale prayed to tides and harvest long before Nacastrum floated overhead."),
                .body("Civic faith, not tower magic. The Agromanians burned that too.")
            ])
        }
        if input.contains(["ASK", "MATRON", "OCEAN", "GOD"]) {
            return TurnResult([
                .speech("A mourner kneeling in the ash: She kept the fishing fleets. She did not keep the raiders."),
                .speech("They say Kaefden mages heal with blue gems. We lit candles to the matron."),
                .speech("Maybe both are anchors. Maybe that is why the schism never ends.")
            ])
        }
        return TurnResult([], .move(.graveyard))
    }
}
