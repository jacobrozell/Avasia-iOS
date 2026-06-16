import Foundation
import AvasiaEngine

// MARK: - Good #6 — The Restoration Accord

struct GoodSixAccordHallRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixAccordHall
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Accord Hall"),
            .body("Nacastrum ministers and Sylvian elders share a table — the first since Oceandale burned."),
            .speech("Thekia: \"Your witness stone, your testimony, your hold order — all led here. One signature binds Restoration to Sylva.\""),
            .speech("Elder Venna: \"Or we walk away before the accord becomes another lie.\""),
        ]
        if state.goodFourHoldLine {
            lines.append(.body("Ministers still quote your pier evacuation — proof Sylva can trust Kaefden with living bodies, not only ink."))
        }
        lines.append(.hint("CONTINUE to the antechamber · LOOK at the table."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("TABLE") {
            return AnthologyTurnResult([
                .body("Two copies of the pact — one for floating court, one for Silvarium bark-archive. Neither side trusts the other's scribes."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodSixAccordAntechamber))
    }
}

struct GoodSixAccordAntechamberRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixAccordAntechamber
    private let advance = ["CONTINUE", "WAIT", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Diplomatic Antechamber"),
            .body("Clerks argue over witness clauses. A minister's aide asks whether Sylvian scouts are \"allies\" or \"observers.\""),
            .body("Restoration hardliners want Agroman names redacted. Elders want every burned pier named aloud."),
        ]
        if state.goodThreePublicTestimony {
            lines.append(.speech("Clerk: \"The courier who forced public testimony — they're waiting on you in prep.\""))
        }
        lines.append(.hint("CONTINUE when Venna sends for you."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.speech("Elder Venna: Scout — witness prep. They will ask you to bless their compromise.")],
            .move(.goodSixWitnessPrep)
        )
    }
}

struct GoodSixWitnessPrepRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixWitnessPrep
    private let advance = ["CONTINUE", "YES", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Witness Prep"),
            .speech("Thekia: \"Sign as Sylvian witness and the court gains legitimacy. Walk and Sylva keeps moral distance — but loses leverage.\""),
            .speech("Elder Venna: \"You carved your ridge report into bark — or refused. This table asks the same question in ministerial ink.\""),
        ]
        if state.goodFiveSworeWitness {
            lines.append(.body("Your palm still remembers sap from the witness stone. Ministers will read your signature as oath, not courtesy."))
        } else {
            lines.append(.body("You refused permanent mark at Silvarium. Venna nods — walking away here would be consistent, not cowardice."))
        }
        lines.append(.hint("CONTINUE to the signing floor."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodSixSigningFloor))
    }
}

struct GoodSixSigningFloorRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixSigningFloor
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodSixAccordResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Signing Floor"),
            .body("Quills dry. Every faction watches the scout who started as ridge eyes and became court memory."),
            .hint("SIGN as Sylvian witness · WALK from the accord.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodSixAccordResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodSixAftermath))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("SIGN") || input.contains("WITNESS") || input.contains("ACCORD") {
            state.goodSixAccordResolved = true
            state.goodSixSignedAccord = true
            return AnthologyTurnResult([
                .body("You sign beside Venna and Thekia — scout, courier, witness. The accord is imperfect and real."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("WALK") || input.contains("LEAVE") || input.contains("REFUSE") {
            state.goodSixAccordResolved = true
            state.goodSixSignedAccord = false
            return AnthologyTurnResult([
                .speech("Elder Venna: \"Then bear the truth outside their ink. Sylva survives without their permission.\""),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("SIGN · WALK")])
    }
}

struct GoodSixAftermathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixAftermath
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodSixSignedAccord {
            return [
                .title("Accord Aftermath"),
                .body("Ministers seal their copy. Elders roll the bark-archive duplicate toward the western lift."),
                .speech("Thekia: \"History will call this peace — or prelude. You made it possible to call it anything at all.\""),
                .hint("CONTINUE to accord night.")
            ]
        }
        return [
            .title("Accord Aftermath"),
            .body("The table empties without a third signature. Clerks scramble to file \"adjournment\" instead of \"accord.\""),
            .speech("Elder Venna: \"Better an honest pause than a lying treaty. Sylva remembers who refused to forget Oceandale.\""),
            .hint("CONTINUE to accord night.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodSixEpilogue))
    }
}

struct GoodSixEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodSixEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodSixComplete {
            return [.body("The Restoration Accord — complete.")]
        }
        let line = state.goodSixSignedAccord
            ? "Two banners share a table at last. Loyalty, for you, meant staying until the ink dried."
            : "You leave ministers whispering. Loyalty, for you, meant refusing a peace that forgets Oceandale."
        return [.title("Accord Night"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodSixComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodSix, state: &state)
        var lines: [StyledLine] = [
            .title("The Restoration Accord — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodSix).fpReward) faction points.")
        ]
        lines.append(contentsOf: AnthologyCatalog.pathCompletionLines(state: state))
        return AnthologyTurnResult(lines, .move(.storyHub))
    }
}
