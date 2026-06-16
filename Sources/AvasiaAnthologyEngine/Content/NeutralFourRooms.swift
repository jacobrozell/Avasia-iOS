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
            .body("Wagons creak under honey and iron both — truce week ended, but merchants still test how far neutrality travels."),
            .body("Cellious's name rides on rumor: a clerk who counts deserters without choosing a banner.")
        ]
        if state.neutralThreeBrokersPeace {
            lines.append(.body("Your truce map bought you passage — no faction owns your road today."))
        } else if state.caveRecordCopiedArchive {
            lines.append(.body("Oilcloth at your hip — bark sheets that make both sides nervous. Cellious will smell the ink."))
        }
        lines.append(.hint("CONTINUE toward the gate · LOOK at the road."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("ROAD") || input.contains("WAGON") {
            return AnthologyTurnResult([
                .body("A Paladin trainee walks barefoot — gauntlet gone, eyes on the dust. Restoration guards will want his name."),
                .body("You could vanish before the gate. You could stay and make the ledger honest."),
                .hint("CONTINUE toward the gate.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the road.")])
        }
        return AnthologyTurnResult([], .move(.neutralFourGate))
    }
}

struct NeutralFourGateRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFourGate
    private let advance = ["CONTINUE", "ENTER"]
    private let talk = ["TALK", "CELLIOUS", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Kaefden Gate"),
            .body("Restoration guards search wagons. A clerk — Cellious — reads names from a ledger without looking up."),
            .body("The schism fable is carved on the gatepost in shorthand: two hands on one wrist. Cellious's pen moves like a third hand."),
            .speech("Cellious: \"Another scout between factions. You may WITNESS the count, or WALK away before your name joins it.\""),
            .hint("CONTINUE to the crowd · TALK to Cellious.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Cellious: I do not ask whose sermon you refused. I ask whether you will let erasure pass as law."),
                .speech("Cellious: Neutral ink is rare — therefore suspect. Sign anyway, or go."),
                .hint("CONTINUE to the crowd.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK to Cellious.")])
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
            .body("Restoration hardliners want names for the pyre. Agroman recruiters want names for the column. Cellious wants names for the record."),
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
        if input.contains("LOOK") || input.contains("CROWD") {
            return AnthologyTurnResult([
                .body("A fisher from Oceandale clutches empty nets. A farmhand from the valley still smells of Many Hands pamphlets."),
                .body("Neither chose a banner — both chose survival. The ledger will decide if that is crime."),
                .hint("WITNESS · WALK away.")
            ])
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
                .body("Cellious does not look up. He has seen scouts vanish before."),
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
            return [.body("Cellious at the Gate — complete."), .hint("Return to the story hub from the menu.")]
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
            .body("+\(AnthologyCatalog.meta(for: .neutralFour).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
