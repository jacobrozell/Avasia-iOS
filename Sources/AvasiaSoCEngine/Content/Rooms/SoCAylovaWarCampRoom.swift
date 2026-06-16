import Foundation
import AvasiaEngine

/// Act IV staging — coalition muster at Aylova (iOS authored).
struct SoCAylovaWarCampRoom: SoCRoomScript {
    let id: SoCRoomID = .aylovaWarCamp
    var parseMode: Parser.Mode { .raw }

    private let advanceTriggers = ["CONTINUE", "TALK", "BRIEFING", "YES", "PROCEED"]
    private let marchTriggers = ["MARCH", "NORTH", "DEPART", "LEAVE"]

    func onEnter(_ state: inout SoCGameState) -> [StyledLine]? {
        guard state.warCampPhase == .notStarted else { return nil }
        state.warCampPhase = .arrived
        return arrivalLines()
    }

    func describe(_ state: SoCGameState) -> [StyledLine] {
        if state.aylovaMusterComplete {
            return musterCompleteLines()
        }
        switch state.warCampPhase {
        case .notStarted, .arrived:
            return campLines() + [.hint("CONTINUE for the war briefing.")]
        case .briefing:
            return [.hint("CONTINUE to see the quartermaster.")]
        case .quartermaster:
            return [.hint("BUY POTION (25g), BUY RATIONS (15g), or CONTINUE when ready.")]
        case .readyToMarch:
            return [.hint("MARCH north toward the border.")]
        case .done:
            return musterCompleteLines()
        }
    }

    func handle(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        if state.aylovaMusterComplete {
            if marchTriggers.contains(where: { input.contains($0) }) {
                return SoCTurnResult(marchLines(), .move(bladeQuestDestination(state)))
            }
            return SoCTurnResult([.hint("MARCH north when you are ready.")])
        }

        if state.warCampPhase == .readyToMarch,
           marchTriggers.contains(where: { input.contains($0) }) {
            return advanceScene(&state)
        }

        if input.contains("BUY") || input.contains("PURCHASE") {
            return handlePurchase(input, &state)
        }
        if advances(input) {
            return advanceScene(&state)
        }
        if input.contains("QUARTERMASTER") && state.warCampPhase == .briefing {
            state.warCampPhase = .quartermaster
            return SoCTurnResult(quartermasterLines(state) + provision(&state))
        }
        return SoCTurnResult([.hint("CONTINUE for orders, or MARCH when the horns sound.")])
    }

    private func advances(_ input: ParsedInput) -> Bool {
        advanceTriggers.contains { input.contains($0) }
    }

    private func advanceScene(_ state: inout SoCGameState) -> SoCTurnResult {
        switch state.warCampPhase {
        case .notStarted, .arrived:
            state.warCampPhase = .briefing
            return SoCTurnResult(briefingLines(state))

        case .briefing:
            state.warCampPhase = .quartermaster
            return SoCTurnResult(quartermasterLines(state) + provision(&state))

        case .quartermaster:
            state.warCampPhase = .readyToMarch
            return SoCTurnResult(readyToMarchLines(state))

        case .readyToMarch:
            state.warCampPhase = .done
            state.aylovaMusterComplete = true
            var lines = deploymentLines(state) + marchLines()
            lines.append(.title("War camp muster complete"))
            return SoCTurnResult(lines, .move(.silvariumElders))

        case .done:
            return SoCTurnResult(musterCompleteLines())
        }
    }

    private func handlePurchase(_ input: ParsedInput, _ state: inout SoCGameState) -> SoCTurnResult {
        guard state.warCampPhase == .quartermaster || state.warCampPhase == .briefing else {
            return SoCTurnResult([.body("The quartermaster is not taking orders right now.")])
        }
        if input.contains("POTION") {
            guard state.spendGold(25) else {
                return SoCTurnResult([.body("You need 25 gold for a potion.")])
            }
            state.addItem(.potion)
            return SoCTurnResult([.body("Thekia sells you an extra potion. Gold: \(state.gold)")])
        }
        if input.contains("RATION") {
            guard state.spendGold(15) else {
                return SoCTurnResult([.body("You need 15 gold for field rations.")])
            }
            state.addItem(.fieldRations)
            return SoCTurnResult([.body("You tuck coalition rations into your pack. Gold: \(state.gold)")])
        }
        return SoCTurnResult([.hint("BUY POTION (25g) or BUY RATIONS (15g).")])
    }

