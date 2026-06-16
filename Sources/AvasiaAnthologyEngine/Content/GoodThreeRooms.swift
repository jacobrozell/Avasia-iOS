import Foundation
import AvasiaEngine

// MARK: - Good #3 — Council Under Glass

struct GoodThreeLandingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeLanding
    private let advance = ["CONTINUE", "GO", "CLIMB"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Western Lift"),
            .body("Rope lifts creak toward Nacastrum — the floating city rebuilt in blue crystal after the Restoration wars."),
            .body("Refugees from Oceandale still camp on the shore below. Your sealed report smells of smoke they escaped."),
            .hint("CONTINUE to the antechamber · LOOK at the city.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("CITY") {
            return AnthologyTurnResult([
                .body("Towers stitch sky to sea. Kaefden's banner flies beside Sylvian witness flags — uneasy cousins."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodThreeAntechamber))
    }
}

struct GoodThreeAntechamberRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeAntechamber
    private let advance = ["CONTINUE", "WAIT", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Court Antechamber"),
            .body("Clerks whisper about Agroman ship counts. A minister's aide asks if your report is \"actionable\" or \"historical.\""),
            .body("Restoration hardliners want Oceandale filed under tragedy — not accusation."),
            .hint("CONTINUE when Thekia sends for you.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult(
            [.speech("Clerk: Thekia of the witness rail — for the courier.")],
            .move(.goodThreeWitnessPrep)
        )
    }
}

struct GoodThreeWitnessPrepRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeWitnessPrep
    private let advance = ["CONTINUE", "YES", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .title("Witness Prep"),
            .speech("Thekia: \"They will ask you to soften names. Paladins with family in Kaefden. Ministers who traded with Agromans last year.\""),
            .body("She straightens your courier seal — still valid, still dangerous.")
        ]
        if state.goodTwoFullTruth {
            lines.append(.speech("Thekia: \"You told me the full truth at the gate. The court cannot unknow it now.\""))
        } else {
            lines.append(.speech("Thekia: \"You softened once. They will ask again. Decide before we enter.\""))
        }
        lines.append(.hint("CONTINUE to the floating court."))
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodThreeNacastrum))
    }
}

struct GoodThreeNacastrumRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeNacastrum
    private let advance = ["CONTINUE", "ENTER", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Nacastrum — Floating Court"),
            .body("Blue crystal scaffolding rings the chamber. Your courier seal still earns stares — Oceandale's truth did not vanish in the gate mud."),
            .speech("Thekia: \"Restoration hardliners want a clean story. You carry the messy one.\""),
            .hint("CONTINUE to the council chamber.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodThreeCouncil))
    }
}

struct GoodThreeCouncilRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeCouncil
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Council Under Glass"),
            .body("Kaefden's ministers sit beneath a dome of spell-glass — sky and sea warped above their heads."),
            .speech("Minister: \"We acknowledge Oceandale. We cannot parade every Agroman name you copied from tree-bark.\""),
            .body("Thekia waits at the rail. One word from you could force public testimony — or let the court soften the record again."),
            .hint("CONTINUE to the verdict floor · LOOK at the ministers.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("MINISTER") {
            return AnthologyTurnResult([
                .body("Half the council never set foot on a burning pier. They know war as ledger ink."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodThreeVerdict))
    }
}

struct GoodThreeVerdictRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeVerdict
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodThreeVerdictResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Verdict Floor"),
            .speech("Thekia: \"PETITION — read the full report before the court. Or WITHHOLD — let me negotiate without burning every bridge.\""),
            .hint("PETITION for public testimony · WITHHOLD for quiet diplomacy.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.goodThreeVerdictResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.goodThreeAftermath))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("PETITION") || input.contains("PUBLIC") || input.contains("TESTIFY") {
            state.goodThreeVerdictResolved = true
            state.goodThreePublicTestimony = true
            return AnthologyTurnResult([
                .speech("You: Every name. Every ship. Every Paladin drill in the valley."),
                .speech("Minister: Then the court will hear it — and the Agromans will call it an act of war."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("WITHHOLD") || input.contains("QUIET") || input.contains("DIPLOMACY") {
            state.goodThreeVerdictResolved = true
            state.goodThreePublicTestimony = false
            return AnthologyTurnResult([
                .speech("Thekia: Wise. We move the garrison first — truth can follow survivors."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("PETITION · WITHHOLD")])
    }
}

struct GoodThreeAftermathRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeAftermath
    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodThreePublicTestimony {
            return [
                .title("Chamber Steps"),
                .body("Clerks scramble to copy your words. A minister refuses to meet your eyes."),
                .speech("Thekia: \"You bought Oceandale a hearing. Paying comes later.\""),
                .hint("CONTINUE.")
            ]
        }
        return [
            .title("Chamber Steps"),
            .body("The session closes without applause. Orders already move on hidden rails."),
            .speech("Thekia: \"Survivors first. Testimony when they can bear it.\""),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        return AnthologyTurnResult([], .move(.goodThreeEpilogue))
    }
}

struct GoodThreeEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .goodThreeEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.goodThreeComplete {
            return [.body("Council Under Glass — complete.")]
        }
        let line = state.goodThreePublicTestimony
            ? "The glass dome echoes with names the Restoration wished to forget. Loyalty, this time, meant volume."
            : "The court adjourns without spectacle. Thekia promises the garrison moves at dawn — a quieter loyalty."
        return [.title("After Session"), .body(line), .hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.goodThreeComplete else {
            return AnthologyTurnResult([.body("Return to Story Adventures from the menu.")])
        }
        AnthologyCatalog.complete(.goodThree, state: &state)
        return AnthologyTurnResult([
            .title("Council Under Glass — complete"),
            .body("+\(AnthologyCatalog.meta(for: .goodThree).fpReward) faction points.")
        ], .move(.storyHub))
    }
}
