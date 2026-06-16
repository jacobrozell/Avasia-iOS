import Foundation

// The Forest / Silvarium region (north of Splitpath). Text reproduced verbatim
// from GameDriver.py (typos/jokes preserved). Mechanics unchanged.

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
        if input.contains(Flag.levitate.castSynonyms) {
            return TurnResult([
                .body("You can't simply use levitate to escape all your problems."),
                .body("Try something else.")
            ])
        }
        if input.contains(["CUT", "SLASH", "SWORD"]) {
            guard state.has(.sword) else {
                return TurnResult([.hint("You have nothing to cut it with.")])
            }
            state.gain(.grassCut)
            return TurnResult([.body("You hack a path through the grass with your sword.")], .move(.forestTrap))
        }
        if input.contains(Flag.fireball.castSynonyms) {
            return TurnResult([.hint("Care will prevent 9 out of 10 forest fires. In other words... No.")])
        }
        return TurnResult([.hint("You could CUT the grass (with a blade), or go BACK.")])
    }
}

/// Forest trap — the net and the loyal Sylvian marksman.
struct ForestTrapRoom: RoomScript {
    let id: RoomID = .forestTrap

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The forest is full of lush flora and fauna. The grass makes it difficult to see where you're walking."),
            .body("Unfortunately, you manage to accidentally spring some sort of trap!"),
            .body("The sword falls from your hand. You are now caught in a net suspended about seven feet from the ground."),
            .body("A man approaches — a longbow on his back, a knife in his hand — and cuts you free."),
            .blank,
            .speech("Look what we have here."),
            .speech("I recognize a mage when I see one. You sure have your work cut out for you."),
            .speech("Kaefden to Kaefden, you must reestablish Nacastrum as the great city it once was."),
            .speech("And with it, unite the mages of Avasia."),
            .speech("A few of us decided to stay. This is our homeland, and if war is coming, we will stand and fight or we will die."),
            .speech("Word from Aylova says Vashirr preaches magic for soldiers now — Many Hands, they call it. We still trust towers and blood."),
            .speech("It's in my people's best interest to help you. Follow me."),
            .body("You follow steadfast, feeling a bond between your fellow Kaefden."),
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
                .body("Before you lies an enormous tree, much larger than all the others in the forest."),
                .body("Around the trunk are numerous houses suspended above the ground, linked by makeshift bridges."),
                .blank,
                .speech("This is my home, Silvarium. My people have lived here for centuries."),
                .speech("When my ancestors joined the Kaefden faction, your people, the mages, gave us a gift."),
                .speech("The druids of Cataracta sent cartloads of Anula — blue crystal for our shrines and gates."),
                .speech("The Elders kept this spell in secretism, wanting to keep all marksmen equal."),
                .speech("The spell is kept at the very top of the tree, where the Elders resided."),
                .speech("When my people went north to escape the barbarians, they sealed the upper chamber."),
                .speech("Venture on, brother, and reunite our people before it is too late."),
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
            .body("Around the room you see numerous tables set up."),
            .body("Residents bring game in and drop it off here before returning to hunt."),
            .body("A young boy appears frightened by you, but strikes up a conversation when you get near."),
            .speech("My name is Marlux. My dad is apart of the hunting squad. I stay here to learn."),
            .speech("I've never seen you here before. Well I need to get back to my class."),
            .hint("A staircase leads UP. The gate leads DOWN and outside.")
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
            .body("The second floor's atrium forks: a butchery to the LEFT, an armory to the RIGHT."),
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

/// The butcher — gives Suformin's Dagger.
struct TreeButcherRoom: RoomScript {
    let id: RoomID = .treeButcher

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.dagger) {
            return [
                .body("The men are far too busy to be bothered by your presence."),
                .body("There isn't anything here left for you to do."),
                .hint("Go BACK.")
            ]
        }
        return [
            .body("You walk into the room and immediately you're hit with the smell of raw animal meat."),
            .body("A very large man with a long bushy beard, clothed in bear skin, notices you enter."),
            .speech("You there! What is a mage doing in my butchery? Can't you see that I am busy feeding my people?"),
            .hint("You could TALK / explain yourself, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if state.has(.dagger) || input.contains(Verb.back) {
            return TurnResult([], .move(.treeFloor2))
        }
        if input.contains(Verb.talk) || input.contains(["EXPLAIN"]) {
            state.gain(.dagger)
            return TurnResult([
                .body("You explain that you're trying to unlock Nacastrum and need something kept here to do it."),
                .speech("You need a spell? You mean the one those damned Elders traded our pride for?"),
                .speech("The Sylvians were fine before we made that deal with those mage!"),
                .speech("But since you're here to get rid of it, I may have something to help you. Wait here."),
                .body("He returns with a small, dusty chest the fled Elders left behind, and hands it to you."),
                .blank,
                .body("You dig up a dagger that looks like nothing you've ever seen."),
                .body("The hilt is wrapped in dark leather; the cross-guards form what looks like mandibles."),
                .body("The blade is razor sharp and made of a metal unknown to you. The metal is a clear blue — Anula."),
                .item("You received Dagger!"),
                .body("You put the dagger away and head back to the atrium.")
            ], .move(.treeFloor2))
        }
        return TurnResult([.hint("You could TALK, or go BACK.")])
    }
}

