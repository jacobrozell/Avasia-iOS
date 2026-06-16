import Foundation

// The Mountain & Cave region (east of Splitpath). Text reproduced verbatim from
// GameDriver.py (deliberate typos and jokes preserved). Mechanics unchanged.

/// Mountain hub on the far side of the bridge.
struct MountainRoom: RoomScript {
    let id: RoomID = .mountain

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("You stand on a windswept ridge, the chasm at your back."),
            .body("To the NORTH gapes the mouth of a cave. To the EAST, paw-prints lead away."),
            .body("To the WEST, a trail winds toward a gate of blue crystal. To the SOUTH, the bridge."),
            .hint("Which way? (NORTH, EAST, WEST, SOUTH)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.north) { return TurnResult([], .move(.caveEntrance)) }
        if input.contains(Verb.east) { return TurnResult([], .move(.druidTalk)) }
        if input.contains(Verb.west) { return TurnResult([], .move(.westMountain)) }
        if input.contains(Verb.south) { return TurnResult([.body("You return to the edge of the chasm.")], .move(.bridge)) }
        return TurnResult([.hint("You can go NORTH, EAST, WEST, or SOUTH.")])
    }
}

/// Dentros the druid scout — gives the lantern.
struct DruidTalkRoom: RoomScript {
    let id: RoomID = .druidTalk

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.lantern) {
            return [.body("There is nothing of significance here."), .hint("Head BACK.")]
        }
        return [
            .body("You follow the path to the EAST."),
            .body("As you travel further, you notice tracks on the ground."),
            .body("The tracks are fairly small and are in the shape of a paw-print."),
            .blank,
            .body("You decide to follow the tracks and eventually find yourself behind a red fox."),
            .body("After a stare-down, the fox relaxes and walks towards you — growing, rising onto its hind legs."),
            .body("To your surprise, what was a fox transforms into a man with long, cherry-red hair."),
            .blank,
            .speech("Ah, greetings mage. My apologies for the reaction. You never know what could be out here."),
            .speech("My name is Dentros. I am a scout from Cataracta. If you can't tell, I am a Druid."),
            .hint("You could TALK with him, or head BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.back) || input.contains(Verb.west) {
            return TurnResult([], .move(.mountain))
        }
        if input.contains(Verb.talk) && !state.has(.lantern) {
            state.gain(.lantern)
            state.gain(.metDentros)
            return TurnResult([
                .speech("You seek to reopen Nacastrum? Yes, a difficult task indeed."),
                .speech("Since Vashirr exiled his people, I must admit, my people have been worried."),
                .speech("Deep within the mountains is a secret of the Old Mages."),
                .speech("The druid of Cataracta have known of it for ages, but do not posses the means to reach it."),
                .speech("I suggest you look for this hidden knowledge. It may be of use to you."),
                .speech("Oh, before you leave. Take this lantern. The caves are dark and you will need to be able to see."),
                .item("You received a lantern!"),
                .speech("Good luck, my friend."),
                .body("Dentros returns to his fox form and leaps away.")
            ], .move(.mountain))
        }
        if state.has(.lantern) && input.contains(["CATARACTA", "ANULA", "GATE"]) {
            return TurnResult([
                .speech("Our western gate shines with Sylvian Anula — gift, not trade."),
                .speech("King Kimious fears spies since Oceandale. If you reach Cataracta someday, tell him a mage proved honest at the gate.")
            ])
        }
        return TurnResult([.hint("You can TALK or go BACK.")])
    }
}

/// West Mountain — the approach to the Cataracta gate.
struct WestMountainRoom: RoomScript {
    let id: RoomID = .westMountain

    func describe(_ state: GameState) -> [StyledLine] {
        if state.cataractaGateDone {
            return [
                .body("The blue-crystal gate of Cataracta remains shut to you. Cellious will not change his mind."),
                .hint("Head BACK.")
            ]
        }
        return [
            .body("You continue until the dirt path becomes stone and the chasm's roar becomes the chirps of birds."),
            .body("Ahead you see a huge stone gate, enriched with blue crystal shards — Anula, the druids say."),
            .body("You see a group of six men talking under the blue gleaming gate to the NORTH."),
            .hint("Go NORTH to the gate, LOOK at the crystals, or BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LOOK", "EXAMINE", "CRYSTAL", "ANULA"]) && !input.contains(Verb.north) {
            return TurnResult([
                .body("The shards are Anula — earth-crystal, cold to the touch even in sunlight."),
                .body("Silvarium sends cartloads to Cataracta as gift. Here they guard the gate like teeth.")
            ])
        }
        if input.contains(Verb.north) && !state.cataractaGateDone {
            return TurnResult([], .move(.druidPath))
        }
        return TurnResult([], .move(.mountain))
    }
}

