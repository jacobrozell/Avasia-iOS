import Foundation
import AvasiaEngine

enum AnthologyArenaLauncher {
    static func enter(state: inout AnthologyGameState) -> AnthologyTurnResult {
        guard state.storyZeroComplete else {
            return AnthologyTurnResult([.body("Finish Scout Patrol before training in the arena.")])
        }
        state.beginArenaRun()
        var lines: [StyledLine] = [
            .title("Training Arena"),
            .body("Three waves. No story consequences — only sweat and gold."),
            .blank
        ]
        return AnthologyTurnResult(lines, .move(.arenaPit))
    }
}
