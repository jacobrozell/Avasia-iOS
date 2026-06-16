import Foundation
import AvasiaEngine

// MARK: - Story #0 — Scout Patrol

struct StoryZeroPatrolCampRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .patrolCamp

    private let advance = ["CONTINUE", "NORTH", "RIDGE", "GO"]
    private let talk = ["TALK", "MIRA", "PARTNER"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Scout Patrol Camp"),
            .body("Cold fire. Mira's breathing steadies beside you on the pine needles."),
            .body("A bark strip is pinned to your pack — Silvarium elders' hand: observe Agroman movement. Do not engage."),
            .hint("CONTINUE toward the ridge, or TALK to Mira.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Mira: If we see a real army, we run. Elders need truth, not two more bodies."),
                .speech("You: Truth is why they sent us."),
                .hint("CONTINUE toward the ridge.")
            ])
        }
        if advance.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult(
                [
                    .body("You douse the embers and climb before full light."),
                    .blank
                ],
                .move(.scoutRidge)
            )
        }
        if input.contains("LOOK") {
            return AnthologyTurnResult([
                .body("Ridge path east. Campfire ash. Mira's bow unstrung — rules of the patrol."),
                .hint("CONTINUE toward the ridge.")
            ])
        }
        return AnthologyTurnResult([.hint("CONTINUE toward the ridge, or TALK to Mira.")])
    }
}

struct StoryZeroScoutRidgeRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutRidge

    private let advance = ["CONTINUE", "DOWN", "VALLEY", "GO"]
    private let withdraw = ["WITHDRAW", "NORTH", "BACK", "RUN"]
    private let talk = ["TALK", "MIRA"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Ridge Overlook"),
            .body("The valley holds hundreds of campfires — too many for a raid."),
            .body("Many Hands banners mix with Nacastrum blue. Pamphlet scraps promise magic for every soldier, not mages in towers."),
            .hint("WITHDRAW to report · TALK to Mira · CONTINUE down (you were seen).")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult([
                .speech("Mira: That's an army. We report. Now."),
                .speech("You: They already know we're here."),
                .hint("WITHDRAW up the ridge — or CONTINUE down under their eyes.")
            ])
        }
        if input.contains("LOOK") {
            return AnthologyTurnResult([
                .body("Smoke threads the valley. Paladin pairs drill between tents — fewer than the stories warn, but real."),
                .hint("WITHDRAW · CONTINUE.")
            ])
        }
        if withdraw.contains(where: { input.contains($0) }) {
            state.ridgeOutcome = .withdrew
            return AnthologyTurnResult(
                [
                    .body("Mira catches your sleeve. You climb back from the lip before the pickets close the gap."),
                    .blank
                ],
                .move(.scoutWithdraw)
            )
        }
        if advance.contains(where: { input.contains($0) }) {
            state.ridgeOutcome = .captured
            return AnthologyTurnResult(
                [
                    .body("You slide down the scree. Agroman pickets rise from the brush — blades out, then lowered."),
                    .blank
                ],
                .move(.scoutPicket)
            )
        }
        return AnthologyTurnResult([.hint("WITHDRAW up the ridge, or CONTINUE down.")])
    }
}

struct StoryZeroScoutWithdrawRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutWithdraw

    private let advance = ["CONTINUE", "GO", "YES"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Ridge Retreat"),
            .body("The valley fires shrink behind pine. Mira counts under her breath — hundreds, not dozens."),
            .body("Elders need more than a guess before Oceandale's ships turn shoreward."),
            .hint("CONTINUE — raise a signal fire on the splitpath.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("TALK") || input.contains("MIRA") {
            return AnthologyTurnResult([
                .speech("Mira: Thin smoke on the ridge beats two corpses in a sermon tent."),
                .hint("CONTINUE.")
            ])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE toward the signal point.")])
        }
        return AnthologyTurnResult(
            [.body("You cut east off the ridge — orders kept, lives kept.")],
            .move(.scoutSignal)
        )
    }
}

struct StoryZeroScoutSignalRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutSignal

    private let advance = ["CONTINUE", "SIGNAL", "FIRE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.scoutSignalSent {
            return [.hint("CONTINUE — decide what elders deserve to hear.")]
        }
        return [
            .title("Splitpath Signal"),
            .body("Dry pine and bark strip cipher. Mira stacks kindling while you scrape flint."),
            .hint("SIGNAL the elders · CONTINUE without fire.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.scoutSignalSent {
            guard advance.contains(where: { input.contains($0) }) else {
                return AnthologyTurnResult([.hint("CONTINUE.")])
            }
            return AnthologyTurnResult([], .move(.scoutFork))
        }
        if input.contains("SIGNAL") || input.contains("FIRE") {
            state.scoutSignalSent = true
            return AnthologyTurnResult([
                .body("Green smoke climbs — Silvarium's call for urgent count, not battle."),
                .speech("Mira: They'll send riders. What we tell them is still ours to choose."),
                .hint("CONTINUE.")
            ])
        }
        if advance.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult(
                [.body("You leave the kindling unlit. The count stays between you and the valley.")],
                .move(.scoutFork)
            )
        }
        return AnthologyTurnResult([.hint("SIGNAL · CONTINUE.")])
    }
}

struct StoryZeroScoutPicketRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutPicket

    private let advance = ["CONTINUE", "GO", "YES"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("Agroman Picket Line"),
            .body("Soldiers flank you without striking. Mira's quiver is taken; your knife is gone."),
            .body("An officer speaks quietly: Vashirr wants witnesses, not corpses."),
            .hint("CONTINUE under escort.")
        ]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("TALK") || input.contains("MIRA") {
            return AnthologyTurnResult([
                .speech("Mira: (whisper) If we live through this, elders hear every word."),
                .hint("CONTINUE.")
            ])
        }
        if advance.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult(
                [
                    .body("They march you into the camp center. Fires banked. Eyes on you — curious, not hungry."),
                    .blank
                ],
                .move(.vashirrParley)
            )
        }
        return AnthologyTurnResult([.hint("CONTINUE under escort.")])
    }
}

struct StoryZeroVashirrParleyRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .vashirrParley
    var parseMode: Parser.Mode { .raw }

    private let advance = ["CONTINUE", "LISTEN", "YES", "GO"]
    private let talk = ["TALK", "ASK", "VASHIRR"]

    func onEnter(_ state: inout AnthologyGameState) -> [StyledLine]? {
        guard state.parleyPhase == .notStarted else { return nil }
        state.parleyPhase = .arrival
        return arrivalLines()
    }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        switch state.parleyPhase {
        case .notStarted, .arrival:
            return [.hint("CONTINUE — listen.")]
        case .schism:
            return [.hint("CONTINUE.")]
        case .doctrine:
            return [.hint("CONTINUE — or TALK to press him.")]
        case .offer:
            return [.hint("CONTINUE to the choice ahead.")]
        case .done:
            return [.hint("CONTINUE to decide your path.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if talk.contains(where: { input.contains($0) }) {
            return AnthologyTurnResult(talkLines(state) + [.hint("CONTINUE.")])
        }
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE to listen.")])
        }
        return advanceParley(&state)
    }

    private func advanceParley(_ state: inout AnthologyGameState) -> AnthologyTurnResult {
        switch state.parleyPhase {
        case .notStarted, .arrival:
            state.parleyPhase = .schism
            return AnthologyTurnResult(schismLines())
        case .schism:
            state.parleyPhase = .doctrine
            return AnthologyTurnResult(doctrineLines())
        case .doctrine:
            state.parleyPhase = .offer
            return AnthologyTurnResult(offerLines())
        case .offer:
            state.parleyHeardFullSermon = true
            state.parleyPhase = .done
            return AnthologyTurnResult(
                [
                    .body("Vashirr steps back. The choice is yours — but not here. Not yet."),
                    .blank
                ],
                .move(.scoutFork)
            )
        case .done:
            return AnthologyTurnResult([], .move(.scoutFork))
        }
    }

    private func arrivalLines() -> [StyledLine] {
        [
            .title("Vashirr's Camp"),
            .body("A hooded man studies you both. Gray staff. Scar at the eye — old, not theatrical."),
            .speech("Vashirr: Sylvian kit. Bark-strip cipher. Silvarium sent observers — good."),
            .speech("Vashirr: Observers can carry truth as well as spears."),
            .speech("Vashirr: You will eat. You will listen. Then you will choose what your elders deserve to hear.")
        ]
    }

    private func talkLines(_ state: AnthologyGameState) -> [StyledLine] {
        switch state.parleyPhase {
        case .schism:
            return [
                .speech("Mira: (whisper) He speaks like an elder. That doesn't make him ours."),
                .speech("Vashirr: I do not ask you to love me. I ask whether mages should gatekeep while kingdoms starve.")
            ]
        case .doctrine:
            return [
                .speech("Mira: (whisper) Surgeon or butcher — people still bleed."),
                .speech("Vashirr: Kaefden rebuilds towers. I rebuild hands that can hold shields.")
            ]
        default:
            return [
                .speech("Vashirr: I do not ask you to love me. I ask whether mages should gatekeep while kingdoms starve.")
            ]
        }
    }

    private func schismLines() -> [StyledLine] {
        [
            .blank,
            .speech("Vashirr: Two hands of one body — that is the schism fable every elder tells children."),
            .speech("Vashirr: One hand hoarded magic in towers. The other learned to bleed without it."),
            .speech("Vashirr: Power must anchor somewhere — sky, earth, flesh, or oath. Kaefden chose towers. Agroman chose blood."),
            .speech("Vashirr: I was taught in Kaefden's halls that mages must serve the people. I believed it."),
            .body("Mira's jaw tightens. She does not look at you.")
        ]
    }

    private func doctrineLines() -> [StyledLine] {
        [
            .blank,
            .speech("Vashirr: Many Hands — train common soldiers to cast. End the schism by force if councils will not."),
            .speech("Vashirr: Agroman is not a curse. It is a prince's middle name, turned into a banner for those exiled from Restoration."),
            .speech("Vashirr: Kaefden IV rebuilds Nacastrum in blue crystal while border villages burn. I offer one army. One law."),
            .speech("Vashirr: You think me a butcher. I think myself a surgeon.")
        ]
    }

    private func offerLines() -> [StyledLine] {
        [
            .blank,
            .speech("Vashirr: Report what you saw — or walk with us and learn what your elders refuse to teach."),
            .speech("Vashirr: I will not keep you. I will not make you swear. But you cannot unknow the valley."),
            .speech("Mira: (whisper) Say nothing rash.")
        ]
    }
}

