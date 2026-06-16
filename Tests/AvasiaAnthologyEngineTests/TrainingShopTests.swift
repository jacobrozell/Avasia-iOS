import XCTest
@testable import AvasiaAnthologyEngine

final class TrainingShopTests: XCTestCase {
    func testPurchaseBootsIncreasesMaxHp() {
        var state = AnthologyGameState()
        state.storyZeroComplete = true
        state.anthologyGold = 100
        _ = AnthologyTrainingShop.purchase(.sturdyBoots, state: &state)
        XCTAssertEqual(state.arenaMaxHp, 25)
        XCTAssertEqual(state.anthologyGold, 60)
    }

    func testShopRequiresScoutPatrol() {
        let engine = AnthologyGameEngine()
        _ = engine.openTrainingShop()
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
    }

    func testShopPurchaseFromRoom() {
        let engine = AnthologyGameEngine()
        AnthologyTestPaths.finishStoryZero(engine, alignment: "REPORT")
        var boosted = engine.state
        boosted.anthologyGold = 200
        engine.load(boosted)
        _ = engine.openTrainingShop()
        _ = engine.submit("BUY WHETSTONE")
        _ = engine.submit("BUY MAIL")
        XCTAssertTrue(engine.state.arenaUpgrades.contains(.whetstone))
        XCTAssertTrue(engine.state.arenaUpgrades.contains(.trainingMail))
        _ = engine.submit("LEAVE")
        XCTAssertEqual(engine.state.currentRoom, .storyHub)
    }
}
