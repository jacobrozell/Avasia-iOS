import XCTest
@testable import AvasiaEngine

final class MediaTests: XCTestCase {
    func testEveryRoomResolvesMedia() {
        for id in RoomID.allCases {
            let m = Media.media(for: id)
            XCTAssertEqual(m.region, id.region)
            XCTAssertEqual(m.backgroundImage, "bg_\(id.region.rawValue)")
            XCTAssertEqual(m.illustration, "art_\(id.region.rawValue)")
            XCTAssertEqual(m.ambientTrack, "amb_\(id.region.rawValue)")
        }
    }

    func testEngineExposesCurrentMediaAndTransition() {
        let engine = GameEngine()
        engine.load(room: .mainCave)
        XCTAssertEqual(engine.currentMedia().region, .cave)

        engine.load(room: .magehouse) { $0.gain(.levitate) }
        _ = engine.submit("back")
        // After leaving the magehouse the last transition should be a move.
        if case .move = engine.lastTransition {} else {
            XCTFail("expected a move transition, got \(engine.lastTransition)")
        }
    }

    func testSoundCueRawNames() {
        XCTAssertEqual(SoundCue.itemGained.rawValue, "sfx_item")
        XCTAssertEqual(SoundCue.death.rawValue, "sfx_death")
        XCTAssertEqual(SoundCue.titleTheme.rawValue, "music_title")
    }
}
