import Foundation
import AvasiaEngine

// MARK: - Neutral #4 — Cellious at the Gate

struct NeutralFourKaefdenRoadRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFourKaefdenRoad
    private let advance = ["CONTINUE", "GO", "WEST"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Road to Kaefden"),
            .body("Splitpath traders pointed you west — not to Nacastrum's float, but the mainland gate where Restoration law meets everyday feet."),
            .body("Cellious's name rides on rumor: a clerk who counts deserters without choosing a banner.")
        ]
        if state.neutralThreeBrokersPeace {
            lines.append(.body("Your truce map bought you passage — no faction owns your road today."))
        }
        lines.append(.hint("CONTINUE toward the gate."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralFourGate))
    }
}

struct NeutralFourGateRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFourGate
    private let advance = ["CONTINUE", "ENTER"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Kaefden Gate"),
            .body("Restoration guards search wagons. A clerk — Cellious — reads names from a ledger without looking up."),
            .speech("Cellious: \"Another scout between factions. You may WITNESS the count, or WALK away before your name joins it.\""),
            .hint("CONTINUE to the crowd.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.neutralFourCrowd))
    }
}

struct NeutralFourCrowdRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFourCrowd
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralFourCrowdResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Deserter Crowd"),
            .body("Farmhands, fishers, a Paladin trainee who threw his gauntlet in the mud — all waiting to be counted."),
            .hint("WITNESS for the record · WALK away unmarked.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.neutralFourCrowdResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.neutralFourEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("WITNESS") || input.contains("STAY") || input.contains("RECORD") {
            state.neutralFourCrowdResolved = true
            state.neutralFourStayedWitness = true
            return AnthologyTurnResult([
                .speech("You: Count them fairly. No side gets to erase the ones who refused both sermons."),
                .speech("Cellious: Then sign beside me. Neutral ink — rare and therefore suspect."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("WALK") || input.contains("LEAVE") || input.contains("AWAY") {
            state.neutralFourCrowdResolved = true
            state.neutralFourStayedWitness = false
            return AnthologyTurnResult([
                .body("You melt into the road dust. The ledger closes without your name — for now."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("WITNESS · WALK")])
    }
}

struct NeutralFourEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFourEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralFourComplete {
            return [.body("Cellious at the Gate — complete.")]
        }
        let line = state.neutralFourStayedWitness
            ? "Your signature sits between factions — not loyalty, but refusal to let erasure pass as law."
            : "Kaefden's gate shrinks behind you. Neutrality sometimes means the record never knew you were there."
        return [.title("Western Dusk"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.neutralFourComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.neutralFour, state: &state)
        return AnthologyTurnResult([
            .title("Cellious at the Gate — complete"),
            .body("+\(AnthologyCatalog.meta(for: .neutralFour).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
