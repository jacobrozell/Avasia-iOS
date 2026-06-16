import Foundation
import AvasiaEngine

/// Final confrontation — Vashirr's redoubt (iOS authored).
struct SoCVashirrStandRoom: SoCRoomScript {
    let id: SoCRoomID = .vashirrStand
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "TALK", "YES", "PROCEED", "CHARGE"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.vashirrStandPhase == .notStarted else { return nil }
        state.vashirrStandPhase = .arrival
        return arrivalLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.inCombat {
            return SoCCombat.statLines(state: state) + [.hint("ATTACK.")]
        }
        if state.vashirrDefeated {
            return [
                .title("Vashirr's Redoubt"),
                .body("The portal ash settles. Coalition soldiers secure the shore."),
                .hint("CONTINUE to Aylova.")
            ]
        }
        switch state.vashirrStandPhase {
        case .notStarted, .arrival:
            return [.hint("CONTINUE as the army deploys.")]
        case .confrontation:
            return [.hint("CONTINUE to answer Kaefden's call.")]
        case .playerBeat:
            return [.hint("CONTINUE into the breach.")]
        case .finalCombat:
            return SoCCombat.statLines(state: state) + [.hint("ATTACK.")]
        case .resolution:
            return [.hint("CONTINUE homeward.")]
        case .done:
            return [.hint("CONTINUE to Aylova.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.inCombat {
            return handleCombat(input, &state)
        }

        if state.vashirrDefeated {
            if advances(input) {
                return SoCTurnResult(homewardLines(), .move(.ageEpilogue))
            }
            return SoCTurnResult([.hint("CONTINUE to Aylova.")])
        }

        if advances(input) {
            return advanceScene(&state)
        }
        return SoCTurnResult([.hint("CONTINUE.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func advanceScene(_ state: inout SoCGameState) -> SoCTurnResult {
        switch state.vashirrStandPhase {
        case .notStarted, .arrival:
            state.vashirrStandPhase = .confrontation
            return SoCTurnResult(confrontationLines())

        case .confrontation:
            state.vashirrStandPhase = .playerBeat
            return SoCTurnResult(playerBeatLines(state))

        case .playerBeat:
            state.vashirrStandPhase = .finalCombat
            return SoCTurnResult(warMageLines() + beginWarMage(state: &state))

        case .resolution:
            state.vashirrStandPhase = .done
            state.vashirrDefeated = true
            var lines = resolutionLines(state: &state)
            lines.append(.title("Vashirr's war broken"))
            return SoCTurnResult(lines)

        case .finalCombat, .done:
            return SoCTurnResult([.hint("ATTACK.")])
        }
    }

    private func handleCombat(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        let result = SoCCombat.handle(input, state: &state)
        var output = SoCCombat.statLines(state: state) + result.lines

        if result.died {
            return SoCTurnResult(output, .stay, playerDied: true)
        }
        guard !state.inCombat else {
            return SoCTurnResult(output)
        }

        state.vashirrStandPhase = .resolution
        output.append(contentsOf: warMageFallsLines())
        return SoCTurnResult(output)
    }

    private func beginWarMage(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Vashirr's War Mage", atk: 11, speed: 8, hp: 28, luck: 6),
            deathText: "The war mage's bolt tears through your line.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func arrivalLines() -> [StyledLine] {
        [
            .title("Vashirr's Redoubt"),
            .body("Dawn breaks over a rocky shore. Agromanian banners whip in the salt wind."),
            .body("At the center stands a dark portal frame — and the hooded figure you have hated since Cataracta's ashes."),
            .body("King Kaefden IV rides to the front of the coalition line, crown bright against the gray sea.")
        ]
    }

    private func confrontationLines() -> [StyledLine] {
        [
            .blank,
            .speech("Kaefden IV: Vashirr. You taught Agromanian butchers to burn Cataracta. You sent a druid to my throne with threats."),
            .speech("Vashirr: I sent them the truth. You sit on a crown you never earned, boy-king."),
            .speech("Kaefden IV: I earned it when you scattered the Council and murdered my people."),
            .speech("Vashirr: I taught you history. You teach Restoration. One of us is building Avasia's future."),
            .speech("Kaefden IV: You build on ashes and call it foundation."),
            .blank,
            .body("Vashirr pulls back his hood. The scar across his eye is exactly as you remember."),
            .speech("Vashirr: Cataracta hid behind mountains while I matured the Paladins. Every day you rebuilt Nacastrum, you chose more blood."),
            .speech("Kaefden IV: Kimious chose alliance, not hiding. You murdered him for it."),
            .speech("Vashirr: I offer one army. One law. Magic in every gauntlet — not hoarded in towers while the schism rots the ground."),
            .speech("Kaefden IV: One fist. You fused magic into soldiers who never chose it. That is not unity. That is theft."),
            .speech("Vashirr: When you wore my classroom, you said mages must serve the people. I listened. I simply stopped waiting for councils to agree."),
            .speech("Kaefden IV: Druid of Cataracta — step forward. Finish what he started with you.")
        ]
    }

    private func playerBeatLines(_ state: SoCGameState) -> [StyledLine] {
        let beat: String
        switch state.playerClass {
        case .hunter:
            beat = "You break from the line and drive your blade through the ward-gap before the war mage can finish chanting."
        case .guardian:
            beat = "You raise your shield and absorb a killing bolt meant for Kaefden — then hold the breach while mages reset their circle."
        case .scout:
            beat = "You sprint the ridgeline, scatter the ward-stakes, and open a lane for the coalition charge."
        case .none:
            beat = "You step into the ward-light and fight as Cataracta's last volunteer."
        }
        return [
            .blank,
            .body(beat),
            .blank,
            .body("Vashirr snarls and thrusts his staff toward you. A war mage surges from the portal to meet you.")
        ]
    }

    private func warMageLines() -> [StyledLine] { [] }

    private func warMageFallsLines() -> [StyledLine] {
        [
            .blank,
            .body("The war mage falls. For a moment the shore is silent."),
            .speech("Vashirr: Enough!"),
            .blank,
            .body("Kaefden raises his hand. Coalition mages answer — a net of blue crystal light pins Vashirr's staff."),
            .body("Vashirr struggles, then the gray wood splinters. Dark energy recoils into the portal and collapses it."),
            .body("Vashirr drops to his knees in the surf, powerless."),
            .speech("Kaefden IV: The Age ends your treachery here. Agromanian armies scatter without his portals."),
            .speech("Kaefden IV: You will answer to Kaefden law — bound, not butchered. We will use what we must. We will chain what we can."),
            .speech("Vashirr: Then bury your united Avasia in blue crystal. History will know I tried to end the schism."),
            .speech("Vashirr: This land will forget you too, Kaefden."),
            .body("Guards bind Vashirr. The coalition cheers along the shore — ragged, exhausted, real.")
        ]
    }

    private func resolutionLines(state: inout SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .blank,
            .speech("Kaefden IV: Cataracta paid the highest price. Aylova will remember."),
            .symbol("Return to Aylova.")
        ]
        lines.insert(contentsOf: SoCQuestProgress.grantQuestExp(50, state: &state), at: 1)
        return lines
    }

    private func homewardLines() -> [StyledLine] {
        [
            .body("The column turns homeward. The war is over."),
            .body("Somewhere ahead, ledgers open — crystal, plate, and the price of peace.")
        ]
    }
}
