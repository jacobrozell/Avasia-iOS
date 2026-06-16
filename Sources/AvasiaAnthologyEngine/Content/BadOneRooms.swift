import Foundation
import AvasiaEngine

// MARK: - Bad #1 — Walking with Vashirr

struct BadOneColumnRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneColumn
    private let advance = ["CONTINUE", "MARCH", "GO"]
    private let talk = ["TALK", "SOLDIER", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Agroman Column"),
            .body("Pamphlets in every kit — Many Hands for every shield, magic without mage priesthood. Shared rations. No looting, no torching granaries — Vashirr's voice ahead, not mercy, but order."),
            .body("Discipline holds a column that could burn Sylva if it forgot why it marched."),
            .body("A soldier mutters about a Sylvian scout seen near the Suformin road — Mira's name never spoken, but your ribs tighten."),
            .hint("CONTINUE with the march · TALK to the column.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            let miraLine = state.miraStatus == .brokeAway
                ? "Soldier: Your partner ran when the parley broke. Smart. The west remembers runners who come back useful."
                : "Soldier: Two scouts on the ridge — one followed, one didn't. The west only counts the one who stayed."
            return AnthologyTurnResult([
                .body(miraLine),
                .speech("Soldier: Vashirr says mages hoard sky while soldiers bleed. Hard to argue when your gauntlet sparks."),
                .hint("CONTINUE with the march.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK to the column.")])
        }
        return AnthologyTurnResult(
            [.body("The column turns west toward the training yards — smoke and chant before blood.")],
            .move(.badOneTraining)
        )
    }
}

struct BadOneTrainingRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneTraining
    private let advance = ["CONTINUE", "WATCH", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Training Yard"),
            .body("A farmhand learns to spark his gauntlet — flesh-anchor, not tower magic. He flinches when the flame catches. Sergeant Dentros barks corrections — not the Cataracta recruiter, but the name stings."),
            .body("Many Hands works. That is the horror: common soldiers casting without Nacastrum's permission."),
            .body("Paladin pairs drill in the far corner — fewer than the stories warn, but real enough to kill Sylvian pickets."),
            .hint("CONTINUE · LOOK at the drill.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LOOK") || input.contains("DRILL") || input.contains("WATCH") {
            return AnthologyTurnResult([
                .body("Two soldiers breathe in unison — one sparks, one shields. Binding without a mage in sight."),
                .speech("Dentros: Again. Hesitation kills more than cruelty."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · LOOK at the drill.")])
        }
        return AnthologyTurnResult([], .move(.badOneAudience))
    }
}

struct BadOneAudienceRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneAudience
    private let advance = ["CONTINUE", "TALK", "YES"]
    private let talk = ["TALK", "VASHIRR", "ASK"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Vashirr's Tent"),
            .body("Maps of Sylvian outposts cover the table — your ridge count would fit neatly beside them if you had brought it west instead of east."),
            .speech("Vashirr: Do you still think mages should gatekeep while soldiers bleed?"),
            .body("You do not answer quickly enough. His eye scar catches lamp-light — the mark KoN will one day explain."),
            .speech("Vashirr: I already know Silvarium watches this ridge. Map what you choose to mark — truth or mercy. I will know which you are."),
            .hint("CONTINUE to the recon task · TALK to Vashirr.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) && !advance.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Vashirr: Kaefden IV will crown in Nacastrum and call it Restoration. I call it hoarding."),
                .speech("Vashirr: Many Hands puts magic in the shield that blocks the spear. You FOLLOWed — now prove you understand why."),
                .hint("CONTINUE to the recon task.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE · TALK to Vashirr.")])
        }
        return AnthologyTurnResult([], .move(.badOneRecon))
    }
}

struct BadOneReconRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneRecon
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badOneReconResolved {
            return [.hint("CONTINUE.")]
        }
        return [
            .title("Northern Ridge"),
            .body("Silvarium pickets below — bark-strip tallies, green smoke ready, elders who trust scouts more than sermons."),
            .body("You hold a charcoal map and Vashirr's trust — such as it is. Every camp you mark is a week someone may not have."),
            .hint("REPORT truthfully · LIE to protect Silvarium.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.badOneReconResolved {
            if input.contains("CONTINUE") {
                return AnthologyTurnResult([], .move(.badOneEpilogue))
            }
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if input.contains("TRUTH") || input.contains("REPORT") || input.contains("HONEST") {
            state.badOneReconResolved = true
            state.badOneTruthfulRecon = true
            return AnthologyTurnResult([
                .body("You mark every outpost — Suformin road, elder hall approaches, the splitpath signal point where green smoke could still save a day."),
                .body("Vashirr reads your map without praise or anger. Useful is its own verdict."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("LIE") || input.contains("FALSE") || input.contains("PROTECT") {
            state.badOneReconResolved = true
            state.badOneTruthfulRecon = false
            let miraLine = state.miraStatus == .brokeAway
                ? "You erase two camps from the map — one near where Mira fled when you chose FOLLOW. You may have bought her a week."
                : "You erase two camps from the map. Mira's face flashes unbidden — you may have bought Silvarium a week."
            return AnthologyTurnResult([
                .body(miraLine),
                .body("The charcoal smudges where your hand shook. Vashirr will notice. He always notices."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint("REPORT truthfully · LIE to protect Silvarium.")])
    }
}

struct BadOneEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .badOneEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.badOneComplete {
            return [.body("Walking with Vashirr — complete."), .hint("Return to the story hub from the menu.")]
        }
        let line = state.badOneTruthfulRecon
            ? "Vashirr assigns you another march. You are useful — that is not the same as forgiven. The west remembers honesty in scouts it can spend."
            : "Vashirr almost smiles. Silvarium will bleed sooner. You feel the weight in your ribs — mercy with an Agroman seal on it."
        return [
            .title("Column Dust"),
            .body(line),
            .body("Cataracta's foothills wait on the next map. Many Hands does not pause for conscience."),
            .hint("CONTINUE.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        guard !state.badOneComplete else {
            return AnthologyTurnResult([.body("Use the menu to return to Story Adventures.")])
        }
        AnthologyCatalog.complete(.badOne, state: &state)
        return AnthologyTurnResult([
            .title("Walking with Vashirr — complete"),
            .body("+\(AnthologyCatalog.meta(for: .badOne).fpReward) faction points."),
            .hint("Story hub unlocked — continue from the menu.")
        ], .move(.storyHub))
    }
}
