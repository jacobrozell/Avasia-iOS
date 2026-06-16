import XCTest
@testable import AvasiaAnthologyEngine

/// Shared path through Scout Patrol for anthology tests (captured ridge → parley → fork).
enum AnthologyTestPaths {
    static func finishStoryZero(_ engine: AnthologyGameEngine, alignment: String) {
        advance(engine, "PLAY SCOUT")
        advance(engine, "CONTINUE") // camp → ridge
        advance(engine, "CONTINUE") // ridge → picket (captured)
        advance(engine, "CONTINUE") // picket → parley
        for _ in 0..<4 { advance(engine, "CONTINUE") } // parley → fork
        advance(engine, alignment)
        advance(engine, "CONTINUE") // fork → camp exit
        advance(engine, "CONTINUE") // camp exit → epilogue
        advance(engine, "CONTINUE") // epilogue → hub + FP
    }

    static func finishGoodOne(_ engine: AnthologyGameEngine) {
        _ = engine.launchStory(.goodOne)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "EVACUATE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
    }

    static func finishElkFeast(_ engine: AnthologyGameEngine) {
        _ = engine.launchStory(.elkFeast)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
    }

    static func finishGoodTwo(_ engine: AnthologyGameEngine) {
        var boosted = engine.state
        boosted.factionPoints = max(boosted.factionPoints, 1_000)
        engine.load(boosted)
        _ = engine.launchStory(.goodTwo)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "FULL")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
    }

    static func finishBadOne(_ engine: AnthologyGameEngine) {
        var boosted = engine.state
        boosted.factionPoints = max(boosted.factionPoints, 500)
        engine.load(boosted)
        _ = engine.launchStory(.badOne)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "REPORT")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
    }

    static func finishBadTwo(_ engine: AnthologyGameEngine) {
        var boosted = engine.state
        boosted.factionPoints = max(boosted.factionPoints, 1_000)
        engine.load(boosted)
        _ = engine.launchStory(.badTwo)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "FULL")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
    }

    static func finishCaveRecord(_ engine: AnthologyGameEngine) {
        var boosted = engine.state
        boosted.factionPoints = max(boosted.factionPoints, 500)
        engine.load(boosted)
        _ = engine.launchStory(.caveRecord)
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
        advance(engine, "COPY")
        advance(engine, "CONTINUE")
        advance(engine, "CONTINUE")
    }

    private static func advance(_ engine: AnthologyGameEngine, _ command: String) {
        _ = engine.submit(command)
    }
}
