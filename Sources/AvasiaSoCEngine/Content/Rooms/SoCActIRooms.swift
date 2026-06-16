import Foundation
import AvasiaEngine

// MARK: - Shared

enum SoCCataractaGate {
    static func ashesBlock(_ state: SoCGameState) -> SoCTurnResult? {
        guard state.courtyardComplete else { return nil }
        return SoCTurnResult(
            [.body("Cataracta is in ashes. There is nothing left for you here.")],
            .stay
        )
    }
}

// MARK: - Athalos

struct SoCCataractaAthalos: SoCRoomScript {
    let id: SoCRoomID = .cataractaAthalos

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        state.athalosVisitCount += 1
        return nil
    }

    func autoReturnAfterEnter(_ state: SoCGameState) -> SoCRoomID? {
        state.athalosVisitCount <= 1 ? .cataractaShopping : nil
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.athalosVisitCount <= 1 {
            return introductionLines(state)
        }
        return shopLines(state)
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }

        if state.athalosVisitCount <= 1 {
            return SoCTurnResult([], .move(.cataractaShopping))
        }

        if input.contains("BUY") && input.contains("POTION") {
            guard state.spendGold(25) else {
                return SoCTurnResult([.speech("Can't help you if you can't pay, friend.")])
            }
            state.addItem(.potion)
            return SoCTurnResult([
                .item("You buy a Health Potion for 25 gold."),
                .body("Gold: \(state.gold)"),
                .speech("Athalos: Legion discount — don't spend it all in one battle.")
            ])
        }

        if input.contains("BUY") && (input.contains("RATION") || input.contains("FOOD")) {
            guard state.spendGold(12) else {
                return SoCTurnResult([.speech("Can't help you if you can't pay, friend.")])
            }
            state.addItem(.fieldRations)
            return SoCTurnResult([
                .item("You buy Field Rations for 12 gold."),
                .body("Gold: \(state.gold)"),
                .speech("Athalos: Dried fish and hard bread. Better than starving on the march.")
            ])
        }

        if input.contains("LEAVE") || input.contains("BACK") || input.contains(Verb.south) {
            return SoCTurnResult([.body("You thank Athalos and leave.")], .move(.cataractaShopping))
        }

        return SoCTurnResult([.hint("BUY POTION (25g), BUY RATIONS (12g), or LEAVE.")])
    }

    private func introductionLines(_ state: SoCGameState) -> [StyledLine] {
        let name = state.playerName.isEmpty ? "friend" : state.playerName
        return [
            .title("Althalos' House"),
            .body("You approach Althalos' shop."),
            .body("The sight of the \"Althalos' Wares\" sign sparks memories of the eccentric shopkeeper."),
            .body("You enter and immediately notice the shop is completely absent of people, yet overstocked in goods."),
            .body("Despite the lack of business, Althalos greets you kindly."),
            .blank,
            .speech("Ah, \(name), I hear you're joining the Cataractan Legion!"),
            .speech("It's mighty brave of you to volunteer!"),
            .speech("Most would wait to be drafted, but not you!"),
            .blank,
            .speech("Listen. I wish I had something to give you, but business hasn't been so good lately."),
            .speech("Come back if you need potions or rations before the courtyard — I'll cut you a fair price."),
            .blank,
            .speech("Take care and good luck!"),
            .body("You thank Althalos and leave.")
        ]
    }

    private func shopLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Althalos' House"),
            .body("Athalos waves from behind dusty shelves of unsold wares."),
            .speech("Back again? Legion rates: potions 25 gold, field rations 12."),
            .hint("BUY POTION, BUY RATIONS, or LEAVE.")
        ]
    }
}

// MARK: - Ulric

struct SoCCataractaBlacksmith: SoCRoomScript {
    let id: SoCRoomID = .cataractaBlacksmith

    func autoReturnAfterEnter(_ state: SoCGameState) -> SoCRoomID? { .cataractaShopping }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.ulric {
            return [
                .title("Ulric's House"),
                .speech("Go bother my brother. I need to get back to work.")
            ]
        }
        return [
            .title("Ulric's House"),
            .body("You go south to Ulric's Blacksmith, a small building, with stacks of metal and materials everywhere."),
            .body("You approach Ulric, who is sitting on the steps of his house."),
            .body("He begins talking to you."),
            .blank,
            .speech("So, you've decided to join the Cataractan army? More business for me I suppose, heh."),
            .speech("Tell you what, go see my brother Doran at the pier."),
            .speech("As you know, he rents out fishing poles."),
            .speech("I bet you can find some pretty interesting stuff out there."),
            .blank,
            .speech("What I wouldn't give to be able to fish all day."),
            .speech("But, there is always work to be done."),
            .speech("Now go bother my brother.")
        ]
    }

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        if !state.ulric && !state.doran {
            state.ulric = true
        }
        return nil
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }
        return SoCTurnResult([], .move(.cataractaShopping))
    }
}

