import Foundation

// The Mountain & Cave region (east of Splitpath). Reached by crossing the bridge
// with Levitate. Contains the druid encounters and the cave's fireball symbol
// puzzle — the central rune mechanic. See WORLD_MAP §4 and STORY §5.

/// Mountain hub on the far side of the bridge.
struct MountainRoom: RoomScript {
    let id: RoomID = .mountain

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("You stand on a windswept ridge, the chasm at your back."),
            .body("To the NORTH gapes the mouth of a cave. To the EAST, a red fox watches you."),
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
            return [
                .body("Dentros gives you a knowing nod, his cherry-red hair bright against the grey stone."),
                .speech("The Old Mages hid their secrets deep in that cave. Mind the dark."),
                .hint("Head BACK.")
            ]
        }
        return [
            .body("The red fox pads closer, then rises — fur becoming cloak, snout becoming a man's grinning face."),
            .speech("My name is Dentros. I am a scout from Cataracta. I am a Druid."),
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
                .speech("You seek what the Old Mages left behind. The cave to the north — but you'll be blind in there."),
                .speech("Take this. You'll need it more than I."),
                .item("Dentros hands you a LANTERN.")
            ], .move(.mountain))
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
            .body("The trail climbs toward a huge stone gate enriched with blue crystal shards."),
            .body("To the NORTH stand the gate and its druid hunters."),
            .hint("Go NORTH to the gate, or BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
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
            .body("Six druid hunters bar the gate. One drops to all fours and becomes a great black wolf, hackles raised."),
            .speech("Hold! Prove you are no Agromanian spy."),
            .hint("How do you prove yourself? (show your EARS, or cast a spell)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        let proven: Bool
        var how: StyledLine? = nil
        if input.contains(["EAR", "EARS"]) {
            proven = true; how = .body("You sweep back your hood, baring the long pointed ears of a Kaefden mage.")
        } else if input.contains(Flag.levitate.castSynonyms) && state.has(.levitate) {
            proven = true; how = .body("You rise gently off the stone. No spy could fake the old magic.")
        } else if input.contains(Flag.stonebend.castSynonyms) && state.has(.stonebend) {
            proven = true; how = .body("You bend the rock of the gatepost like clay. The wolf shrinks back.")
        } else if input.contains(Flag.fireball.castSynonyms) {
            return TurnResult([.hint("You raise a flame — and the hunters bristle. Fire among allies? Lower it, fool.")])
        } else {
            proven = false
        }

        guard proven else {
            return TurnResult([.hint("The wolf growls. Show them your EARS, or cast a spell only a mage could.")])
        }
        state.cataractaGateDone = true
        var lines: [StyledLine] = []
        if let how { lines.append(how) }
        lines.append(contentsOf: [
            .speech("Dreadfully sorry about that, Mage. I am Cellious."),
            .speech("But I'm afraid I can't let you into the city. Our king is extremely paranoid of spies."),
            .body("The gate stays shut. There is nothing more for you here.")
        ])
        return TurnResult(lines, .move(.mountain))
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
        if input.contains(Flag.levitate.castSynonyms) && state.has(.levitate) {
            return TurnResult([.body("You drift upward in the dark — straight onto a ceiling of unseen stalactites.")],
                              .death(reason: "Impaled in the blind dark. Some places are not meant for flying."))
        }
        if input.contains(["LIGHT", "LANTERN"]) {
            guard state.has(.lantern) else {
                return TurnResult([.hint("You have no light. Items don't just appear in this game.")])
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
            return [.body("The stone gate stands open. The pedestal chamber lies beyond."), .hint("Go FORWARD, or BACK.")]
        }
        return [
            .body("An ancient archway bars the way, set with three rune buttons:"),
            .symbol("   1: %'      2: )*      3: <~"),
            .hint("You could PUSH a button (1, 2, or 3), or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.back) || input.contains(Verb.south) {
            return TurnResult([], .move(.mainCave))
        }
        if state.has(.northCaveGateOpen) && (input.contains(["FORWARD", "NORTH", "ENTER"])) {
            return TurnResult([], .move(.fireballRoom))
        }
        if input.contains(["1", "%'"]) {
            state.gain(.northCaveGateOpen)
            return TurnResult([.body("The button sinks with a grind of stone. The gate yawns open.")], .move(.fireballRoom))
        }
        if input.contains(["2", ")*", "3", "<~"]) {
            return TurnResult([.body("The button clicks, but nothing happens.")])
        }
        return TurnResult([.hint("PUSH button 1, 2, or 3 — or go BACK.")])
    }
}

/// Fireball room — solve the rune order (state.symbolAnswer) to learn Inflame.
struct FireballRoom: RoomScript {
    let id: RoomID = .fireballRoom

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A cracked pedestal stands at the center. In the corner, a mage is burnt to ash."),
            .body("It seems you are not alone on your quest."),
            .body("Four slots wait on the pedestal. A legend is carved above them:"),
            .symbol("   ^' = 1     ~' = 2     >' = 3     ;' = 4"),
            .hint("Enter the four-symbol order (as digits), or LEAVE. (\(state.guesses) attempts left)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LEAVE", "BACK", "EXIT", "RETURN"]) {
            return TurnResult([], .move(.northCave))
        }
        if input.contains(["NOIDEA"]) {
            return TurnResult([.hint("Thanks for your honesty.")])
        }
        if input.normalized == state.symbolAnswer {
            state.gain(.fireball)
            return TurnResult([
                .body("The slots blaze. Heat coils up your arm and settles, waiting, behind your eyes."),
                .item("You have learned the spell INFLAME.")
            ], .move(.mainCave))
        }
        // Wrong guess.
        state.guesses -= 1
        if state.guesses <= 0 {
            return TurnResult([.body("The pedestal flares white-hot and the whole chamber erupts in flame.")],
                              .death(reason: "Burnt to ash, like the mage before you."))
        }
        return TurnResult([.hint("The runes flash red. Wrong. (\(state.guesses) attempts left)")])
    }
}

/// A symbol-clue room: reveals one rune of the puzzle by slot index.
struct SymbolClueRoom: RoomScript {
    let id: RoomID
    let slot: Int           // index into state.symbols
    let ordinal: String     // "first" / "second" / ...
    let flavor: [StyledLine]

    func describe(_ state: GameState) -> [StyledLine] {
        var lines = flavor
        lines.append(.symbol("Scratched into the stone, the \(ordinal) symbol of four:  \(state.symbols[slot].glyph)"))
        lines.append(.hint("Head BACK."))
        return lines
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
                .body("You rise to the cage and pry the parchment from skeletal fingers."),
                .symbol("The third symbol of four:  \(state.symbols[2].glyph)")
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
            .body("A miner lies murdered among translucent shards, a pickaxe still within reach."),
            .symbol("Carved beside him, the second symbol of four:  \(state.symbols[1].glyph)"),
            .hint("You could TAKE the pickaxe, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.take) || input.contains(["PICKAXE", "MINE", "PICK"]) {
            return TurnResult([.body("You heft the pickaxe and swing at the shards. Something in the dark hurls a spear through your chest.")],
                              .death(reason: "Killed for a miner's greed. The shards were guarded."))
        }
        return TurnResult([], .move(.mainCave))
    }
}
