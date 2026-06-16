import Foundation
import AvasiaEngine

struct StoryHubRoom: AnthologyRoomScript {
    let id: AnthologyRoomID = .storyHub

    func onEnter(_ state: inout AnthologyGameState) -> [StyledLine]? {
        AnthologyRingPass.refreshDailyGrant(state: &state)
    }

    func describe(_ state: AnthologyGameState) -> [StyledLine] {
        AnthologyCatalog.hubLines(state: state)
    }

    func handle(_ input: ParsedInput, _ state: inout AnthologyGameState) -> AnthologyTurnResult {
        if input.contains("LIST") || input.contains("STORIES") {
            return AnthologyTurnResult(AnthologyCatalog.listLines(state: state))
        }

        if input.contains("PLAY") {
            if let story = storyFromPlayCommand(input) {
                return AnthologyStoryLauncher.launch(story, state: &state)
            }
        }
        if input.contains("ARENA") || input.contains("TRAIN") {
            return AnthologyArenaLauncher.enter(state: &state)
        }
        if input.contains("SHOP") || input.contains("GEAR") || input.contains("QUARTERMASTER") {
            return AnthologyTrainingShopLauncher.enter(state: &state)
        }

        return AnthologyTurnResult([.hint("Choose Story · Arena · Shop · LIST · PLAY <name>")])
    }

    private func storyFromPlayCommand(_ input: ParsedInput) -> AnthologyStoryID? {
        if input.contains("SCOUT") || input.contains("ZERO") || input.contains("PATROL") { return .storyZero }
        if input.contains("COURIER") || input.contains("GOOD2") || input.contains("GOOD 2") || input.contains("NACASTRUM") {
            return .goodTwo
        }
        if input.contains("COUNCIL") || input.contains("GOOD3") || input.contains("GOOD 3") || input.contains("GLASS") {
            return .goodThree
        }
        if input.contains("GOOD4") || input.contains("GOOD 4") || input.contains("MOBILIZE") || input.contains("RESTORATION") {
            return .goodFour
        }
        if input.contains("GOOD5") || input.contains("GOOD 5")
            || (input.contains("WITNESS") && input.contains("STONE")) {
            return .goodFive
        }
        if input.contains("GOOD6") || input.contains("GOOD 6") || input.contains("ACCORD") {
            return .goodSix
        }
        if input.contains("CAVE") || input.contains("RECORD") || input.contains("ARCHIVE") { return .caveRecord }
        if input.contains("GOOD") || input.contains("OCEANDALE") || input.contains("WARNING") { return .goodOne }
        if input.contains("CATARACTA") || input.contains("BAD2") || input.contains("BAD 2") || input.contains("PERIPHERY") {
            return .badTwo
        }
        if input.contains("OATH") || input.contains("BAD3") || input.contains("BAD 3") || input.contains("MANY HANDS") {
            return .badThree
        }
        if input.contains("BAD4") || input.contains("BAD 4") || input.contains("BREACH") {
            return .badFour
        }
        if input.contains("BAD5") || input.contains("BAD 5") || input.contains("COMMAND") {
            return .badFive
        }
        if input.contains("BAD6") || input.contains("BAD 6") || input.contains("THRONE") {
            return .badSix
        }
        if input.contains("BAD") || input.contains("VASHIRR") || input.contains("WALK") { return .badOne }
        if input.contains("ELK") || input.contains("FEAST") { return .elkFeast }
        if input.contains("MARKET") || input.contains("NEUTRAL3") || input.contains("NEUTRAL 3") || input.contains("TWO HANDS") {
            return .neutralThree
        }
        if input.contains("NEUTRAL4") || input.contains("NEUTRAL 4") || input.contains("CELLIOUS") {
            return .neutralFour
        }
        if input.contains("NEUTRAL5") || input.contains("NEUTRAL 5") || input.contains("UNMARKED") {
            return .neutralFive
        }
        if input.contains("NEUTRAL6") || input.contains("NEUTRAL 6") || input.contains("LEDGER") {
            return .neutralSix
        }
        return nil
    }
}
