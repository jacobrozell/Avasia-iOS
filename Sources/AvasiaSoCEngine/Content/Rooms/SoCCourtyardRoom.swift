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
            .body("You quickly dispatch the Agromanian and reassess the area around you."),
            .body("Destros is lying on the floor and an Agromanian is charging toward him."),
            .body("You swiftly position yourself in-between Destros and the Agromanian."),
            .blank
        ]
    }

    private func beginCombat1(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Grunt", atk: 5, speed: 5, hp: 15, luck: 0),
            deathText: "The Agromanian Grunt lays his mace into the side of your head.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func beginCombat2(state: inout SoCGameState) -> [StyledLine] {
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Agromanian Warrior", atk: 6, speed: 3, hp: 18, luck: 0),
            deathText: "The Agromanian Warrior's sword pierces your chest.",
            state: &state
        )
        return SoCCombat.statLines(state: state) + [.hint("What do will you do?")]
    }

    private func afterCombat2() -> [StyledLine] {
        [
            .body("Another Agromanian falls to their death."),
            .body("You turn to help Destros, but it seems your efforts were in vain."),
            .body("By the time you managed to get to his side, he had already passed."),
            .blank,
            .body("Filled with rage, you turn to find another target,"),
            .body("but you quickly realize that all of the fighting has come to a stand still."),
            .blank,
            .body("Countless Cataractan lie dead on the ground in pools of their own blood."),
            .body("Any survivors are being held hostage by Agromanians around you."),
            .blank,
            .body("It is in everyone's best interest if you stand still.")
        ]
    }

    private func introLines() -> [StyledLine] {
        [
            .title("Courtyard"),
            .body("You enter the courtyard and see dozens of druids training."),
            .body("Suddenly, another Druid appears next to you and speaks."),
            .blank,
            .speech("Nice of you to join us! My name is Dentros."),
            .blank,
            .body("You introduce yourself and tell Dentros that you're here to join the legion."),
            .blank,
            .speech("Well, let's not waste anytime then!."),
            .speech("We have three spirit animals that are best known for their skill in combat."),
            .speech("The Wolf, the Bear, and the Fox."),
            .speech("Which are you?")
        ]
    }

    private func classConfirmLines(_ state: SoCGameState) -> [StyledLine] {
        switch state.playerClass {
        case .hunter:
            return [
                .blank,
                .speech("Ah, I could tell your spirit animal was the wolf when I saw you."),
                .speech("The wolves are very formidable in battle."),
                .speech("They hit hard and can take hits well too."),
                .blank
            ]
        case .guardian:
            return [
                .blank,
                .speech("Yes, the Bear. Bears are our front-line defense."),
                .speech("They can take quite a beating before they're defeated."),
                .blank
            ]
        case .scout:
            return [
                .blank,
                .speech("Hm, yes a fox. My spirit animal is the fox as well."),
                .speech("We are well known for our ability to move quickly and silently."),
                .speech("Foxes make up most of our scouting force."),
                .blank
            ]
        case .none:
            return []
        }
    }

    private func kimiousLines() -> [StyledLine] {
        [
            .body("You head further into the courtyard to see the king of Cataracta, Kimious, walk out of the Cataractan keep."),
            .body("He speaks out to the druids in the courtyard as you make your way to the front to get a good view."),
            .blank,
            .speech("My friends! The time to fight is drawing near!"),
            .speech("Our people are under constant threat of an Agromanian invasion."),
            .speech("The attack on Oceandale was far too close to Cataracta."),
            .speech("We can no longer rely on our hidden passages and the mountainess terrain to defend us."),
            .speech("We must take the fight to them!"),
            .blank,
            .body("The crowd roars in agreement."),
            .blank,
            .speech("Your undying loyalty to our home speaks volumes an-"),
            .blank,
            .body("Kimious is interrupted by a blinding flash of light, followed by a cascade of darkness."),
            .body("The sky turns blood red as a dark portal forms at the entrance of the keep."),
            .body("A man donned in a dark hooded robe, holding a gray wooden staff walks out of the portal."),
            .body("From behind the man floods dozens of what brutish warriors."),
            .blank,
            .body("Dentros shouts out to you."),
            .blank,
            .speech("Agromanians! They've found us! But how?!"),
            .blank,
            .body("Guards rush to protect Kimious, but they're quickly outmatched by the Agromanians sheer numbers"),
            .body("The hooded man points his staff to Kimious and blasts him with a bolt of dark energy."),
            .body("Kimious falls to the floor, lifeless."),
            .blank,
            .body("The Druids in the courtyard shout in horror and charge in to fight the oncoming Agromanians"),
            .body("The hooded man points his staff toward you and unleashes another bolt of energy."),
            .body("Before you can react, Dentros shoves you out of the line of fire and takes the hit."),
            .body("As you stumble over, an Agromanian confronts you.")
        ]
    }

    private func vashirrLines() -> [StyledLine] {
        [
            .blank,
            .body("From out of the crowd of Agromanians surrounding you, the hooded man comes."),
            .body("He walks forward and is only a few feet in-front of you."),
            .body("He removes his hood."),
            .body("The man has a scar running across his left eye that continues to his chin."),
            .body("He speaks to you in a deep, raspy voice."),
            .blank,
            .speech("Listen to me, and listen carefully."),
            .body("He places the tip of his staff to your head."),
            .body("You can hear and feel the energy resonating from it."),
            .blank,
            .speech("I have a message for you to deliver."),
            .speech("Tell King Kaefden IV of the horrors his ignorance has brought."),
            .speech("Tell him that Cataracta and its king have fallen."),
            .speech("Tell him that so long as he holds his unearned claim on this land..."),
            .blank,
            .speech("I will not stop."),
            .blank,
            .body("Vashirr turns and with a snap, the Agromanians execute every Druid in their captivity."),
            .body("You can only watch in horror as countless people are mercilessly massacred."),
            .body("Vashirr returns through the dark portal and before you can do anything to stop the onslaught,"),
            .body("An Agromanian bashes your head in with his axe, knocking you out cold.")
        ]
    }

    private func ashesLines() -> [StyledLine] {
        [
            .blank,
            .body("Time passes and you awaken alone in the same place you were before."),
            .body("You stumble up off the ground and immediately smell burning fires."),
            .body("You look to the Cataractan castle. Now in flames and rubble."),
            .body("The entire city is in ashes.")
        ]
    }
}
