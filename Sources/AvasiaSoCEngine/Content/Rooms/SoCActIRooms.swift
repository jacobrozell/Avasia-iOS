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

        if input.contains(Verb.look) || input.contains("SEARCH") {
            return SoCTurnResult([
                .body("Dusty ledgers list potion sales beside coalition requisition tallies."),
                .speech("Gift crystal on the shelf, war debt in the ledger — same blue, different math.")
            ])
        }

        return SoCTurnResult([.hint("BUY POTION (25g), BUY RATIONS (12g), LOOK, or LEAVE.")])
    }

    private func introductionLines(_ state: SoCGameState) -> [StyledLine] {
        let name = state.playerName.isEmpty ? "friend" : state.playerName
        return [
            .title("Athalos' House"),
            .body("The shop is overstocked and empty of customers — shelves groaning, bell silent."),
            .body("Athalos greets you anyway, as if trade were still a kindness."),
            .blank,
            .speech("Ah, \(name) — enlisting today?"),
            .speech("Brave. Most wait for the draft."),
            .blank,
            .speech("I wish I had a send-off gift. Business is thin."),
            .speech("If Kaefden's coalition starts buying Anula by the crate, maybe I'll clear this dust."),
            .speech("Come back before the courtyard if you need potions or rations — legion rates."),
            .blank,
            .speech("Good luck out there."),
            .body("You thank Athalos and leave.")
        ]
    }

    private func shopLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .title("Athalos' House"),
            .body("Athalos waves from behind dusty shelves."),
            .speech("Legion rates: potions 25 gold, field rations 12."),
            .hint("BUY POTION, BUY RATIONS, LOOK, or LEAVE.")
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
            .body("Smoke and hammer-song spill from Ulric's forge."),
            .body("Anula dust winks in the coal — blue sparks, pretty curse."),
            .body("Ulric sits on the stoop, arms folded."),
            .blank,
            .speech("Joining the Legion? Good for my ledger."),
            .speech("Plate needs Sylvian shavings. Kimious pays; Kaefden's clerks count every flake."),
            .speech("Go bother my brother Doran at the pier — he'll lend you a rod if you sweet-talk him."),
            .speech("Or tell him I sent you and skip the fee."),
            .blank,
            .speech("I'd fish all day if the war drums would quiet."),
            .speech("Now move — I have orders to fill.")
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
            .body("You step into the fishing hut perched alongside the Varatho."),
            .body("Fish and bait hang in the air. Poles line the walls in every size and color."),
            .blank
        ]
        if !state.doran {
            lines += [
                .body("Doran calls from the back room, voice rough with annoyance."),
                .speech("Oi! What're you doin' in my hut?"),
                .blank,
                .body("You say you wanted a look at the pier."),
                .blank,
                .speech("Hmm. Doran hums. Don't get many who respect the river."),
                .speech("Too many landfolk treat Varatho like a puddle."),
                .speech("Fifteen gold — call it insurance — and I'll lend you a rod and bait."),
                .speech("Or walk. Your coin, your risk.")
            ]
            state.doran = true
        } else {
            lines.append(.speech("Back again? Fishin', or just breathin' my air?"))
        }
        return lines
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.doran {
            return [
                .speech("What do ye say? 15 gold?"),
                .hint("YES or NO — LOOK at the river crates, TALK to Doran.")
            ]
        }
        return [StyledLine.speech("What do ye say? 15 gold?")]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if let block = SoCCataractaGate.ashesBlock(state) { return block }

        if input.contains(Verb.look) || input.contains("CRATE") || input.contains("RIVER") {
            return SoCTurnResult([
                .body("Through the pier shutters, river crates bear Aylova tally marks — Anula requisition, stamped for the pact."),
                .body("A dockhand mutters that King's war chest buys crystal now; river folk pay in fish and silence.")
            ])
        }

        if input.contains(["TALK", "DORAN", "ASK", "ANULA", "REQUISITION"]) {
            return SoCTurnResult([
                .speech("Aylova clerks came through last week — counted every blue shaving in my tackle like royal tax."),
                .speech("Ulric says it's for Kimious and the legion. I say Varatho won't care whose war she's fueling when the nets go empty."),
                .speech("Use what you must, chain what you can — that's what the broadsheets say Kaefden swears now. Easy for a king.")
            ])
        }

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
                    .speech("Be careful on the planks."),
                    .speech("Varatho ain't kind to swimmers.")
                ]
                state.unlockTrophy(.brother)
                state.ulric = false
                return SoCTurnResult(lines, .move(.cataractaFishing))
            }
            if state.spendGold(15) {
                let lines: [StyledLine] = [
                    .body("You pay Doran 15 gold."),
                    .body("Gold: \(state.gold)"),
                    .body("He hands you an old fishing rod and bait, then points you toward the pier door."),
                    .blank,
                    .speech("Be careful on the planks."),
                    .speech("Varatho ain't kind to swimmers.")
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
            .body("Druid children chase each other between hedges while parents trade gossip in the shade."),
            .body("At the center, an Anula fountain throws blue light across scattered coins — most landed tails-up."),
            .hint("COIN, LOOK, TALK, or LEAVE south to North Cataracta.")
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
                    .body("You toss a gold piece. It lands heads-up and sinks without a ripple."),
                    .body("The fountain keeps its luck for someone else today.")
                ])
            }
            state.fountainLuck = true
            state.playerLuck += 1
            return SoCTurnResult([
                .body("You toss a gold piece. It lands tails-up in the Anula basin."),
                .body("The crystal hums faintly. You feel a whisper of luck."),
                .body("Maybe the boy was right after all.")
            ])
        }

        if input.contains(Verb.look) || input.contains("SEARCH") {
            return SoCTurnResult([
                .body("Couples linger by the water. An elder folds a Silvarium dispatch too quickly to read."),
                .body("You catch Paladin and requisition before the page disappears."),
                .body("Gift becomes ledger, he mutters — Kaefden's war will price everything."),
                .body("A child trails fingers through the cool Anula. The fountain feels older than today's rumors.")
            ])
        }

        if input.contains("TALK") || input.contains("APPROACH") || input.contains("SPEAK") || input.contains("PEOPLE") {
            var lines: [StyledLine] = [
                .body("A boy watches the coins at the fountain's lip."),
                .blank,
                .speech("Mom says tails in the water brings luck."),
                .speech("Heads just buys the fish a snack. I don't know if I believe it."),
                .body("He runs off to chase a friend.")
            ]
            if !state.gardenInsight {
                state.gardenInsight = true
                lines.append(contentsOf: SoCQuestProgress.grantQuestExp(10, state: &state))
            }
            return SoCTurnResult(lines)
        }

        if input.contains("LEAVE") || input.contains("BACK") || input.contains("RETURN") || input.contains(Verb.south) {
            return SoCTurnResult([], .move(.cataractaNorth))
        }

        return SoCTurnResult([.hint("COIN, LOOK, TALK, or LEAVE.")])
    }
}