    private func provision(_ state: inout SoCGameState) -> [StyledLine] {
        guard !state.aylovaProvisioned else { return [] }
        state.aylovaProvisioned = true
        state.inventory[.potion, default: 0] += 1
        return [.body("Thekia presses a healing potion into your hands.")]
    }

    private func arrivalLines() -> [StyledLine] {
        [
            .title("Aylova War Camp"),
            .body("You march for days with the Cataractan remnant — a thin column of survivors who still wear ash in their hair."),
            .body("Aylova rises ahead: stone walls, coalition banners, and a sea of tents swallowing the fields outside the capital."),
            .body("Horns call officers to their posts. This is where Kaefden's war becomes real.")
        ]
    }

    private func campLines() -> [StyledLine] {
        [
            .title("Aylova War Camp"),
            .body("Smiths hammer at field forges. Nacastrum mages trace wards along the supply wagons."),
            .body("Aylovan officers bark orders in a tongue you almost understand."),
            .body("Your unit's sergeant waves you toward the command pavilion.")
        ]
    }

    private func briefingLines(_ state: SoCGameState) -> [StyledLine] {
        let unit: String
        switch state.playerClass {
        case .hunter: unit = "assault wedge"
        case .guardian: unit = "shield line"
        case .scout: unit = "recon detachment"
        case .none: unit = "general column"
        }
        return [
            .speech(SoCStoryVoice.sergeantOpener(state)),
            .blank,
            .body("She unrolls a map scarred with charcoal X's along the northern border."),
            .speech("Seven years the border held — while Vashirr taught Agromanian steel to drink magic. Those soldiers are Paladins now."),
            .speech("Last week they hit three border villages. Their craft isn't borrowed anymore — it's bred into the rank."),
            .speech("Oceandale ridge is the next push. Hold the high ground and we keep their army out of Aylova's throat."),
            .blank,
            .speech("Before the northern front: Silvarium's elders, Varatro Falls, and Kaefden's Blade of Courage — Ofelos won't march without that symbol."),
            .speech("You ride east to Silvarium first. When Ofelos joins, your \(unit) deploys at first light."),
            .speech("Thekia's tent is east of the cookfires. Don't report to the front empty-handed.")
        ]
    }

    private func quartermasterLines(_ state: SoCGameState) -> [StyledLine] {
        let gear: String
        switch state.playerClass {
        case .hunter:
            gear = "a Legion hunter's blade — light, cruel, and yours until it breaks"
        case .guardian:
            gear = "a battered shield boss and bracers stamped with coalition marks"
        case .scout:
            gear = "a scout's cloak pin and a coil of chalk for marking trails"
        case .none:
            gear = "a coalition armband and field kit"
        }
        return [
            .blank,
            .body("Thekia meets you between stacked crates, purple robes traded for a mage's field tabard."),
            .speech("Thekia: I heard Kaefden's pledge. Don't make me regret vouching for you in the throne room."),
            .blank,
            .body("She fits you with \(gear).")
        ]
    }

    private func readyToMarchLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .speech("Thekia: The northern road is muddy and watched. Stay with your sergeant."),
            .speech("If you see mage-fire on the horizon — you run, or you shield the man beside you. Understood?"),
            .blank,
            .body("You nod. For the first time since Cataracta, you have a unit, gear, and a direction.")
        ]
    }

    private func deploymentLines(_ state: SoCGameState) -> [StyledLine] {
        [
            .blank,
            .body("Horns sound three short blasts — march order."),
            .body("The coalition column turns north, toward smoke on the horizon."),
            .symbol("Ride east to Silvarium — then Varatro Falls and Ofelos.")
        ]
    }

    private func marchLines() -> [StyledLine] {
        [.body("You fall in with your unit and take the northern road.")]
    }

    private func musterCompleteLines() -> [StyledLine] {
        [
            .title("Aylova War Camp"),
            .body("The camp bustles behind you. The Blade quest leads east before the northern front."),
            .hint("MARCH east toward Silvarium.")
        ]
    }

    private func bladeQuestDestination(_ state: SoCGameState) -> SoCRoomID {
        if !state.silvariumEldersComplete { return .silvariumElders }
        if !state.varatroFallsCleared { return .varatroFalls }
        if !state.ofelosAllianceComplete { return .ofelos }
        return .northernMarch
    }
}
