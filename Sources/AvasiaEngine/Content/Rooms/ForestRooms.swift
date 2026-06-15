import Foundation

// The Forest / Silvarium region (north of Splitpath). The great tree's blood
// seal grants Stonebend. See WORLD_MAP §5 and STORY §5.

/// Forest entrance — grass must be cut with the sword.
struct ForestEntranceRoom: RoomScript {
    let id: RoomID = .forestEntrance

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.grassCut) {
            return [.body("The slashed grass lies trampled. The way north is open."), .hint("Go NORTH, or BACK.")]
        }
        return [
            .body("The forest path is choked with grass grown shoulder-high. You cannot push through it."),
            .hint("Perhaps you could CUT it — if you had the right tool. Or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.back) || input.contains(Verb.south) {
            return TurnResult([], .move(.splitpath))
        }
        if state.has(.grassCut) && input.contains(Verb.north) {
            return TurnResult([], .move(.forestTrap))
        }
        if input.contains(["CUT", "SLASH", "SWORD"]) {
            guard state.has(.sword) else {
                return TurnResult([.hint("You have nothing to cut it with.")])
            }
            state.gain(.grassCut)
            return TurnResult([.body("You hack a path through the grass with your sword.")], .move(.forestTrap))
        }
        if input.contains(Flag.fireball.castSynonyms) {
            return TurnResult([.hint("Burn a whole forest down? Care will prevent 9 out of 10 forest fires.")])
        }
        return TurnResult([.hint("You could CUT the grass (with a blade), or go BACK.")])
    }
}

/// Forest trap — the net and the loyal Sylvian marksman.
struct ForestTrapRoom: RoomScript {
    let id: RoomID = .forestTrap

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A net springs from the undergrowth and hauls you off your feet."),
            .body("A hunter steps out, bow lowered when he sees your robes."),
            .speech("I recognize a mage when I see one. Kaefden to Kaefden — you must reestablish Nacastrum."),
            .body("He cuts you down and leads you deeper into the trees."),
            .hint("Go FORWARD.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .move(.silvarium))
    }
}

/// Silvarium — the great-tree city.
struct SilvariumRoom: RoomScript {
    let id: RoomID = .silvarium

    func describe(_ state: GameState) -> [StyledLine] {
        if !state.has(.forestLoreHeard) {
            return [
                .body("Before you rises an enormous tree, far larger than all the others, hung with houses and rope bridges."),
                .speech("This is my home, Silvarium. A few of us stayed. If war is coming, we will stand and fight, or we will die."),
                .hint("Climb UP into the tree, or go BACK.")
            ]
        }
        return [
            .body("The great tree of Silvarium creaks overhead."),
            .hint("Climb UP into the tree, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if !state.has(.forestLoreHeard) { state.gain(.forestLoreHeard) }
        if input.contains(Verb.up) || input.contains(Verb.north) || input.contains(["TREE", "CLIMB", "FORWARD"]) {
            return TurnResult([], .move(.treeFloor1))
        }
        if input.contains(Verb.back) || input.contains(Verb.south) {
            return TurnResult([], .move(.forestEntrance))
        }
        return TurnResult([.hint("Go UP into the tree, or BACK.")])
    }
}

/// Tree floor 1 — Marlux.
struct TreeFloor1Room: RoomScript {
    let id: RoomID = .treeFloor1

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("Tables of dressed game line the first floor. A boy eyes you nervously."),
            .speech("My name is Marlux. My dad is apart of the hunting squad. I stay here to learn."),
            .hint("Climb UP, or go DOWN.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(Verb.up) { return TurnResult([], .move(.treeFloor2)) }
        return TurnResult([], .move(.silvarium))
    }
}

/// Tree floor 2 — butcher (left) and armory (right).
struct TreeFloor2Room: RoomScript {
    let id: RoomID = .treeFloor2

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The second floor forks: a butchery to the LEFT, an armory to the RIGHT."),
            .hint("Go LEFT, RIGHT, UP, or DOWN.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LEFT", "BUTCHER"]) { return TurnResult([], .move(.treeButcher)) }
        if input.contains(["RIGHT", "ARMORY"]) { return TurnResult([], .move(.treeArmory)) }
        if input.contains(Verb.up) { return TurnResult([], .move(.treeFloor3)) }
        if input.contains(Verb.down) { return TurnResult([], .move(.treeFloor1)) }
        return TurnResult([.hint("Go LEFT, RIGHT, UP, or DOWN.")])
    }
}

