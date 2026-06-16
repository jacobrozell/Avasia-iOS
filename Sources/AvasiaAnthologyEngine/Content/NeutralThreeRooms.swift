import Foundation
import AvasiaEngine

// MARK: - Neutral #3 — Two Hands Market (mirror of council / oath)

struct NeutralThreeMarketRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralThreeMarket
    private let advance = ["CONTINUE", "GO", "ENTER"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Splitpath Market"),
            .body("No banners today — only awnings, spice smoke, and traders who remember the elk feast horn."),
            .body("Suformin's holdfast is two valleys east. Here, neutrality is commerce with a knife under the counter."),
            .body("Word traveled: you walked the prison caves. Both sides think your memory belongs to them.")
        ]
        if state.caveRecordCopiedArchive {
            lines.append(.body("Oilcloth bulges at your hip — bark sheets the court never saw."))
        } else {
            lines.append(.body("You carry no sheets — only the schism fable etched behind your eyes and \"Both. Always both.\" on the cave wall."))
        }
        lines.append(.hint("CONTINUE into the trader row · LOOK at the stalls · TALK to a trader."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("TALK") || input.contains("TRADER") {
            return AnthologyTurnResult([
                .speech("Trader: Cave gossip pays better than honey this week. Name a Paladin, name a price."),
                .speech("You: I name no one until I know who listens."),
                .hint("CONTINUE into the trader row.")
            ])
        }
        if input.contains("LOOK") || input.contains("STALL") {
            return AnthologyTurnResult([
                .body("Sylvian honey beside Agroman iron. A neutral broker weighs coin without asking whose war paid for it."),
                .body("The schism fable is chalked on a tent flap — two hands, one wrist. Someone keeps redrawing it when rain washes it away."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK · TALK.")])
        }
        return AnthologyTurnResult([], .move(.neutralThreeTraderRow))
    }
}

struct NeutralThreeTraderRowRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralThreeTraderRow
    private let advance = ["CONTINUE", "GO"]
    private let talk = ["TALK", "FACTOR", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Trader Row"),
            .speech("Sylvian factor: \"Name the Agroman elder who signed the grain truce — we pay in silver, not sermons.\""),
            .speech("Agroman quartermaster: \"Name the Paladin who looked away at Oceandale — we pay in salt.\""),
            .body("Suformin warned you at the elk feast: two hands on one wrist. The market wants you to pick a hand."),
            .body("Nacastrum's court and Vashirr's rite ring ask the same question in different costumes."),
            .hint("CONTINUE to the schism stall · TALK to the factor.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Sylvian factor: Restoration summaries lie by omission. Your cave copy could embarrass ministers."),
                .speech("Agroman quartermaster: Or embarrass us. Either way — coin talks when banners won't."),
                .hint("CONTINUE to the schism stall.")
            ])
        }
        if input.contains("LOOK") || input.contains("ROW") {
            return AnthologyTurnResult([
                .body("Children chase each other between salt sacks and honey jars — truce week ended, but habit dies slow."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK.")])
        }
        return AnthologyTurnResult([], .move(.neutralThreeSchismStall))
    }
}

struct NeutralThreeSchismStallRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralThreeSchismStall
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralThreeStallResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Schism Stall"),
            .body("A neutral broker folds her hands — mirror of the cave graffiti. Same beat as Nacastrum's court and Vashirr's ring."),
            .body("She slides chalk between them: a map of Splitpath markets, witness points, truce-week routes — incomplete, usable, honest."),
            .speech("Broker: \"BROKER — make them bid for a shared truce map. Or LEAN — sell the truth to one side and vanish rich.\""),
            .hint("BROKER a truce · LEAN toward one buyer · LOOK at the map.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.neutralThreeStallResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.neutralThreeAftermath))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("LOOK") || input.contains("MAP") || input.contains("CHALK") {
            return AnthologyTurnResult([
                .body("Neither faction owns every line — that is the point. Propaganda offices want villains; the map wants witnesses."),
                .hint("BROKER · LEAN.")
            ])
        }
        if input.contains("BROKER") || input.contains("TRUCE") || input.contains("BOTH") {
            state.neutralThreeStallResolved = true
            state.neutralThreeBrokersPeace = true
            return AnthologyTurnResult([
                .body("You make them bid on a shared witness list — incomplete, honest, usable by neither propaganda office."),
                .body("Silver and salt change hands in equal measure. Neither side leaves happy. Both leave alive."),
                .speech("Broker: \"You stayed between. That is its own allegiance.\""),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("LEAN") || input.contains("SELL") || input.contains("BUYER") {
            state.neutralThreeStallResolved = true
            state.neutralThreeBrokersPeace = false
            let leanLine = state.caveRecordCopiedArchive
                ? "You slide a copied sheet under the salt sacks. Silver heavy — blame lighter."
                : "You whisper two names you memorized from the pink cavern. Coin changes hands; your conscience does not."
            return AnthologyTurnResult([
                .body(leanLine),
                .body("The broker counts without looking at you. Neutrality, traded for coin, is still a choice."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("BROKER · LEAN · LOOK.")])
    }
}

struct NeutralThreeAftermathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralThreeAftermath
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralThreeBrokersPeace {
            return [
                .title("Market Close"),
                .body("Traders leave grumbling but alive. The broker nods — no oaths, no glass dome, just a ledger both sides hate equally."),
                .body("Suformin would call this truce week extended by commerce. Cellious would call it evidence."),
                .hint("CONTINUE.")
            ]
        }
        return [
            .title("Market Close"),
            .body("One faction counts new leverage; the other curses your back. Neutrality bought you coin — not friends."),
            .body("The chalk map is gone — scraped clean before couriers arrive. You kept the memory. They kept the silver."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralThreeEpilogue))
    }
}

struct NeutralThreeEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralThreeEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralThreeComplete {
            return [.body("Two Hands Market — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.neutralThreeBrokersPeace
            ? "Splitpath sleeps without a banner night. You refused court, oath, and easy coin — and still moved the world a finger-width."
            : "You walk away richer and narrower. The valley will call it betrayal or pragmatism depending on who eats first."
        return [.title("Dusk on Splitpath"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.neutralThreeComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.neutralThree, state: &state)
        return AnthologyTurnResult([
            .title("Two Hands Market — complete"),
            .body("+\(AnthologyCatalog.meta(for: .neutralThree).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
