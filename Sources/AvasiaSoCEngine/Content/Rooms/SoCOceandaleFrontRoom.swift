import Foundation
import AvasiaEngine

/// Oceandale ridge assault — two-wave authored battle (iOS authored).
struct SoCOceandaleFrontRoom: SoCRoomScript {
    let id: SoCRoomID = .oceandaleFront
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "CHARGE", "ATTACK", "PROCEED", "YES"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.oceandaleFrontPhase == .notStarted else { return nil }
        state.oceandaleFrontPhase = .staging
        return stagingLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.inCombat {
            return SoCCombat.statLines(state: state) + [.hint("ATTACK to fight.")]
        }
        if state.oceandaleFrontCleared {
            return [
                .title("Oceandale Ridge"),
                .body("The ridge is yours. Coalition banners replace Agromanian colors on the heights."),
                .hint("ADVANCE toward the mage outpost.")
            ]
        }
        switch state.oceandaleFrontPhase {
        case .notStarted, .staging:
            return [.hint("CONTINUE when horns sound.")]
        case .charge:
            return [.hint("CONTINUE into the breach.")]
        case .combat1, .combat2:
            return SoCCombat.statLines(state: state) + [.hint("ATTACK.")]
        case .betweenWaves:
            return [.hint("CONTINUE through the mage-fire.")]
        case .victory:
            return [.hint("CONTINUE to regroup.")]
        case .done:
            return [.hint("ADVANCE toward the mage outpost.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.inCombat {
            return handleCombat(input, &state)
        }

        if state.oceandaleFrontCleared {
            if input.contains("ADVANCE") || input.contains("MARCH") || advances(input) {
                return SoCTurnResult(advanceLines(), .move(.mageOutpost))
            }
            return SoCTurnResult([.hint("ADVANCE toward the mage outpost.")])
        }

        if advances(input) {
            return advanceScene(&state)
        }
        return SoCTurnResult([.hint("CONTINUE when you are ready.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func advanceScene(_ state: inout SoCGameState) -> SoCTurnResult {
        switch state.oceandaleFrontPhase {
        case .notStarted, .staging:
            state.oceandaleFrontPhase = .charge
            return SoCTurnResult(chargeLines(state))

        case .charge:
            state.oceandaleFrontPhase = .combat1
            return SoCTurnResult(waveOneLines() + beginWave1(state: &state))

        case .betweenWaves:
            state.oceandaleFrontPhase = .combat2
            return SoCTurnResult(waveTwoLines() + beginWave2(state: &state))

        case .victory:
            state.oceandaleFrontPhase = .done
            state.oceandaleFrontCleared = true
            state.unlockTrophy(.oceandaleVictor)
            var lines = heldRidgeLines(state)
            lines.append(contentsOf: SoCQuestProgress.grantQuestExp(25, state: &state))
            lines.append(.title("Oceandale ridge secured"))
            return SoCTurnResult(lines)

        case .combat1, .combat2, .done:
            return SoCTurnResult([.hint("ATTACK the enemy in front of you.")])
        }
    }

    private func handleCombat(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        let phase = state.oceandaleFrontPhase
        let (lines, died) = SoCCombat.handle(input, state: &state)
        var output = SoCCombat.statLines(state: state) + lines

        if died {
            return SoCTurnResult(output, .stay, playerDied: true)
        }
        guard !state.inCombat else {
            return SoCTurnResult(output)
        }

        switch phase {
        case .combat1:
            state.oceandaleFrontPhase = .betweenWaves
            state.restoreHealthToMax()
            output.append(contentsOf: betweenWavesLines())
            return SoCTurnResult(output)

        case .combat2:
            state.oceandaleFrontPhase = .victory
            output.append(contentsOf: waveTwoVictoryLines())
            return SoCTurnResult(output)

        default:
            return SoCTurnResult(output)
        }
    }

    private func beginWave1(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Raider", atk: 6, speed: 6, hp: 14, luck: 0),
            deathText: "A raider's axe catches you across the ribs.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func beginWave2(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Battle Mage", atk: 9, speed: 5, hp: 22, luck: 0),
            deathText: "Mage-fire consumes your shield line.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func stagingLines() -> [StyledLine] {
        [
            .title("Oceandale Ridge"),
            .body("The coalition halts at the tree line. Below, the ridge burns — Agromanian banners where KoN's beach once lay quiet."),
            .body("Spell-flash stutters along the heights. Your sergeant grips your shoulder."),
            .speech("Coalition Sergeant: That's Vashirr's teaching. Hold until the horns — then we take the ridge or die on it.")
        ]
    }

    private func chargeLines(_ state: SoCGameState) -> [StyledLine] {
        let role: String
        switch state.playerClass {
        case .hunter: role = "You sprint with the assault wedge, wolf-instinct driving you uphill."
        case .guardian: role = "You brace the shield wall as the column surges into arrow-fire."
        case .scout: role = "You dart between burning wagons, marking gaps in their line for the sergeant."
        case .none: role = "You run with the column into smoke and screaming steel."
        }
        return [
            .blank,
            .body("Horns blast. The coalition charges."),
            .body(role),
            .blank,
            .body("Agromanian raiders meet you halfway up the slope.")
        ]
    }

    private func waveOneLines() -> [StyledLine] { [] }

    private func betweenWavesLines() -> [StyledLine] {
        [
            .blank,
            .body("The first wave breaks. For a breath, the slope is yours."),
            .body("Then blue-white fire erupts from the ridgeline — a battle mage channeling Vashirr's craft."),
            .speech("Coalition Sergeant: Mage on the crest! Push through!")
        ]
    }

    private func waveTwoLines() -> [StyledLine] { [] }

    private func waveTwoVictoryLines() -> [StyledLine] {
        [
            .blank,
            .body("The battle mage crumples. Mage-fire gutters out along the ridge."),
            .body("Agromanian survivors flee downhill toward the treeline.")
        ]
    }

    private func heldRidgeLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .blank,
            .speech("Coalition Sergeant: Ridge held! Scouts report a mage outpost beyond the far wood — that's where they're coordinating."),
            .symbol("Advance to the mage outpost.")
        ]
    }

    private func advanceLines() -> [StyledLine] {
        [.body("Your unit peels off the ridge and moves into the scrub toward reported mage-fire.")]
    }
}
