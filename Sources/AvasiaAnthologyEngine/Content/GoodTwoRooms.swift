import Foundation
import AvasiaEngine

// MARK: - Good #2 — Nascastrum Courier

struct GoodTwoSilvariumRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodTwoSilvarium
    private let advance = ["CONTINUE", "GO", "YES"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Silvarium — Elders' Hall"),
            .body("Smoke from Oceandale still stains your boots. The hall smells of sap and urgency — elders who waited for ridge truth now wait for shore aftermath.")
        ]
        if state.goodOneEvacuatedPier {
            lines.append(.speech("Elder Venna: Most of the pier lived. Your count saved more than our smoke signals did."))
        } else {
            lines.append(.speech("Elder Venna: The church stands. You saved who you could. That is not nothing — it is not enough."))
        }
        lines.append(.speech("Elder Venna: Oceandale's smoke still stains your report. Kaefden IV must hear it before Restoration claims another coast."))
        lines.append(.body("She presses a wax seal into your palm — courier's authority, Sylvian witness. Nacastrum's gate will read this before the court does."))
        lines.append(.hint("CONTINUE west toward Nacastrum."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.body("Western road mud. The floating city glints between storms.")],
            .move(.goodTwoWesternRoad)
        )
    }
}

struct GoodTwoWesternRoadRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodTwoWesternRoad
    private let advance = ["CONTINUE", "WEST", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Western Road"),
            .body("Refugees pass east — Oceandale fishers with empty nets and full fear. Some recognize your Sylvian seal and spit; some cling to your sleeve for news."),
            .body("Nacastrum hangs ahead between storms — blue crystal scaffolding, towers rebuilding what Vashirr scattered."),
            .body("KoN's Western Road gauntlet waits in another timeline. Today you carry witness, not a pendant."),
            .hint("CONTINUE to the gate · TALK to refugees · LOOK at the city.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("TALK") || input.contains("REFUGEE") {
            return AnthologyTurnResult([
                .speech("Fisher: They burned the nets. Not the boats — the nets. How do we eat?"),
                .speech("You: Nacastrum hears today. Hold east until the garrison moves."),
                .hint("CONTINUE to the gate.")
            ])
        }
        if input.contains("LOOK") || input.contains("CITY") || input.contains("NACASTRUM") {
            return AnthologyTurnResult([
                .body("The floating city drifts on anchor chains — mages returning through portals KoN will one day reopen. Restoration is rebuilding in public."),
                .hint("CONTINUE to the gate.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodTwoNacastrumGate))
    }
}

struct GoodTwoNacastrumGateRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodTwoNacastrumGate
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodTwoGateResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Nacastrum Gate"),
            .speech("Gate guard: State business. The king's council is not taking every rumor from the trees."),
            .speech("Thekia: (from the wall) Let the courier speak. Oceandale is not a rumor."),
            .hint("FULL truth to Thekia · SOFTEN for the court.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodTwoGateResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodTwoEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("FULL") || input.contains("TRUTH") || input.contains("THEKIA") {
            state.goodTwoGateResolved = true
            state.goodTwoFullTruth = true
            return AnthologyTurnResult([
                .speech("You: Agroman ships massed. Oceandale burned. Many Hands trains Paladins in the valley."),
                .speech("Thekia: The council will hear every word. Kaefden must."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("SOFTEN") || input.contains("COURT") || input.contains("GUARD") {
            state.goodTwoGateResolved = true
            state.goodTwoFullTruth = false
            return AnthologyTurnResult([
                .body("You trim the worst from the report. The guard nods — politics, not prophecy."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("FULL truth · SOFTEN for the court.")])
    }
}

struct GoodTwoEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodTwoEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodTwoComplete {
            return [.body("Nascastrum Courier — complete.")]
        }
        let line = state.goodTwoFullTruth
            ? "Thekia's hand on your shoulder — thin comfort, real witness. Mobilization stirs in the towers."
            : "Your softened report buys time and costs clarity. The shore will pay the difference."
        return [.title("Courier's Return"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodTwoComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodTwo, state: &state)
        return AnthologyTurnResult([
            .title("Nascastrum Courier — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodTwo).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
