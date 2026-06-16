import Foundation
import AvasiaEngine

/// Act IV march corridor — one authored patrol encounter (iOS authored).
struct SoCNorthernMarchRoom: SoCRoomScript {
    let id: SoCRoomID = .northernMarch
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "MARCH", "PROCEED", "NORTH"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.northernMarchPhase == .notStarted else { return nil }
        state.northernMarchPhase = .refugees
        return roadLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.inCombat {
            return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
        }
        if state.northernMarchCleared {
            return [
                .title("Northern March"),
                .body("The road ahead climbs toward distant ridgelines — Oceandale country."),
                .hint("CONTINUE toward the war front.")
            ]
        }
        switch state.northernMarchPhase {
        case .notStarted, .refugees:
            var hints: [StyledLine] = [.hint("CONTINUE along the road.")]
            if let bypass = SoCClassIngenuity.bypassHint(for: state) {
                hints.append(bypass)
            }
            return hints
        case .patrolCombat:
            return SoCCombat.statLines(state: state) + [.hint("ATTACK the skirmisher.")]
        case .aftermath:
            return [.hint("CONTINUE toward Oceandale ridge.")]
        case .done:
            return [.hint("CONTINUE toward the war front.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.inCombat {
            return handleCombat(input, &state)
        }

        if state.northernMarchCleared {
            if advances(input) {
                return SoCTurnResult(frontApproachLines(), .move(.oceandaleFront))
            }
            return SoCTurnResult([.hint("CONTINUE toward Oceandale ridge.")])
        }

        if [.notStarted, .refugees].contains(state.northernMarchPhase),
           SoCClassIngenuity.matches(input, playerClass: state.playerClass) {
            return classBypass(&state)
        }

        if advances(input) {
            switch state.northernMarchPhase {
            case .notStarted, .refugees:
                state.northernMarchPhase = .patrolCombat
                return SoCTurnResult(patrolAmbushLines() + beginPatrol(state: &state))

            case .aftermath:
                state.northernMarchPhase = .done
                state.northernMarchCleared = true
                return SoCTurnResult(clearanceLines())

            case .patrolCombat, .done:
                return SoCTurnResult([.hint("CONTINUE along the road.")])
            }
        }

        return SoCTurnResult([.hint("CONTINUE along the northern road.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func handleCombat(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        let result = SoCCombat.handle(input, state: &state)
        var output = SoCCombat.statLines(state: state) + result.lines

        if result.died {
            return SoCTurnResult(output, .stay, playerDied: true)
        }

        if result.fled {
            state.northernMarchPhase = .aftermath
            output.append(.body("You regroup with the column — the skirmisher loses your trail."))
            output.append(contentsOf: patrolVictoryLines(state))
            return SoCTurnResult(output)
        }

        guard !state.inCombat else {
            return SoCTurnResult(output)
        }

        state.northernMarchPhase = .aftermath
        output.append(contentsOf: patrolVictoryLines(state))
        return SoCTurnResult(output)
    }

    private func beginPatrol(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Skirmisher", atk: 7, speed: 7, hp: 16, luck: 4),
            deathText: "The skirmisher's blade finds the gap in your guard.",
            state: &state,
            allowsFlee: true
        )
        return [
            .body("The skirmisher's pauldron bears fresh chant-scores — flesh-magic not yet fully bred in."),
            .blank
        ] + SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func roadLines() -> [StyledLine] {
        [
            .title("Northern March"),
            .body("The coalition road turns to mud. Rain has been falling since Aylova."),
            .body("A column of refugees passes in the opposite direction — children bundled in blankets, elders staring through you."),
            .speech("Refugee woman: They burned our granary with mage-fire. Don't stop on that ridge.")
        ]
    }

    private func patrolAmbushLines() -> [StyledLine] {
        [
            .blank,
            .body("Your sergeant raises a fist. The column halts."),
            .body("Three Agromanian scouts break from the treeline — one peels off toward your position."),
            .speech("Coalition Sergeant: Skirmisher on us! Druid — handle it!")
        ]
    }

    private func patrolVictoryLines(_ state: SoCGameState) -> [StyledLine] {
        let sergeantTail: String
        switch state.throneRecountStyle {
        case .reportFacts:
            sergeantTail = "Scouts report mage-fire on the ridgeline — coordinates match the outpost. Move."
        default:
            sergeantTail = "Keep moving — Oceandale ridge before sundown."
        }
        return [
            .blank,
            .body("The skirmisher falls. Your sergeant signals the column forward."),
            .speech("Coalition Sergeant: First blood. \(sergeantTail)"),
            .body("Smoke rises ahead, thicker now. You can smell burned timber on the wind.")
        ]
    }

    private func clearanceLines() -> [StyledLine] {
        [
            .blank,
            .symbol("Oceandale ridge lies ahead."),
            .hint("CONTINUE toward the war front.")
        ]
    }

    private func frontApproachLines() -> [StyledLine] {
        [.body("The column crests a low hill. Distant horns — and the flash of mage-fire on the ridgeline.")]
    }

    private func classBypass(_ state: inout SoCGameState) -> SoCTurnResult {
        state.scoutShortcut = true
        state.northernMarchPhase = .done
        state.northernMarchCleared = true
        let lines: [StyledLine]
        switch state.playerClass {
        case .scout:
            lines = [
                .body("You leave the column and ghost through the treeline, marking patrol routes for the sergeant."),
                .speech("Coalition Sergeant: Good eyes. We slip past — Oceandale before sundown.")
            ]
        case .hunter:
            lines = [
                .body("You read fresh boot-prints in the mud and cut uphill through the pines."),
                .body("The skirmisher never reaches the road — your wolf-spirit already had their angle."),
                .speech("Coalition Sergeant: Clean kill, no alarm. Column moves — Oceandale before sundown.")
            ]
        case .guardian:
            lines = [
                .body("You step into the open with shield raised. The skirmisher checks stride — one heartbeat of doubt."),
                .body("The column melts into the roadside ditch while you hold the line."),
                .speech("Coalition Sergeant: Bear work. They never saw the rest of us. Oceandale before sundown.")
            ]
        case .none:
            lines = [.body("You find a gap in the patrol and slip through.")]
        }
        var output = lines
        output.append(contentsOf: SoCQuestProgress.grantQuestExp(15, state: &state))
        output.append(contentsOf: [.blank, .symbol("Oceandale ridge lies ahead."), .hint("CONTINUE toward the war front.")])
        return SoCTurnResult(output)
    }
}
