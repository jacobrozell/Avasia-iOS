import XCTest
@testable import AvasiaAnthologyEngine

/// Enables deferred anthology tiers for content tests; resets after each case.
class FullAnthologyTestCase: XCTestCase {
    override func setUp() {
        super.setUp()
        AnthologyRelease.shipsFullAnthology = true
    }

    override func tearDown() {
        AnthologyRelease.shipsFullAnthology = false
        super.tearDown()
    }
}