/// Cataracta gate — prove you are a mage to avoid the wolf.
struct DruidPathRoom: RoomScript {
    let id: RoomID = .druidPath

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("These men seem friendly enough. You approach them to start a converation."),
            .speech("Who are you!? Stay back!"),
            .body("Suddenly, one of the men lets out an unhuman roar! He is on all fours,"),
            .body("thrashing as hairs protrude from his ever-growing body — a big, black, terrifying wolf!"),
            .body("You know that the druids are allies with the mages. You need to show them who you are."),
            .hint("How do you prove yourself? (show your EARS, or cast a spell)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        var lead: [StyledLine] = []
        var proven = false
        if input.contains(["EAR", "EARS"]) {
            proven = true
            lead = [
                .body("You quickly pull back your hair and flash your ears!"),
                .body("Almost immediately, the group seems to understand that you mean no harm.")
            ]
        } else if input.contains(Flag.levitate.castSynonyms) && state.has(.levitate) {
            proven = true
            lead = [
                .body("You desperately mumble levitate under your breath."),
                .body("Suddenly, the druid men are like little stone pebbles as you ascend towards the heavens."),
                .body("Once you see the wolf transform back into human form, you deicde it is safe to come back down.")
            ]
        } else if input.contains(Flag.stonebend.castSynonyms) && state.has(.stonebend) {
            proven = true
            lead = [
                .body("You cast Stonebend!"),
                .body("Right in front of you, the stone pathway lurches upwards to hide the pack of men."),
                .body("The men seem surprised but immediately understand you mean no harm.")
            ]
        } else if input.contains(Flag.fireball.castSynonyms) {
            return TurnResult([
                .body("That would certainly start a wildfire, or kill your allies."),
                .body("Find another way! Quick!")
            ])
        }

        guard proven else {
            return TurnResult([.hint("You need to show them you're a mage. You can try talking to them.")])
        }
        state.cataractaGateDone = true
        let events: [GameEvent] = input.contains(["EAR", "EARS"]) ? [.provedWithEars] : []
        return TurnResult(lead + [
            .body("The man that shouted, obviously the leader, begins to apologize."),
            .speech("Dreadfully sorry about that, Mage."),
            .speech("You can't be too careful around here, not with those cursed Agromanians lurking around."),
            .speech("We are a group of hunters. Our duty is to provide food for the people of Cataracta."),
            .speech("The blue on our gate is Anula — Sylvian gift. We do not sell it. We guard it."),
            .speech("My name is Cellious. I'm the chief of that hunting pack."),
            .speech("I heard what happened to Nacastrum. Most mages went towards Aylova, the capital. But not you."),
            .speech("I'm afriad I can't let you into the city."),
            .speech("Our king is extremely paranoid of spies now that Oceandale has been attacked."),
            .speech("I wish you safe travels, Mage. And most of all, if you see any Agromanians..."),
            .body("Cellious roars ferociously showing his hatred."),
            .body("You make your way all the way back to where you crossed the bridge.")
        ], .move(.mountain), events: events)
    }
}

/// Cave entrance — needs the lantern; levitating here is fatal.
struct CaveEntranceRoom: RoomScript {
    let id: RoomID = .caveEntrance

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The cave mouth swallows all light. You can see nothing within."),
            state.has(.lantern)
                ? .hint("You could LIGHT your lantern, or go BACK.")
                : .hint("It is far too dark to enter. Go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.back) || input.contains(Verb.south) {
            return TurnResult([], .move(.mountain))
        }
        if input.contains(Verb.look) || input.contains("SEARCH") || input.contains("HISTORY") {
            return TurnResult([
                .body("Scorch marks and old iron rings are bolted into the stone — this cave was a prison long before the mages hid their secrets here.")
            ])
        }
        if input.contains(Flag.levitate.castSynonyms) && state.has(.levitate) {
            return TurnResult([
                .body("Your voice echos through the dark cave as you fling upwards out of the water."),
                .body("You overcompensate for the weight of the water and spring upwards; faster than intended."),
                .body("The roof of the cave is home to several stalactites.")
            ], .death(.stalactite))
        }
        if input.contains(["LIGHT", "LANTERN", "TORCH"]) {
            guard state.has(.lantern) else {
                return TurnResult([
                    .body("What lantern?"),
                    .body("I must've missed when you obtained that."),
                    .body("Items don't just appear out of thin air ya'know?")
                ])
            }
            return TurnResult([
                .body("Lantern lit, you pick your way down a narrow, flooded passage and swim through a low hole."),
                .body("Beyond, the rock opens into a vast cavern.")
            ], .move(.mainCave))
        }
        return TurnResult([.hint("You can LIGHT your lantern (if you have one) or go BACK.")])
    }
}