// MARK: - Doran pier

struct SoCCataractaPier: SoCRoomScript {
    let id: SoCRoomID = .cataractaPier

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        var lines: [StyledLine] = [
            .title("Doran's Pier"),
            .body("You enter the fishing hut posted along side the Varatho river."),
            .body("The hut reeks of fish and bait."),
            .body("Various fishing poles line the walls in all shapes, sizes, and colors."),
            .blank
        ]
        if !state.doran {
            lines += [
                .body("Doran, who appears to be the owner, hears you enter and calls from a back room with a rough, agitated voice."),
                .speech("Oi! Whatya be doin' in my hut?"),
                .blank,
                .body("You explain that you saw the pier and wanted to take a closer look."),
                .blank,
                .speech("Hmm.. Doran hums before responding. I don't allow many people to come visit."),
                .speech("To many of these landfolk don't have any appreciation for the river or my pier."),
                .speech("Perhaps for a few gold, you can take a look. Think of it as insurance."),
                .speech("I'll even let you borrow a fishing rod and some bait.")
            ]
            state.doran = true
        } else {
            lines.append(.speech("Welcome back! You here to fish or just stand there?"))
        }
        return lines
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [.speech("What do ye say? 15 gold?")]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }

        if input.contains("YES") {
            if state.ulric {
                let lines: [StyledLine] = [
                    .body("You explain to Doran that his brother, Ulric, sent you."),
                    .blank,
                    .speech("Ay', you spoke to Ulric, did ye?"),
                    .speech("He's always leading people over here to 'help the business out', as he puts it."),
                    .speech("I think he sends 'em here so he isn't bothered."),
                    .speech("I'm sure he told you that I'd let you borrow a fishing pole to fish for a bit."),
                    .speech("Fine, here. Go ahead. Just make sure you're kind to the river and don't ruin my pier!"),
                    .blank,
                    .body("Doran hands you an old fishing rod and some bait then points you towards the door to the pier."),
                    .blank,
                    .speech("Becareful not to fall in the river."),
                    .speech("Varatho ain't a kind beast to those who swim her rapids.")
                ]
                state.unlockTrophy(.brother)
                state.ulric = false
                return SoCTurnResult(lines, .move(.cataractaFishing))
            }
            if state.spendGold(15) {
                let lines: [StyledLine] = [
                    .body("You pay Doran 15 gold."),
                    .body("Gold: \(state.gold)"),
                    .body("He hands you an old fishing rod and some bait then points toward the door to the pier."),
                    .blank,
                    .speech("Becareful not to fall in the river."),
                    .speech("Varatho ain't a kind beast to those who swim her rapids.")
                ]
                return SoCTurnResult(lines, .move(.cataractaFishing))
            }
            return SoCTurnResult([.speech("Simple yes or no, boy.")])
        }

        if input.contains("NO") || input.contains("LEAVE") {
            return SoCTurnResult([
                .blank,
                .speech("Then what're you doin' standin' around here for?"),
                .speech("You change your mind, you come see me."),
                .blank,
                .body("You leave the pier.")
            ], .move(.cataractaShopping))
        }

        return SoCTurnResult([.speech("Simple yes or no, boy.")])
    }
}

// MARK: - Fishing

