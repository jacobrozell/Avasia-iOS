import Foundation
import AvasiaEngine

// MARK: - Neutral #5 — The Unmarked Road

struct NeutralFiveSplitpathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFiveSplitpath
    private let advance = ["CONTINUE", "GO", "WALK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Splitpath Crossroads"),
            .body("War maps redrawn again. Market awnings fold. Traders pack before the next sermon becomes law."),
            .body("Three roads: north to Sylva, west to Agroma, east to the coast and away from both."),
            .body("The mile marker is carved with the schism fable — two hands, one wrist. Suformin keeps the ink fresh.")
        ]
        if state.neutralFourStayedWitness {
            lines.append(.body("Cellious's ledger still lists your signature — neutral ink in a partisan age."))
        } else if state.neutralThreeBrokersPeace {
            lines.append(.body("The truce map still circulates — both factions hate it equally, which means it worked once."))
        }
        lines.append(.hint("CONTINUE to the mile marker · LOOK at the roads."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("ROAD") || input.contains("MARKER") {
            return AnthologyTurnResult([
                .body("North: green smoke on the ridge, elders who trust scouts. West: column dust and Many Hands pamphlets."),
                .body("East: coast wind, no banner, no sermon — only distance."),
                .hint("CONTINUE to the mile marker.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the roads.")])
        }
        return AnthologyTurnResult([], .move(.neutralFiveMileMarker))
    }
}

struct NeutralFiveMileMarkerRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFiveMileMarker
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralFiveRoadResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Mile Marker"),
            .body("Suformin meets you where the roads fork — elk horn at his belt, truce-week hospitality in his voice even now."),
            .speech("Suformin: \"LEAVE — walk east until banners blur. Or STAY — Splitpath still needs brokers who refuse sermons.\""),
            .body("The holdfast fire is cold. The market will reopen when someone keeps it honest."),
            .hint("LEAVE the war behind · STAY on the unmarked road · TALK to Suformin.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.neutralFiveRoadResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.neutralFiveEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("TALK") || input.contains("ASK") || input.contains("SCHISM") {
            return AnthologyTurnResult([
                .speech("Suformin: Neutrality is not absence — it is work. The market does not stay honest without a hinge."),
                .speech("Suformin: Leave if you must. Stay if you can bear the weight."),
                .hint("LEAVE · STAY.")
            ])
        }
        if input.contains("LEAVE") || input.contains("EAST") || input.contains("DEPART") {
            state.neutralFiveRoadResolved = true
            state.neutralFiveStayedOnRoad = false
            return AnthologyTurnResult([
                .body("You choose distance — not denial. The coast road swallows your footprints."),
                .body("Splitpath shrinks behind you. Suformin does not call you back."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("STAY") || input.contains("REMAIN") || input.contains("BROKER") {
            state.neutralFiveRoadResolved = true
            state.neutralFiveStayedOnRoad = true
            return AnthologyTurnResult([
                .speech("Suformin: \"Then keep the market honest. Neutrality is work, not absence.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("LEAVE · STAY · TALK.")])
    }
}

struct NeutralFiveEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .neutralFiveEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.neutralFiveComplete {
            return [.body("The Unmarked Road — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.neutralFiveStayedOnRoad
            ? "Splitpath keeps you — not as hero, but as hinge. Neutrality ends where your work begins."
            : "The coast wind erases ash smell. You leave no carving, no oath — only the stories you carry unnamed."
        return [.title("Road's End"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.neutralFiveComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.neutralFive, state: &state)
        return AnthologyTurnResult([
            .title("The Unmarked Road — complete"),
            .body("+\(AnthologyCatalog.meta(for: .neutralFive).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
