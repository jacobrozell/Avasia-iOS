import Foundation
import AvasiaEngine

/// Starts anthology stories — shared by hub room and app story picker.
public enum AnthologyStoryLauncher {
    public static func launch(_ story: AnthologyStoryID, state: inout AnthologyGameState) -> AnthologyTurnResult {
        let (allowed, reason) = AnthologyCatalog.canPlay(story, state: state)
        guard allowed else {
            return AnthologyTurnResult([.body(reason ?? "That story is locked.")])
        }

        if story == .storyZero {
            state.prepareStoryZeroReplay()
        } else {
            AnthologyCatalog.spendAndStart(story, state: &state)
        }

        let pack = introPack(for: story)
        var lines = pack.intro
        lines.append(.blank)
        return AnthologyTurnResult(lines, .move(pack.destination))
    }

    private static func introPack(for story: AnthologyStoryID) -> (intro: [StyledLine], destination: AnthologyRoomID) {
        switch story {
        case .storyZero:
            return (
                [.body("You take up the ridge patrol again — same cold fire, same orders.")],
                .patrolCamp
            )
        case .goodOne:
            return (
                [
                    .title("The Oceandale Warning"),
                    .body("Elder Venna reads your ridge report twice before speaking.")
                ],
                .goodOneSilvarium
            )
        case .goodTwo:
            return (
                [
                    .title("Nascastrum Courier"),
                    .body("Elder Venna seals a report with sap. \"Kaefden must hear Oceandale before the next tide.\"")
                ],
                .goodTwoSilvarium
            )
        case .badOne:
            return (
                [
                    .title("Walking with Vashirr"),
                    .body("The column forms before dawn. No one asks if you still belong.")
                ],
                .badOneColumn
            )
        case .badTwo:
            return (
                [
                    .title("Cataracta Periphery"),
                    .body("Vashirr wants eyes on the druid city — not a sword, not yet.")
                ],
                .badTwoPeriphery
            )
        case .elkFeast:
            return (
                [
                    .title("The Elk Feast"),
                    .body("Splitpath smoke smells of roast meat, not siege.")
                ],
                .elkSplitpath
            )
        case .caveRecord:
            return (
                [
                    .title("The Cave Record"),
                    .body("Suformin mentioned a scholar who hid notes in the old prison caves — before the mages moved in.")
                ],
                .caveRecordTrail
            )
        case .goodThree:
            return (
                [
                    .title("Council Under Glass"),
                    .body("Thekia summons you back to Nacastrum — Restoration hardliners want a cleaner story than Oceandale.")
                ],
                .goodThreeLanding
            )
        case .badThree:
            return (
                [
                    .title("Many Hands Oath"),
                    .body("Vashirr's column marches west from Cataracta. The Paladins gather for binding — not battle, yet.")
                ],
                .badThreeMarch
            )
        case .neutralThree:
            return (
                [
                    .title("Two Hands Market"),
                    .body("Splitpath traders heard about the prison caves. Both factions want your memory — or your silence.")
                ],
                .neutralThreeMarket
            )
        }
    }
}