struct StoryZeroScoutForkRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutFork
    var parseMode: Parser.Mode { .raw }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.forkResolved {
            return [.hint("CONTINUE on your road.")]
        }
        let lines: [StyledLine] = [
            .title("The Fork"),
            .body(forkContext(state)),
            .hint(forkHint(state))
        ]
        return lines
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if state.forkResolved {
            if input.contains("CONTINUE") || input.contains("GO") {
                return AnthologyTurnResult([], .move(.scoutCampExit))
            }
            return AnthologyTurnResult([.hint("CONTINUE on your road.")])
        }

        if input.contains("REPORT") {
            state.alignment = .loyalist
            state.forkResolved = true
            return AnthologyTurnResult([
                .speech("Mira: Thank the roots. I'll run with you."),
                .body("You choose truth for Silvarium — every fire counted, every banner noted."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("FOLLOW") {
            if state.ridgeOutcome == .withdrew {
                return AnthologyTurnResult([
                    .body("You never walked their column. FOLLOW is not a road you can take from the ridge.")
                ])
            }
            state.alignment = .agroman
            state.forkResolved = true
            state.miraStatus = .brokeAway
            return AnthologyTurnResult([
                .speech("Mira: Then we are not partners anymore."),
                .body("She breaks from your side. A sergeant starts forward — Vashirr shakes his head. She is gone before you can call."),
                .hint("CONTINUE.")
            ])
        }
        if input.contains("REFUSE") || input.contains("FLEE") {
            state.alignment = .neutral
            state.forkResolved = true
            return AnthologyTurnResult([
                .body("You refuse both sermon and easy loyalty. The choice stands — what happens next depends on who holds the valley."),
                .hint("CONTINUE.")
            ])
        }
        return AnthologyTurnResult([.hint(forkHint(state))])
    }

    private func forkContext(_ state: AnthologyGameState) -> String {
        if state.ridgeOutcome == .withdrew {
            return "Splitpath wind. No escorts — only Mira, the count in your head, and the choice elders will ask about."
        }
        return "Escorts fall back. The camp noise dulls. This moment belongs to you."
    }

    private func forkHint(_ state: AnthologyGameState) -> String {
        if state.ridgeOutcome == .withdrew {
            return "REPORT to Silvarium · REFUSE both paths."
        }
        return "REPORT to Silvarium · FOLLOW Vashirr · REFUSE both paths."
    }
}

struct StoryZeroScoutCampExitRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutCampExit

    private let advance = ["CONTINUE", "GO"]

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        [.hint("CONTINUE on your road.")]
    }

    func onEnter(_ state: inout AnthologyGameState) -> [StyledLine]? {
        exitLines(state)
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard advance.contains(where: { input.contains($0) }) else {
            return AnthologyTurnResult([.hint("CONTINUE on your road.")])
        }
        return AnthologyTurnResult([], .move(.scoutEpilogue))
    }

    private func exitLines(_ state: AnthologyGameState) -> [StyledLine] {
        switch state.alignment {
        case .loyalist:
            if state.ridgeOutcome == .withdrew {
                return [
                    .title("Road to Silvarium"),
                    .body("No sermon tent — only bark tallies and, if you lit it, green smoke already climbing."),
                    .speech("Mira: Venna will want numbers. Not his poetry.")
                ]
            }
            return [
                .title("Treeline Release"),
                .speech("Vashirr: Tell your elders the count. I hide nothing."),
                .body("Escorts march you to the pines. Mira scratches tallies onto bark as you walk."),
                .speech("Mira: Every fire. Every banner. Before the ships turn.")
            ]
        case .agroman:
            return [
                .title("Column Edge"),
                .body("A stranger presses Many Hands pamphlets into your hand. The march swallows you."),
                .body("Behind you, the treeline is empty where Mira stood.")
            ]
        case .neutral:
            if state.ridgeOutcome == .withdrew {
                return [
                    .title("Splitpath Alone"),
                    .body("You leave the count unspoken to either banner. Mira does not argue — she only watches which way you turn.")
                ]
            }
            return [
                .title("Camp Gate"),
                .speech("Vashirr: Let them go."),
                .body("An officer's jaw tightens, but pickets stand aside. You walk out with the valley burned into memory."),
                .body("No oath. No chase. Not yet.")
            ]
        case .none:
            return [.body("The road opens.")]
        }
    }
}

struct StoryZeroScoutEpilogueRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .scoutEpilogue

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        if state.storyZeroComplete {
            return [
                .title("Story Complete"),
                .body("Scout Patrol — finished."),
                .hint("Choose Story from the menu.")
            ]
        }
        return epilogueLines(state) + [.hint("CONTINUE.")]
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard input.contains("CONTINUE") || input.contains("GO") else {
            return AnthologyTurnResult([.hint("CONTINUE.")])
        }
        if !state.storyZeroComplete {
            AnthologyCatalog.complete(.storyZero, state: &state)
            let lines: [StyledLine] = [
                .title("Scout Patrol — complete"),
                .body("+\(AnthologyCatalog.meta(for: .storyZero).fpReward) faction points."),
                .body(closingLine(state)),
                .blank
            ]
            return AnthologyTurnResult(lines, .move(.storyHub))
        }
        return AnthologyTurnResult([], .move(.storyHub))
    }

    private func epilogueLines(_ state: AnthologyGameState) -> [StyledLine] {
        [
            .title("The Road Out"),
            .body(dawnLine(state))
        ]
    }

    private func dawnLine(_ state: AnthologyGameState) -> String {
        switch state.alignment {
        case .loyalist:
            if state.ridgeOutcome == .withdrew {
                if state.scoutSignalSent {
                    return "Splitpath mud under your boots. Riders may already be moving — Oceandale's ships are still on the horizon."
                }
                return "Splitpath mud under your boots. You kept your orders and your partner — Silvarium must still hear the count before the ships land."
            }
            return "Splitpath mud under your boots. Oceandale is still far — but Silvarium will hear you before the ships land."
        case .agroman:
            return "Column dust on your tongue. Mira is gone. The Many Hands pamphlet in your pocket feels like a second skin."
        case .neutral:
            return "Splitpath at dusk. No banner feels clean. Somewhere ahead, firelight that is not war — if you keep walking."
        case .none:
            return "The road opens. Your choice lingers unspoken."
        }
    }

    private func closingLine(_ state: AnthologyGameState) -> String {
        switch state.alignment {
        case .loyalist:
            return "PLAY GOOD from the hub to warn Oceandale (500 FP)."
        case .agroman:
            return "PLAY BAD from the hub to march with Vashirr (500 FP)."
        case .neutral:
            return "PLAY ELK from the hub (250 FP) · then The Cave Record (500 FP)."
        case .none:
            return "Your patrol ends without a recorded choice."
        }
    }
}