/// The butcher — gives Suformin's Dagger after you explain yourself.
struct TreeButcherRoom: RoomScript {
    let id: RoomID = .treeButcher

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.dagger) {
            return [.body("The bearded butcher waves you off. \"Got what you came for. Go on.\""), .hint("Go BACK.")]
        }
        return [
            .body("A bearded man in a bear-skin cleaves a carcass."),
            .speech("The Sylvians were fine before we made that deal with those mage!"),
            .hint("You could TALK with him, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if state.has(.dagger) || input.contains(Verb.back) {
            return TurnResult([], .move(.treeFloor2))
        }
        if input.contains(Verb.talk) {
            state.gain(.dagger)
            return TurnResult([
                .speech("So you mean to open the old seal upstairs? Hmph."),
                .speech("Then you'll be needing this. Suformin help you."),
                .body("He drags a chest from beneath the table and throws back the lid."),
                .item("You take SUFORMIN'S DAGGER — a blade of cold blue metal.")
            ], .move(.treeFloor2))
        }
        return TurnResult([.hint("You could TALK, or go BACK.")])
    }
}

/// The armory — barred to non-Sylvians.
struct TreeArmoryRoom: RoomScript {
    let id: RoomID = .treeArmory

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A guard steps in front of the armory door."),
            .speech("This area is restricted to Sylvian hunters only. By those pointed ears, you're Kaefden."),
            .hint("Go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        state.gain(.armoryVisited)
        return TurnResult([], .move(.treeFloor2))
    }
}

/// Tree floor 3 — church (left) and library (right).
struct TreeFloor3Room: RoomScript {
    let id: RoomID = .treeFloor3

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The third floor forks: the Church of Suformin to the LEFT, the library to the RIGHT."),
            .hint("Go LEFT, RIGHT, UP, or DOWN.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LEFT", "CHURCH"]) { return TurnResult([], .move(.treeChurch)) }
        if input.contains(["RIGHT", "LIBRARY"]) { return TurnResult([], .move(.treeLibrary)) }
        if input.contains(Verb.up) { return TurnResult([], .move(.treeFloor4)) }
        if input.contains(Verb.down) { return TurnResult([], .move(.treeFloor2)) }
        return TurnResult([.hint("Go LEFT, RIGHT, UP, or DOWN.")])
    }
}

/// Church of Suformin — the elk-headed priestess (and the "42" gag).
struct TreeChurchRoom: RoomScript {
    let id: RoomID = .treeChurch

    func describe(_ state: GameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .body("An elk-headed priestess tends a shrine wreathed in antlers."),
            .speech("All are welcome in the Church of Suformin, God of the Hunt.")
        ]
        if state.has(.dagger) {
            lines.append(.speech("Suformin would not entrust a mortal with her dagger lightly, especially a mage. I suspect great things to come from you."))
        }
        lines.append(.hint("You could ASK her a question, or go BACK."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["ASK", "MEANING", "LIFE"]) {
            return TurnResult([.speech("The meaning of life? Forty-two, of course."), .body("(\"42.\")")])
        }
        return TurnResult([], .move(.treeFloor3))
    }
}

/// Library — the vain librarian; lore about the seal.
struct TreeLibraryRoom: RoomScript {
    let id: RoomID = .treeLibrary

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("A man in a fox-fur coat looks down his nose at you."),
            .speech("I pride myself as the number one hoarder of knowledge in this city."),
            .speech("The seal above? The same one used by the mages of old. Even our Elders could not open it — their blood isn't worthy!"),
            .hint("Go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        TurnResult([], .move(.treeFloor3))
    }
}

/// Tree floor 4 — the blood seal. Only Suformin's Dagger opens it; the neck kills.
struct TreeFloor4Room: RoomScript {
    let id: RoomID = .treeFloor4

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.stonebend) {
            return [.body("The seal lies open, the hidden chamber empty of its secret now."), .hint("Go DOWN.")]
        }
        return [
            .body("At the top of the tree, a seal is set into the wood: crossed daggers within a target."),
            .body("Dried blood crusts its grooves. It wants more."),
            .hint("You could CUT yourself (name a blade and where), or go DOWN.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if state.has(.stonebend) || input.contains(Verb.down) {
            return TurnResult([], .move(.treeFloor3))
        }
        let mentionsCut = input.contains(["CUT", "BLEED"])
        if mentionsCut && input.contains(["NECK", "THROAT"]) {
            return TurnResult([.body("You draw the blade across your throat. The seal drinks deep — too deep.")],
                              .death(reason: "Bled out on the seal. It asked for blood, not all of it."))
        }
        if mentionsCut && input.contains(["SWORD"]) {
            return TurnResult([.hint("You scrape the long sword across your palm. Nothing happens — wrong blade.")])
        }
        if mentionsCut && input.contains(["DAGGER", "SUFORMIN"]) {
            guard state.has(.dagger) else {
                return TurnResult([.hint("You don't have Suformin's Dagger.")])
            }
            state.gain(.stonebend)
            return TurnResult([
                .body("You open your palm with Suformin's blue blade. Your blood runs into the grooves and the seal blazes."),
                .body("The wood peels back on a hidden chamber, and old knowledge pours into you."),
                .item("You have learned the spell STONEBEND.")
            ], .move(.treeFloor3))
        }
        if mentionsCut {
            return TurnResult([.hint("Cut with which blade, and where? (e.g. \"cut hand with dagger\")")])
        }
        return TurnResult([.hint("You could CUT yourself with a blade, or go DOWN.")])
    }
}
