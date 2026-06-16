import XCTest
@testable import AvasiaSoCEngine

extension SoCGameEngine {
    /// Fight until combat ends — restores HP first and uses potions so RNG cannot
    /// flake long E2E walks (combat rolls `Int.random(in: 0...10)` each attack).
    func fightToVictory(file: StaticString = #filePath, line: UInt = #line) {
        var fresh = state
        fresh.restoreHealthToMax()
        load(fresh)
        var turns = 0
        let maxTurns = 80

        while state.inCombat, turns < maxTurns {
            if state.playerHp <= state.playerMaxHp / 2,
               state.inventory[.potion, default: 0] > 0 {
                _ = submit("eat potion")
            } else {
                _ = submit("attack")
            }
            turns += 1
            XCTAssertFalse(
                playerDiedOnLastTurn,
                "Player died during combat",
                file: file,
                line: line
            )
        }

        XCTAssertFalse(
            state.inCombat,
            "Combat did not end within \(maxTurns) turns (hp=\(state.playerHp))",
            file: file,
            line: line
        )
        XCTAssertGreaterThan(
            state.playerHp,
            0,
            "Player should survive combat",
            file: file,
            line: line
        )
    }
}