/// The armory — barred to non-Sylvians.
struct TreeArmoryRoom: RoomScript {
    let id: RoomID = .treeArmory

    func describe(_ state: GameState) -> [StyledLine] {
        if state.has(.armoryVisited) {
            return [
                .body("You don't get very far before you are stopped by a guard."),
                .speech("Kaefden! Didn't I tell you that you're not allowed here? Off with you!"),
                .hint("Go BACK.")
            ]
        }
        return [
            .body("You enter a room full of assorted weaponry — bows, swords, daggers — all custom made for the Sylvian people."),
            .body("You don't get very far before you are stopped by a guard."),
            .speech("Stop right there! This area is restricted to Sylvian hunters only."),
            .speech("By those pointed ears and the robes you're wearing I can see that you are Kaefden."),
            .hint("You can EXPLAIN yourself, or turn BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["EXPLAIN", "TALK"]) && !state.has(.armoryVisited) {
            state.gain(.armoryVisited)
            return TurnResult([
                .body("You explain that you're trying to get to Nacastrum and need something kept here."),
                .speech("All that we keep here are bows and blades reserved for Sylvians."),
                .speech("Whatever you're looking for, you'll have to look elsewhere. Now off with you!")
            ], .move(.treeFloor2))
        }
        if input.contains(Flag.fireball.castSynonyms) || input.contains(["ATTACK", "SWORD"]) {
            return TurnResult([
                .body("Attacking an ally makes you no better than the Barbarians."),
                .body("Besides, you're inside a giant tree.")
            ])
        }
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

/// Church of Suformin — the elk-headed priestess. Off-path lore + the "42" gag.
struct TreeChurchRoom: RoomScript {
    let id: RoomID = .treeChurch

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("You head in to what appears to be a place of worship. At the front of the room is a statue."),
            .body("Civilians approach and pray to the statue — some kind of shrine."),
            .body("A woman in an elk's head and strange animal skins attends to them."),
            .speech("Greetings, mage. All are welcome in the Church of Suformin, God of the Hunt. What can I do for you?"),
            .hint("You could ASK about SUFORMIN, ANULA, the DAGGER, or another question — or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["MEANING", "LIFE"]) {
            return TurnResult([.speech("42.")], events: [.heard42])
        }
        if input.contains(["SUFORMIN", "GOD", "HUNT"]) {
            return TurnResult([
                .speech("Ah! Suformin is the God of the Hunt, our mistress of the kill. We owe our lives to her."),
                .speech("When we first left Aylova in search of a new home, it was Suformin who showed us this place."),
                .speech("When she ascended, she entrusted her dagger to one worthy hunter — he founded our elder line."),
                .speech("Those who left turned their backs on her and will face her wrath in due time.")
            ])
        }
        if input.contains(["ANULA", "CRYSTAL", "BLUE"]) {
            return TurnResult([
                .speech("Anula is earth-gift — blue crystal from living stone. The druids share it; we light our shrines with it."),
                .speech("It is not coin. Not yet. The elders say what is given freely must not be weighed."),
                .speech("I pray they are right.")
            ])
        }
        if input.contains(["DAGGER", "BLADE", "SUFORMIN'S"]) {
            if state.has(.dagger) {
                return TurnResult([
                    .speech("What is this? Where did you find this? This is Suformin's dagger!"),
                    .speech("Suformin would not entrust a mortal with her dagger lightly, especially a mage."),
                    .speech("If you weren't meant to have her dagger, you would not have it now."),
                    .speech("Take great care of it. I suspect great things to come from you.")
                ])
            }
            return TurnResult([
                .speech("If by 'dagger' you mean the one Suformin is holding,"),
                .speech("That blade was a knife she used to hunt and slay her enemies."),
                .speech("No one knows where the dagger is kept. Only the one who is supposed to find it will find it.")
            ])
        }
        if input.contains(["ASK", "QUESTION"]) {
            return TurnResult([.speech("I don't understand the question.")])
        }
        return TurnResult([], .move(.treeFloor3))
    }
}

/// Library — the vain librarian; off-path lore about the seal and the mages.
struct TreeLibraryRoom: RoomScript {
    let id: RoomID = .treeLibrary

    func describe(_ state: GameState) -> [StyledLine] {
        [
            .body("The library walls are absolutely covered in bookcases of old texts."),
            .body("A man donned in an exquisite fox coat greets you — clearly the head of the library."),
            .speech("Welcome, Mage. I pride myself as the number one hoarder of knowledge in this city."),
            .speech("Should I find you mistreating any of the books here, I will have you fed to angry, starving wolves."),
            .speech("Now that you know how things work here, what can I do for you?"),
            .hint("You could EXPLAIN your task, ASK about the MAGES or ANULA, or go BACK.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["MAGE", "MAGES"]) {
            return TurnResult([
                .speech("Ah, the mage. A proud and knowledgeable people. They live up in their floating city of Nacastrum. Or at least they used to."),
                .speech("They lived there up until your king, Vashirr, saved them from the barbarians by banishing them from the city."),
                .speech("I was excited to hear that they were going to give us a spell as a sort of peace offering."),
                .speech("And then those damned Elders sealed it up and saved it for themselves."),
                .speech("I've heard rumors that the Elders themselves have been unable to open the seal. It seems that their blood isn't worthy!")
            ])
        }
        if input.contains(["ANULA", "CRYSTAL", "BLUE"]) {
            return TurnResult([
                .speech("Anula? The druids cart it in from the mountains. Blue shards for lamps and gate-work."),
                .speech("The elders count every crate when it arrives — and again when the war drums sound."),
                .speech("If you're asking whether I'd sell you some, the answer is no. I'm a librarian, not a merchant.")
            ])
        }
        if input.contains(["EXPLAIN", "TASK", "SEAL"]) {
            return TurnResult([
                .speech("So you seek the knowledge those Elders sealed away."),
                .speech("Unfortunately for you, I have no idea how to get what ever lies behind the seal."),
                .speech("The only thing I can tell you is that the seal is the same one used by the mages of old, but surely you know that.")
            ])
        }
        return TurnResult([], .move(.treeFloor3))
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
            .hint("You could CUT yourself (name a blade and where), LOOK at the seal, or go DOWN.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult {
        if input.contains(["LOOK", "EXAMINE", "SEAL"]) && !state.has(.stonebend) {
            return TurnResult([
                .body("Mage-blood in the grooves — power tied to lineage, not market."),
                .body("Sylvian hunter blood could not answer — only the line Malkos bred for the sky."),
                .body("Stonebend waits behind consent written in crimson. Vashirr would call that weakness.")
            ])
        }
        if state.has(.stonebend) || input.contains(Verb.down) {
            return TurnResult([], .move(.treeFloor3))
        }
        let mentionsCut = input.contains(["CUT", "BLEED"])
        if mentionsCut && input.contains(["NECK", "THROAT"]) {
            return TurnResult([
                .body("You cut your neck open and watch your blood spew onto the ground."),
                .body("It's too late before you realize that was a horrible idea."),
                .body("Your vision fades to black and darkness consumes you....")
            ], .death(.neckCut))
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
                .item("You obtained the spell Stonebend!")
            ], .move(.treeFloor3))
        }
        if mentionsCut {
            return TurnResult([.hint("Cut with which blade, and where? (e.g. \"cut hand with dagger\")")])
        }
        return TurnResult([.hint("You could CUT yourself with a blade, or go DOWN.")])
    }
}