/// Main cave hub — raw, exact-direction input like the original `mcave`.
struct MainCaveRoom: RoomScript {
    let id: RoomID = .mainCave
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("Enormous pink crystals illuminate the room with a soft glow."),
            .body("Passages lead NORTH, NORTHEAST, NORTHWEST, EAST, and WEST. SOUTH leads back out."),
            .hint("Which way? (e.g. NORTH, NE, NW, E, W, S)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.equalsAny(["NORTHEAST", "NE", "GO NORTHEAST"]) { return TurnResult([], .move(.northeastCave)) }
        if input.equalsAny(["NORTHWEST", "NW", "GO NORTHWEST"]) { return TurnResult([], .move(.northwestCave)) }
        if input.equalsAny(["NORTH", "GO NORTH", "N"]) { return TurnResult([], .move(.northCave)) }
        if input.equalsAny(["EAST", "GO EAST", "E"]) { return TurnResult([], .move(.eastCave)) }
        if input.equalsAny(["WEST", "GO WEST", "W"]) { return TurnResult([], .move(.westCave)) }
        if input.equalsAny(["SOUTH", "GO SOUTH", "S", "BACK", "LEAVE"]) { return TurnResult([], .move(.caveEntrance)) }
        return TurnResult([.hint("The crystals hum. Choose a passage: NORTH, NE, NW, EAST, WEST, or SOUTH.")])
    }
}

/// North cave — the three-button rune gate (button 1 / `%'` opens it).
struct NorthCaveRoom: RoomScript {
    let id: RoomID = .northCave

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.northCaveGateOpen) {
            return [.body("The stone-gate has rolled away, leaving a new entrance to the north."), .hint("Go FORWARD, or BACK.")]
        }
        return [
            .body("You walk under a massive archway that is inscribed with ancient writing."),
            .body("Ahead you see a massive crumbling stone-gate, its writings penetrating the wall about a quarter inch."),
            .symbol("Symbols include:  %'   )*   <~"),
            .hint("You could PUSH a button (1, 2, or 3), or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.back) || input.contains(Verb.south) {
            return TurnResult([], .move(.mainCave))
        }
        if input.contains(Flag.levitate.castSynonyms) {
            return TurnResult([.body("Seriously?")])
        }
        if state.has(.northCaveGateOpen) && input.contains(["FORWARD", "NORTH", "ENTER"]) {
            return TurnResult([], .move(.fireballRoom))
        }
        if input.contains(["1", "%'"]) {
            state.gain(.northCaveGateOpen)
            return TurnResult([
                .body("A low rumbling turns to a loud thunderous roar, the northern gate is rolling open!"),
                .body("After the dust settles, and you clear your eyes..."),
                .body("The stone-gate has rolled away, leaving a new entrance to the north!")
            ], .move(.fireballRoom))
        }
        if input.contains(["2", ")*", "3", "<~"]) {
            return TurnResult([
                .body("You reach out and touch the cold inscription."),
                .body("Absolutely nothing happens.")
            ])
        }
        return TurnResult([.hint("PUSH button 1, 2, or 3 — or go BACK.")])
    }
}

