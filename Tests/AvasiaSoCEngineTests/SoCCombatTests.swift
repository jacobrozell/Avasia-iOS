import XCTest
import AvasiaEngine
@testable import AvasiaSoCEngine

final class SoCCombatTests: XCTestCase {
    func testEffectivePlayerLuckIncludesLevel() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.playerLevel = 3
        XCTAssertEqual(SoCCombat.effectivePlayerLuck(state), 7)
    }

    func testRollsHitDeterministic() {
        XCTAssertTrue(SoCCombat.hits(attackerLuck: 5, roll: 5))
        XCTAssertFalse(SoCCombat.hits(attackerLuck: 5, roll: 6))
    }

    func testGuardianBlocksFirstEnemyHit() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Test", atk: 9, speed: 10, hp: 20, luck: 10),
            deathText: "dead",
            state: &state
        )
        state.playerAttacksFirst = false

        let result = SoCCombat.handle(Parser.parse("attack", mode: .normalized), state: &state)
        XCTAssertFalse(result.died)
        XCTAssertTrue(result.lines.contains { $0.text.contains("bear shield") })
        XCTAssertEqual(state.playerHp, state.playerMaxHp)
    }

    func testHunterFirstStrikeBonus() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.playerLuck = 12
        var enemy = SoCCombatant(name: "Dummy", atk: 1, speed: 1, hp: 30, luck: 0)
        SoCCombat.begin(enemy: enemy, deathText: "", state: &state)

        _ = SoCCombat.handle(Parser.parse("attack", mode: .normalized), state: &state)
        enemy = state.enemy!
        XCTAssertEqual(enemy.hp, 30 - 13, "Hunter first strike should deal atk+3")
    }

    func testHunterWoundedBonusAfterFirstStrike() {
        var state = SoCGameState()
        state.applyClass(.hunter)
        state.playerLuck = 12
        var enemy = SoCCombatant(name: "Dummy", atk: 1, speed: 1, hp: 30, luck: 0)
        SoCCombat.begin(enemy: enemy, deathText: "", state: &state)
        state.combatHunterStrikeUsed = true
        enemy.hp = 14
        state.enemy = enemy

        _ = SoCCombat.handle(Parser.parse("attack", mode: .normalized), state: &state)
        enemy = state.enemy!
        XCTAssertEqual(enemy.hp, 2, "Wounded hunter bonus should add +2 damage")
    }

    func testEatPotionGrantsEnemyTurn() {
        var state = SoCGameState()
        state.applyClass(.guardian)
        state.playerHp = 5
        state.inventory[.potion] = 2
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Raider", atk: 8, speed: 1, hp: 40, luck: 10),
            deathText: "dead",
            state: &state
        )

        let result = SoCCombat.handle(Parser.parse("eat potion", mode: .normalized), state: &state)
        XCTAssertTrue(result.lines.contains { $0.text.contains("does not wait") })
        XCTAssertGreaterThan(state.playerHp, 5)
        XCTAssertLessThan(state.playerHp, state.playerMaxHp, "Enemy should land a hit after potion")
    }

    func testObjectivesAvailableInCombat() {
        var state = SoCGameState()
        state.applyClass(.scout)
        SoCCombat.begin(
            enemy: SoCCombatant(name: "Grunt", atk: 5, speed: 5, hp: 10, luck: 0),
            deathText: "",
            state: &state
        )

        let result = SoCCombat.handle(Parser.parse("objectives", mode: .normalized), state: &state)
        XCTAssertFalse(result.lines.isEmpty)
        XCTAssertTrue(state.inCombat)
    }
}
