import Foundation
import AvasiaEngine

/// Critical path set piece — verbatim from `Avasia-SoC/Cataracta/Cataracta_Courtyard.py`.
struct SoCCourtyardRoom: SoCRoomScript {
    let id: SoCRoomID = .cataractaCourtyard

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.courtyardComplete {
            return [
                .title("Courtyard"),
                .body("The courtyard is ash and silence."),
                .hint("There is nothing left here.")
            ]
        }
        if state.inCombat {
            return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
        }
        if state.courtyardPhase == .notStarted {
            return introLines() + [.hint("Wolf, Bear, or Fox?")]
        }
        return [.hint("Which way would you like to investigate?")]
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.courtyardComplete {
            return SoCTurnResult([.body("There is nothing left here.")], .move(.cataractaNorth))
        }

        if state.inCombat {
            return handleCombat(input, &state)
        }

        switch state.courtyardPhase {
        case .notStarted, .pickClass:
            if state.courtyardPhase == .notStarted {
                state.courtyardPhase = .pickClass
            }
            if input.contains("WOLF") {
                state.applyClass(.hunter)
                return startMassacre(&state)
            }
            if input.contains("FOX") {
                state.applyClass(.scout)
                return startMassacre(&state)
            }
            if input.contains("BEAR") {
                state.applyClass(.guardian)
                return startMassacre(&state)
            }
            return SoCTurnResult([.speech("Wolf, Bear, or Fox?")])

        default:
            return SoCTurnResult([.hint("The courtyard is silent.")])
        }
    }

    private func startMassacre(_ state: inout SoCGameState) -> SoCTurnResult {
        state.courtyardPhase = .combat1
        var lines = classConfirmLines(state) + kimiousLines()
        lines.append(contentsOf: beginCombat1(state: &state))
        return SoCTurnResult(lines)
    }

    private func handleCombat(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        let phase = state.courtyardPhase
        let result = SoCCombat.handle(input, state: &state)
        var output = SoCCombat.statLines(state: state) + result.lines

        if result.died {
            return SoCTurnResult(output, .stay, playerDied: true)
        }

        guard !state.inCombat else {
            return SoCTurnResult(output)
        }

        switch phase {
        case .combat1:
            state.courtyardPhase = .combat2
            state.restoreHealthToMax()
            output.append(contentsOf: betweenCombatsLines())
            output.append(contentsOf: beginCombat2(state: &state))
            return SoCTurnResult(output)

        case .combat2:
            output.append(contentsOf: afterCombat2())
            output.append(contentsOf: vashirrLines())
            output.append(contentsOf: ashesLines())
            state.courtyardComplete = true
            state.courtyardPhase = .done
            return SoCTurnResult(output, .move(.portalRoom))

        default:
            return SoCTurnResult(output)
        }
    }

    private func betweenCombatsLines() -> [StyledLine] {
        [
            .body("You dispatch the Agromanian and wheel back toward Dentros."),
            .body("He lies where he fell, clutching the bolt-wound. Another warrior charges him."),
            .body("You throw yourself between them."),
            .blank,
            .body("A Legion healer's hands flash over your ribs in the chaos — borrowed seconds, not mercy.")
        ]
    }

    private func beginCombat1(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Grunt", atk: 5, speed: 5, hp: 15, luck: 3),
            deathText: "The Agromanian Grunt lays his mace into the side of your head.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func beginCombat2(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Warrior", atk: 6, speed: 3, hp: 18, luck: 3),
            deathText: "The Agromanian Warrior's sword pierces your chest.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func afterCombat2() -> [StyledLine] {
        [
            .body("Another Agromanian falls."),
            .body("You turn to Dentros. His eyes find yours for a heartbeat — then close."),
            .body("The bolt did its work. You were too slow."),
            .blank,
            .body("Rage sends you hunting for another target, but the courtyard has gone still."),
            .blank,
            .body("Cataractan dead lie in their own blood. Survivors kneel under Agromanian blades."),
            .blank,
            .body("You freeze. Moving would only add your name to the count.")
        ]
    }

    private func introLines() -> [StyledLine] {
        [
            .title("Courtyard"),
            .body("Dozens of druids drill in the yard — forms, footwork, spirit animals pacing the edges."),
            .body("A red fox darts between recruits and resolves into Dentros at your shoulder."),
            .blank,
            .speech("Nice of you to join us. I'm Dentros."),
            .blank,
            .body("You give your name and say you've come to enlist."),
            .blank,
            .speech("Then we won't waste time."),
            .speech("Three spirit animals define our combat lines: Wolf, Bear, and Fox."),
            .speech("Which walks with you?")
        ]
    }

    private func classConfirmLines(_ state: SoCGameState) -> [StyledLine] {
        switch state.playerClass {
        case .hunter:
            return [
                .blank,
                .speech("Knew it — wolf in your stride."),
                .speech("Hard hits, fast feet. Kimious will want you near the front."),
                .blank
            ]
        case .guardian:
            return [
                .blank,
                .speech("Bear line. Good — someone has to hold the gate when the rest of us break."),
                .blank
            ]
        case .scout:
            return [
                .blank,
                .speech("Fox, then. Mine too."),
                .speech("Quick and quiet — most of our scouts wear that shape."),
                .blank
            ]
        case .none:
            return []
        }
    }

    private func kimiousLines() -> [StyledLine] {
        [
            .body("You press toward the keep as King Kimious steps onto the review stones."),
            .body("He lifts his voice over the drilling recruits."),
            .blank,
            .speech("My friends! The time to fight is drawing near!"),
            .speech("Our people live under constant threat of Agromanian invasion."),
            .speech("Seven years after Oceandale, we still live in its shadow — and in that quiet, Vashirr bred Paladins in Agroman's forges."),
            .speech("Sylvian envoys warn us: share Anula freely now, or Kaefden will requisition it when the war drums loud enough."),
            .speech("They stride openly against us now. Hidden passes and mountain terrain will not be enough."),
            .speech("We must take the fight to them!"),
            .blank,
            .body("The crowd roars."),
            .blank,
            .speech("Your undying loyalty to our home speaks volumes an—"),
            .blank,
            .body("Light blinds the yard — then darkness pours after it."),
            .body("The sky turns blood red. A portal tears open at the keep gate."),
            .body("A hooded man with a gray wooden staff steps through."),
            .body("Behind him spill brutish warriors — some wrapped in spell-light, the Paladins Vashirr forged."),
            .blank,
            .body("Dentros grabs your arm."),
            .blank,
            .speech("Agromanians! They've found us — but how?!"),
            .blank,
            .body("Guards rush Kimious and are swallowed by sheer numbers."),
            .body("The hooded man levels his staff. Dark energy takes Kimious in the chest."),
            .body("The king falls without a sound."),
            .blank,
            .body("Druids scream and charge. The hooded man turns his staff on you."),
            .body("Dentros shoves you aside — the bolt punches through his chest."),
            .body("He drops in the churning yard, still breathing."),
            .body("An Agromanian closes on you while the courtyard tears itself apart.")
        ]
    }

    private func vashirrLines() -> [StyledLine] {
        [
            .blank,
            .body("The hooded man parts the Agromanian ring and stops a few feet from your face."),
            .body("He drops his hood."),
            .body("A scar cuts from his left eye to his chin."),
            .blank,
            .speech("You rebuild what failed — a floating city, council whispers, a king who puts stones back in the sky."),
            .speech("I scattered the mages so they would feel the ground again. I forged Paladins so magic would belong to every soldier — not a priesthood in blue robes."),
            .speech("My king and I will knit this continent together. Kaefden's crown is the last stitch that will not hold."),
            .blank,
            .speech("Listen carefully."),
            .body("He sets his staff against your forehead. Energy hums through bone."),
            .blank,
            .speech("My king waited seven years while your boy-king rebuilt. Cataracta is the first lesson."),
            .blank,
            .speech("Deliver a message."),
            .speech("Tell King Kaefden IV what his ignorance bought."),
            .speech("Tell him Cataracta and its king have fallen."),
            .speech("Tell him that so long as he holds his unearned claim on this land..."),
            .blank,
            .speech("I will not stop."),
            .blank,
            .body("Vashirr snaps his fingers. Agromanians cut down every captive druid."),
            .body("You watch, helpless, as the courtyard becomes slaughter."),
            .body("He steps back through the portal. Before you can move, an axe butt takes you behind the ear."),
            .body("Darkness.")
        ]
    }

    private func ashesLines() -> [StyledLine] {
        [
            .blank,
            .body("Time passes and you awaken alone in the same place you were before."),
            .body("You stumble up off the ground and immediately smell burning fires."),
            .body("You look to the Cataractan castle. Now in flames and rubble."),
            .body("The entire city is in ashes."),
            .blank,
            .body("A fallen Paladin lies near your boot — plate still humming a half-finished chant under the soot."),
            .body("You do not know the words. Your skin remembers the rhythm anyway."),
            .blank,
            .body("Somewhere downhill, the garden fountain cracked. Anula dust in the mud where children used to toss coins for luck.")
        ]
    }
}