/// Fireball room — solve the rune order (state.symbolAnswer) to learn Inflame.
struct FireballRoom: RoomScript {
    let id: RoomID = .fireballRoom

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("There is a cracked stone pedestal, centered in the room."),
            .body("The smell of charred ash stings your nostrils."),
            .body("A dead mage lies in the corner of the room."),
            .body("His body is now just black ash in the shape of what he once was."),
            .blank,
            .body("It seems you are not alone on your quest."),
            .blank,
            .body("On the pedestal are four symbols, horizontal to each other."),
            .symbol("The symbols include: (^' ~' >' ;')"),
            .symbol("   ^' = 1     ~' = 2     >' = 3     ;' = 4"),
            .hint("Enter the four-symbol order (as digits), or LEAVE. (\(state.guesses) attempts left)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LEAVE", "BACK", "EXIT", "RETURN"]) {
            return TurnResult([], .move(.northCave))
        }
        if input.contains(Flag.levitate.castSynonyms) {
            return TurnResult([.body("You seriously have got to stop.")])
        }
        if input.contains(["LANTERN", "LIGHT"]) {
            return TurnResult([.body("It's already lit fam.")], events: [.relitLanternAtPedestal])
        }
        if input.contains(["NOIDEA"]) {
            return TurnResult([
                .body("Thanks for your honesty."),
                .body("I'm not going to give you the answer, however.")
            ], events: [.admittedNoIdea])
        }
        if input.normalized == state.symbolAnswer {
            state.gain(.fireball)
            return TurnResult([
                .body("The slots blaze. Heat coils up your arm and settles, waiting, behind your eyes."),
                .item("You obtained the spell Inflame!")
            ], .move(.mainCave))
        }
        // Wrong guess.
        state.guesses -= 1
        if state.guesses <= 0 {
            return TurnResult([
                .body("Suddenly the room goes completely black."),
                .body("The entrance behind you rolls shut once again."),
                .body("The ground under you becomes immensely hot."),
                .body("The cause of the heat is now apparent."),
                .body("A massive ball of fire hurls towards you.")
            ], .death(.fireball))
        }
        return TurnResult([.hint("The runes flash red. Wrong. (\(state.guesses) attempts left)")])
    }
}

/// A symbol-clue room: reveals one rune of the puzzle by slot index. The lead-in
/// flavor is supplied per room in `World`; this appends the reveal line.
struct SymbolClueRoom: RoomScript {
    let id: RoomID
    let slot: Int           // index into state.symbols
    let ordinal: String     // for the test/comment only
    let flavor: [StyledLine]

    func describe(_ state: GameState) -> [StyledLine] {
        flavor + [
            .symbol("The symbol is \(state.symbols[slot].glyph)"),
            .hint("Head BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .move(.mainCave))
    }
}

/// Northeast cave — the third symbol, reachable only by Levitate (up to a cage).
struct NortheastCaveRoom: RoomScript {
    let id: RoomID = .northeastCave

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("Iron cages hang from the cavern roof. In one, a skeleton slumps over a scrap of parchment, far overhead."),
            state.has(.levitate)
                ? .hint("You could LEVITATE up to read it, or go BACK.")
                : .hint("It hangs far too high to reach. Go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Flag.levitate.castSynonyms) && state.has(.levitate) {
            return TurnResult([
                .body("You manage to decipher the third symbol."),
                .symbol("The symbol is \(state.symbols[2].glyph)")
            ], .move(.mainCave))
        }
        return TurnResult([], .move(.mainCave))
    }
}

/// Northwest cave — the second symbol; an optional, fatal pickaxe.
struct NorthwestCaveRoom: RoomScript {
    let id: RoomID = .northwestCave

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("You head into the north-western entrance, the pink crystals shrinking and cracking as you go."),
            .body("The ground is littered in broken shards, colorless despite coming from the pink spires."),
            .body("You discover a body laying cold on the floor, his satchel busted open and full of translucent shards."),
            .body("He appears to have been attempting to mine the shards. His pickaxe lies beside him."),
            .blank,
            .body("Three of the four symbols are illegible, but you can decipher one of them."),
            .symbol("The second of the four is \(state.symbols[1].glyph)"),
            .hint("You could TAKE the pickaxe, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.take) || input.contains(["PICKAXE", "MINE", "PICK"]) {
            return TurnResult([
                .body("You grab the pickaxe."),
                .body("You walk towards one of the remaining crystals and set down your lantern."),
                .body("Just as you're about to slam down the pick into the crystals..."),
                .body("You feel a sharp pain in the center of your back."),
                .body("You drop the pickaxe and look down to see the tip of a spear extruding from your chest."),
                .body("The world around you darkens and you fall to the ground..")
            ], .death(.mining))
        }
        return TurnResult([.body("It probably isn't a good idea to mine the pink crystals considering the miner's fate. You continue on through the cave.")], .move(.mainCave))
    }
}