struct SoCCataractaFishing: SoCRoomScript {
    let id: SoCRoomID = .cataractaFishing

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        if state.fishingSession == nil {
            state.fishingSession = SoCFishingSession(baitRemaining: Int.random(in: 4...7))
        }
        return nil
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Fishing"),
            .body("You see the rippling water surrounding you."),
            .body("You feel the cool breeze of you the wind over the water."),
            .hint("Throw your cast in the water? (yes / no)")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }

        guard var session = state.fishingSession else {
            state.fishingSession = SoCFishingSession(baitRemaining: Int.random(in: 4...7))
            return SoCTurnResult(describe(state))
        }

        if input.contains("NO") || input.contains("N") {
            state.fishingSession = nil
            return SoCTurnResult([
                .body("You thank Doran and return the fishing pole."),
                .body("You leave the pier.")
            ], .move(.cataractaShopping))
        }

        guard input.contains("YES") || input.contains("Y") else {
            return SoCTurnResult([.hint("Throw your cast in the water? (yes / no)")])
        }

        var lines: [StyledLine] = []
        let roll = Int.random(in: 1...10)

        switch roll {
        case 1 where !session.caughtOldShoe:
            session.caughtOldShoe = true
            state.addItem(.oldShoe)
            lines += [
                .item("You fish up an Old-shoe!"),
                .body("Old-shoe: 2 gold, An old shoe covered in mud and seaweed.")
            ]
        case 1:
            lines.append(.body("Whole lot of nothing..."))

        case 2 where !session.caughtSmallFish:
            session.caughtSmallFish = true
            state.addItem(.smallFish)
            lines += [
                .item("You fish up a Small Fish!"),
                .body("Small Fish: 5 gold, When consumed it restores 5hp")
            ]
        case 2:
            lines.append(.body("Whole lot of nothing..."))

        case 3...5:
            let amount = Int.random(in: 1...20)
            state.addGold(amount)
            lines += [
                .item("You fish up a Soggy-Money Purse!"),
                .body("You add \(amount) gold to your backpack!"),
                .body("Gold: \(state.gold)")
            ]

        case 6 where !session.caughtBigFish:
            session.caughtBigFish = true
            state.addItem(.bigFish)
            lines += [
                .item("You fish up a Big Fish!"),
                .body("Big Fish: 10 gold, When consumed it restores 10hp")
            ]
        case 6:
            lines.append(.body("Whole lot of nothing..."))

        case 7 where !session.caughtCrab:
            session.caughtCrab = true
            state.addItem(.crab)
            lines += [
                .item("You fish up a Crab!"),
                .body("Crab: 15 gold, When consumed, it restores 15 hp")
            ]
        case 7:
            lines.append(.body("Whole lot of nothing..."))

        default:
            lines += [
                .body("You fish up a heavy amount of seaweed."),
                .body("You throw it back over the pier.")
            ]
        }

        session.baitRemaining -= 1
        state.fishingSession = session

        if session.baitRemaining == 0 {
            state.fishingSession = nil
            if !state.trophies.contains(.fished) {
                state.unlockTrophy(.fished)
                lines.append(.symbol("Trophy unlocked: Gone Fishin'"))
            }
            lines += [
                .body("You ran out of bait!"),
                .body("You thank Doran and return the fishing pole."),
                .body("You leave the pier.")
            ]
            return SoCTurnResult(lines, .move(.cataractaShopping))
        }

        lines.append(.body("It seems you have enough bait to last \(session.baitRemaining) casts."))
        lines.append(.hint("Throw your cast in the water? (yes / no)"))
        return SoCTurnResult(lines)
    }
}

// MARK: - Garden

struct SoCCataractaGarden: SoCRoomScript {
    let id: SoCRoomID = .cataractaGarden

    func describe(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Castle Garden"),
            .body("Around the garden are young druid children playing while their parents socialize."),
            .body("In front of you is a fountain made of the blue crystal, Anula."),
            .body("The fountain is filled with gold pieces, scattered around the base, most of which are on tails."),
            .hint("What would you like to do?")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }

        if input.contains("COIN") || input.contains("THROW") {
            guard !state.fountain else {
                return SoCTurnResult([.body("You already tossed a coin in the water.")])
            }
            guard state.spendGold(1) else {
                return SoCTurnResult([.body("You don't have any gold to toss.")])
            }
            state.fountain = true
            if Bool.random() {
                return SoCTurnResult([
                    .body("You toss a gold piece into the water and it lands on heads!"),
                    .body("Nothing happens."),
                    .body("I guess some things just aren't worth doing.")
                ])
            }
            state.fountainLuck = true
            state.playerLuck += 1
            return SoCTurnResult([
                .body("You toss a gold piece into the water and it lands on tails."),
                .body("The Anula crystal hums faintly. You feel a whisper of luck."),
                .body("Maybe the boy was right after all.")
            ])
        }

        if input.contains("LOOK") || input.contains("SEARCH") {
            return SoCTurnResult([
                .body("You decide to take a look around."),
                .body("People sit by the fountain — a couple holding hands, an elder reading a dispatch from Silvarium."),
                .body("You catch the word Paladin before the page is folded away."),
                .body("A young child guides his hands through the cool Anula water.")
            ])
        }

        if input.contains("TALK") || input.contains("APPROACH") || input.contains("SPEAK") || input.contains("PEOPLE") {
            var lines: [StyledLine] = [
                .body("You approach the young boy by the crystal fountain."),
                .blank,
                .speech("My parents say that if you toss some gold in the fountain, it brings good luck!"),
                .speech("I don't know if I believe in stuff like that though..."),
                .body("The young boy walks off.")
            ]
            if !state.gardenInsight {
                state.gardenInsight = true
                lines.append(contentsOf: SoCQuestProgress.grantQuestExp(10, state: &state))
            }
            return SoCTurnResult(lines)
        }

        if input.contains("LEAVE") || input.contains("BACK") || input.contains("RETURN") || input.contains("WEST") {
            return SoCTurnResult([], .move(.cataractaNorth))
        }

        return SoCTurnResult([.hint("COIN, LOOK, TALK, or LEAVE.")])
    }
}
