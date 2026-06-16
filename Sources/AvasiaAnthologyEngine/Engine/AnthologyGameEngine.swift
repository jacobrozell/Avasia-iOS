import Foundation
import AvasiaEngine

/// Drives anthology short stories — same turn loop as KoN / SoC, separate world.
public final class AnthologyGameEngine {
    public private(set) var state: AnthologyGameState
    public private(set) var lastTransition: AnthologyTransition = .stay
    private let world: [AnthologyRoomID: AnthologyRoomScript]

    public init(
        state: AnthologyGameState = AnthologyGameState(),
        world: [AnthologyRoomID: AnthologyRoomScript] = AnthologyWorld.build()
    ) {
        self.state = state
        self.world = world
    }

    private func room(_ id: AnthologyRoomID) -> AnthologyRoomScript {
        world[id]!
    }

    private var currentRoom: AnthologyRoomScript { room(state.currentRoom) }

    public func describeCurrent() -> [StyledLine] {
        currentRoom.describe(state)
    }

    @discardableResult
    public func launchStory(_ story: AnthologyStoryID) -> [StyledLine] {
        let result = AnthologyStoryLauncher.launch(story, state: &state)
        lastTransition = result.transition
        var output = result.lines
        if case .move(let dest) = result.transition {
            state.currentRoom = dest
            output.append(contentsOf: enterRoom(dest))
        }
        return output
    }

    @discardableResult
    public func launchArena() -> [StyledLine] {
        let result = AnthologyArenaLauncher.enter(state: &state)
        lastTransition = result.transition
        var output = result.lines
        if case .move(let dest) = result.transition {
            state.currentRoom = dest
            output.append(contentsOf: enterRoom(dest))
        }
        return output
    }

    @discardableResult
    public func openTrainingShop() -> [StyledLine] {
        let result = AnthologyTrainingShopLauncher.enter(state: &state)
        lastTransition = result.transition
        var output = result.lines
        if case .move(let dest) = result.transition {
            state.currentRoom = dest
            output.append(contentsOf: enterRoom(dest))
        }
        return output
    }

    /// Restores arena HP mid-run (used by tests to avoid flaky RNG deaths).
    public func setArenaHp(_ hp: Int) {
        state.arenaHp = hp
    }

    @discardableResult
    public func submit(_ raw: String) -> [StyledLine] {
        let script = currentRoom
        let input = Parser.parse(raw, mode: script.parseMode)
        let result = script.handle(input, &state)
        lastTransition = result.transition
        var output = result.lines

        if case .move(let dest) = result.transition {
            state.currentRoom = dest
            output.append(contentsOf: enterRoom(dest))
        }
        return output
    }

    private func enterRoom(_ id: AnthologyRoomID) -> [StyledLine] {
        let script = room(id)
        var lines: [StyledLine] = []
        if let enter = script.onEnter(&state) {
            lines.append(contentsOf: enter)
        }
        lines.append(contentsOf: script.describe(state))
        return lines
    }

    public func restart() {
        let delay = state.textDelay
        state = AnthologyGameState()
        state.textDelay = delay
        lastTransition = .stay
    }

    public func load(_ saved: AnthologyGameState) {
        state = saved
        lastTransition = .stay
    }

    public func setTextDelay(_ delay: TextDelay) {
        state.textDelay = delay
    }

    public func currentMedia() -> RoomMedia {
        RoomMedia(
            region: state.currentRoom.region,
            backgroundImage: Media.backgroundName(for: state.currentRoom.region),
            illustration: Media.illustrationName(for: state.currentRoom.region),
            ambientTrack: Media.ambientName(for: state.currentRoom.region)
        )
    }
}
