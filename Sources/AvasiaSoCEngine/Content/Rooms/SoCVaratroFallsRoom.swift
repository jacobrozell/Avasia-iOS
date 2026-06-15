import Foundation
import AvasiaEngine

/// Tomb dungeon at Varatro Falls — recover Kaefden's Blade of Courage (iOS authored).
struct SoCVaratroFallsRoom: SoCRoomScript {
    let id: SoCRoomID = .varatroFalls
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "SEARCH", "ENTER", "PROCEED", "YES"]
    private let departTriggers = ["MARCH", "DEPART", "LEAVE", "OFEL"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.varatroFallsPhase == .notStarted else { return nil }
        state.varatroFallsPhase = .approach
        return approachLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.inCombat {
            return SoCCombat.statLines(state: state) + [.hint("ATTACK the warden.")]
        }
        if state.varatroFallsCleared {
            return [
                .title("Varatro Falls"),
                .body("The Blade rests at your hip. Mist drifts over the first king's tomb."),
                .hint("MARCH to Ofelos with the Blade.")
            ]
        }
        switch state.varatroFallsPhase {
        case .notStarted, .approach:
            return [.hint("CONTINUE toward the falls.")]
        case .tomb:
            return [.hint("SEARCH the tomb chamber.")]
        case .combat:
            return SoCCombat.statLines(state: state) + [.hint("ATTACK.")]
        case .recovered:
            return [.hint("CONTINUE — then MARCH to Ofelos.")]
        case .done:
            return [.hint("MARCH to Ofelos.")]
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.inCombat {
            return handleCombat(input, &state)
        }

        if state.varatroFallsCleared {
            if departs(input) {
                return SoCTurnResult(ofelosBoundLines(), .move(.ofelos))
            }
            return SoCTurnResult([.hint("MARCH to Ofelos.")])
        }

        if departs(input), state.varatroFallsPhase == .done {
            return SoCTurnResult(ofelosBoundLines(), .move(.ofelos))
        }

        if advances(input) {
            return advanceScene(&state)
        }

        return SoCTurnResult([.hint("CONTINUE along the falls.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func departs(_ input: ParsedInput) -> Bool {
        departTriggers.contains { input.contains($0) }
    }

    private func advanceScene(_ state: inout SoCGameState) -> SoCTurnResult {
        switch state.varatroFallsPhase {
        case .notStarted, .approach:
            state.varatroFallsPhase = .tomb
            return SoCTurnResult(tombLines())

        case .tomb:
            state.varatroFallsPhase = .combat
            return SoCTurnResult(wardenAmbushLines() + beginWarden(state: &state))

        case .recovered:
            state.varatroFallsPhase = .done
            state.varatroFallsCleared = true
            var lines = bladeTakenLines()
            lines.append(.hint("MARCH to Ofelos."))
            return SoCTurnResult(lines)

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

        guard !state.inCombat else {
            return SoCTurnResult(output)
        }

        state.varatroFallsPhase = .recovered
        state.addItem(.bladeOfCourage)
        state.unlockTrophy(.bladeBearer)
        output.append(contentsOf: wardenDefeatedLines())
        output.append(.hint("CONTINUE to take the Blade."))
        return SoCTurnResult(output)
    }

    private func beginWarden(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Paladin Tomb Warden", atk: 8, speed: 4, hp: 20, luck: 1),
            deathText: "The warden's spell-blade finds the gap in your guard.",
            state: &state,
            allowsFlee: false
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func approachLines() -> [StyledLine] {
        [
            .title("Varatro Falls"),
            .body("The Varatho roars white over black cliffs — older than Cataracta's bridge, older than the war."),
            .body("Carved steps descend behind the curtain of spray into a tomb lit by failing blue crystals."),
            .body("Agromanian boot-prints mark the mud. You are not the first to come hunting.")
        ]
    }

    private func tombLines() -> [StyledLine] {
        [
            .blank,
            .body("The first King Kaefden lies under a stone lid chased with the bloodline sigil."),
            .body("Embedded in his hands: a sword whose edge still catches light after centuries."),
            .speech("A voice from the shadows: That blade belongs to the northwest now.")
        ]
    }

    private func wardenAmbushLines() -> [StyledLine] {
        [
            .blank,
            .body("A Paladin in corroded plate steps between you and the tomb — Vashirr's craft written in the glow along his gauntlets.")
        ]
    }

    private func wardenDefeatedLines() -> [StyledLine] {
        [
            .blank,
            .body("The warden collapses. Spell-light gutters out along the falls.")
        ]
    }

    private func bladeTakenLines() -> [StyledLine] {
        [
            .body("You lift Kaefden's Blade of Courage from the first king's resting hands."),
            .body("The metal is cold, impossibly balanced — an oath made steel."),
            .symbol("Ofelos awaits the Blade."),
            .title("Blade recovered")
        ]
    }

    private func ofelosBoundLines() -> [StyledLine] {
        [.body("You sheath the Blade and follow the river road toward neutral country.")]
    }
}
