import Foundation
import AvasiaEngine

/// Night approach to Agromanian mage outpost (iOS authored).
struct SoCMageOutpostRoom: SoCRoomScript {
    let id: SoCRoomID = .mageOutpost
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "PROCEED", "INFILTRATE", "YES"]
    private let stealthTriggers = ["SCOUT", "STEALTH", "SNEAK"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.mageOutpostPhase == .notStarted else { return nil }
        state.mageOutpostPhase = .approach
        return approachLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.inCombat {
            return SoCCombat.statLines(state: state) + [.hint("ATTACK.")]
        }
        if state.mageOutpostCleared {
            return [
                .title("Mage Outpost"),
                .body("The captured outpost smolders. Coalition scouts already copy the ward maps."),
                .hint("MARCH to Vashirr's redoubt.")
            ]
        }
        switch state.mageOutpostPhase {
        case .notStarted, .approach:
            return [.hint("CONTINUE toward the outpost.")]
        case .infiltration:
            if state.playerClass == .scout {
                return [.hint("SCOUT to slip past, or CONTINUE to assault the gate.")]
            }
            return [.hint("CONTINUE to assault the gate.")]
        case .combat:
            return SoCCombat.statLines(state: state) + [.hint("ATTACK.")]
        case .intel:
            return [.hint("CONTINUE with the intel.")]
        case .done:
            return [.hint("MARCH to Vashirr's redoubt.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.inCombat {
            return handleCombat(input, &state)
        }

        if state.mageOutpostCleared {
            if input.contains("MARCH") || advances(input) {
                return SoCTurnResult(marchLines(), .move(.vashirrStand))
            }
            return SoCTurnResult([.hint("MARCH to Vashirr's redoubt.")])
        }

        if state.mageOutpostPhase == .infiltration,
           state.playerClass == .scout,
           stealthTriggers.contains(where: { input.contains($0) }) {
            return completeIntel(&state, stealth: true)
        }

        if advances(input) {
            return advanceScene(&state)
        }
        return SoCTurnResult([.hint("CONTINUE toward the outpost.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func advanceScene(_ state: inout SoCGameState) -> SoCTurnResult {
        switch state.mageOutpostPhase {
        case .notStarted, .approach:
            state.mageOutpostPhase = .infiltration
            return SoCTurnResult(infiltrationLines(state))

        case .infiltration:
            state.mageOutpostPhase = .combat
            return SoCTurnResult(assaultLines() + beginLieutenant(state: &state))

        case .intel:
            state.mageOutpostPhase = .done
            state.mageOutpostCleared = true
            return SoCTurnResult(intelCompleteLines(state: &state))

        case .combat, .done:
            return SoCTurnResult([.hint("CONTINUE.")])
        }
    }

    private func handleCombat(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        let result = SoCCombat.handle(input, state: &state)
        var output = SoCCombat.statLines(state: state) + result.lines

        if result.died {
            return SoCTurnResult(output, .stay, playerDied: true)
        }

        if result.fled {
            state.mageOutpostPhase = .intel
            output.append(.body("You slip away with partial maps — enough to find Vashirr's redoubt."))
            output.append(contentsOf: lieutenantFallsLines())
            return SoCTurnResult(output)
        }

        guard !state.inCombat else {
            return SoCTurnResult(output)
        }

        state.mageOutpostPhase = .intel
        output.append(contentsOf: lieutenantFallsLines())
        return SoCTurnResult(output)
    }

    private func completeIntel(_ state: inout SoCGameState, stealth: Bool) -> SoCTurnResult {
        state.mageOutpostPhase = .done
        state.mageOutpostCleared = true
        var lines = stealthIntelLines()
        if stealth {
            lines.insert(.body("You ghost between ward-stakes, copy the battle maps, and vanish before the guards turn."), at: 1)
        }
        lines.append(contentsOf: intelCompleteLines(state: &state))
        return SoCTurnResult(lines)
    }

    private func beginLieutenant(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Mage Lieutenant", atk: 10, speed: 6, hp: 24, luck: 0),
            deathText: "The lieutenant's staff splits your ward and drops you to the mud.",
            state: &state,
            allowsFlee: true
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func approachLines() -> [StyledLine] {
        [
            .title("Mage Outpost"),
            .body("Blue ward-light bleeds through the pines. Agromanian sentries pace a ring of carved stakes."),
            .body("Your sergeant whispers the plan."),
            .speech("Coalition Sergeant: Burn their maps or steal them. Either way, we need Vashirr's position before dawn.")
        ]
    }

    private func infiltrationLines(_ state: SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = [
            .blank,
            .body("You crawl through wet ferns toward the palisade gate.")
        ]
        if state.playerClass == .scout {
            lines.append(.hint("SCOUT to infiltrate silently, or CONTINUE to hit the gate."))
        }
        return lines
    }

    private func assaultLines() -> [StyledLine] {
        [
            .blank,
            .body("The gate splinters. A robed lieutenant rises from the command table, staff already glowing."),
            .speech("Mage Lieutenant: Cataractan ash-walker? Vashirr warned us you'd come.")
        ]
    }

    private func lieutenantFallsLines() -> [StyledLine] {
        [
            .blank,
            .body("The lieutenant collapses. Ward-stakes flicker and die."),
            .body("On the table: charcoal maps marking a shoreside redoubt — Vashirr's stand."),
            .body("Beside them, a training sheet titled Many Hands — fuse ward-light into plate, bind chant to obedience."),
            .speech("Coalition Sergeant: He thinks he's freeing magic. Looks like slavery with spell-light.")
        ]
    }

    private func stealthIntelLines() -> [StyledLine] {
        [
            .title("Mage Outpost"),
            .body("You slip back to the tree line undetected, maps folded against your chest."),
            .speech("Coalition Sergeant: Fox work. Vashirr's redoubt — two leagues east on the shore.")
        ]
    }

    private func intelCompleteLines(state: inout SoCGameState) -> [StyledLine] {
        var lines: [StyledLine] = [.blank, .symbol("March on Vashirr's redoubt.")]
        lines.insert(contentsOf: SoCQuestProgress.grantQuestExp(20, state: &state), at: 1)
        return lines
    }

    private func marchLines() -> [StyledLine] {
        [.body("The column moves east through predawn mist, toward the shore and the end of the war.")]
    }
}
