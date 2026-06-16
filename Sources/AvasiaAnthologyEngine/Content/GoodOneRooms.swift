import Foundation
import AvasiaEngine

// MARK: - Good #1 — The Oceandale Warning

struct GoodOneSilvariumRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneSilvarium
    private let advance = ["CONTINUE", "YES", "GO"]
    private let talk = ["TALK", "VENNA", "ELDER"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        debriefLines(state) + [.hint("CONTINUE — march for the coast · TALK to Elder Venna.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Elder Venna: Oceandale is not Nacastrum. Fishers, not mages. They will not read smoke signals — they need a voice on the pier."),
                .speech("Elder Venna: Run until your boots bleed if you must. The ships turn shoreward on the tide."),
                .hint("CONTINUE — march for the coast.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK to Elder Venna.")])
        }
        return AnthologyTurnResult(
            [
                .body("You descend the great tree with the elders' seal on your report — wax still warm against your palm."),
                .body("The coastal road waits. Oceandale does not know the valley's count yet.")
            ],
            .move(.goodOneSplitpath)
        )
    }

    private func debriefLines(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Silvarium — Elders' Hall"),
            .body("Sap and council smoke. Witness flags hang limp — Sylva has heard too many partial truths this season.")
        ]

        if state.miraStatus == .brokeAway {
            lines.append(.speech("Elder Venna: You came alone. Where is your partner?"))
            lines.append(.body("You have no good answer — only the count, and the ridge where Mira broke away when you chose REPORT."))
        } else if state.ridgeOutcome == .withdrew {
            if state.scoutSignalSent {
                lines.append(.speech("Elder Venna: Green smoke on the ridge — thin truth, but timely. How many fires?"))
            } else {
                lines.append(.speech("Elder Venna: You kept orders and returned. How many fires?"))
            }
            lines.append(.body("You give the count. Mira's bark tally matches yours — two scouts, one number, no poetry."))
        } else if state.parleyHeardFullSermon {
            lines.append(.speech("Elder Venna: Hundreds of fires. Many Hands banners. You are certain?"))
            lines.append(.speech("Elder Venna: You repeat his sermon too cleanly. What did you see with your own eyes?"))
            lines.append(.body("You strip the poetry. Mira's tally confirms the numbers — campfires, not metaphors."))
        } else {
            lines.append(.speech("Elder Venna: Hundreds of fires. Many Hands banners. You are certain?"))
            lines.append(.body("You nod. Mira's written tally confirms yours — every picket you counted from captivity or the ridge."))
        }

        lines.append(.speech("Elder Venna: Oceandale must hear this before the ships turn shoreward. Run."))
        return lines
    }
}

struct GoodOneSplitpathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneSplitpath
    private let advance = ["CONTINUE", "GO", "EAST"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Coastal Road"),
            .body("Two days hard march from Splitpath. Your report rides in oilcloth — elders' seal unbroken."),
            .body("Smoke on the horizon — nets burning, not campfires. The smell reaches you before the sea does."),
            .body("Agroman sails still sit on the water, patient as weather. You are late for the ridge, not yet for the pier."),
            .hint("CONTINUE toward Oceandale · LOOK at the horizon.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("HORIZON") || input.contains("SEA") {
            return AnthologyTurnResult([
                .body("Six sails — maybe eight. Landing boats stacked on deck like teeth. Oceandale's church steeple is a thin line against the water."),
                .hint("CONTINUE toward Oceandale.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the horizon.")])
        }
        return AnthologyTurnResult(
            [
                .body("The colony clamors at the shoreline — chaos, but not overrun. Fishers shout over children. Someone is still trying to save the nets."),
                .body("You are the first Sylvian voice they have seen since the smoke started.")
            ],
            .move(.goodOneOceandale)
        )
    }
}

struct GoodOneOceandaleRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneOceandale
    private let advance = ["CONTINUE", "GO"]
    private let talk = ["TALK", "FISHER", "WARN"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Oceandale Front"),
            .body("Fishers pack the pier — children, elders, nets still dripping brine. The colony KoN will one day call a wound still smells of salt and smoke."),
            .body("Agroman sails sit on the horizon. You have minutes, not hours."),
            .body("A woman clutches a pendant — blue crystal, earth-anchor, Sylvian make. She does not know you carry elders' truth in your pack."),
            .hint("CONTINUE to the pier · TALK to the fishers.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Fisher: We saw the smoke east. Is it Agroman? Is it Restoration? We fish. We don't read sermons."),
                .speech("You: Ships on the horizon. Hundreds of fires behind them in the valley. Move now — pier or church, but move."),
                .hint("CONTINUE to the pier.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK to the fishers.")])
        }
        return AnthologyTurnResult([], .move(.goodOnePier))
    }
}

struct GoodOnePierRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOnePier
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodOnePierResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("The Pier"),
            .body("Boats rock empty at their moorings — not enough hulls for every family. The church bell still works. The landing craft do not care which you choose."),
            .speech("Fisher: Do we run or hold the church?"),
            .speech("Elder fisher: My grandmother meditated on this shore before the schism. The water was peaceful then."),
            .hint("EVACUATE the pier · HOLD the church.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodOnePierResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodOneEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("EVACUATE") || input.contains("PIER") || input.contains("BOATS") {
            state.goodOnePierResolved = true
            state.goodOneEvacuatedPier = true
            return AnthologyTurnResult([
                .body("You drive families toward the boats — children first, nets abandoned. Hands pull oars before the first landing craft touches sand."),
                .body("Most reach open water before Agroman boots hit the pier. Not all. Never all."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("CHURCH") || input.contains("HOLD") {
            state.goodOnePierResolved = true
            state.goodOneEvacuatedPier = false
            return AnthologyTurnResult([
                .body("You bar the church doors and ring the bell — three long, the fisher's alarm. Some sprint from the pier. Many do not reach stone in time."),
                .body("Those inside survive the first hour. Those outside learn what Many Hands means on a shore without mages."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("EVACUATE the pier · HOLD the church.")])
    }
}

struct GoodOneEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodOneEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodOneComplete {
            return [.body("The Oceandale Warning — complete."), .hint("Return to the story hub from the menu.")]
        }
        let outcome = state.goodOneEvacuatedPier
            ? "Most fishers live to curse the horizon another day. Empty boats drift back with the tide — grim tally, but a tally."
            : "The church stands charred at the eaves. You saved who you could behind stone. The pier tells the rest."
        return [
            .title("Dawn After"),
            .body(outcome),
            .body("Kaefden's war is still distant — but Oceandale will not forget who ran toward the smoke."),
            .body("Elder Venna will ask for names next. Nacastrum will ask for fewer."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodOneComplete else {
            return AnthologyTurnResult([.body("Use the menu to return to Story Adventures.")])
        }
        AnthologyCatalog.complete(.goodOne, state: &state)
        var lines: [StyledLine] = [
            .title("The Oceandale Warning — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodOne).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ]
        lines.append(contentsOf: AnthologyCatalog.launchSliceCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
