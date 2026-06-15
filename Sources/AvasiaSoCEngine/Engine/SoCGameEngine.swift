import Foundation
import AvasiaEngine

/// Drives *Sword of Courage* — same turn loop as `GameEngine`, separate world.
public final class SoCGameEngine {
    public private(set) var state: SoCGameState
    public private(set) var lastDeath: DeathInfo?
    public private(set) var lastSocDeath: SoCDeathInfo?
    public private(set) var lastTransition: SoCTransition = .stay
    private let world: [SoCRoomID: SoCRoomScript]

    public init(state: SoCGameState = SoCGameState(), world: [SoCRoomID: SoCRoomScript] = SoCWorld.build()) {
        self.state = state
        self.world = world
    }

    private func room(_ id: SoCRoomID) -> SoCRoomScript {
        world[id]!
    }

    private var currentRoom: SoCRoomScript { room(state.currentRoom) }

    public func describeCurrent() -> [StyledLine] {
        currentRoom.describe(state)
    }

    @discardableResult
    public func submit(_ raw: String) -> [StyledLine] {
        playerDiedOnLastTurn = false
        let script = currentRoom
        let input = Parser.parse(raw, mode: script.parseMode)

        if let global = SoCGlobalCommands.handle(input, state: &state) {
            lastTransition = .stay
            return global
        }

        let result = script.handle(input, &state)
        lastTransition = result.transition
        playerDiedOnLastTurn = result.playerDied
        var output = result.lines

        if result.playerDied {
            lastSocDeath = SoCDeathCatalog.info(for: state, narrative: result.lines)
            return output
        }

        if case .move(let dest) = result.transition {
            state.currentRoom = dest
            output.append(contentsOf: enterRoom(dest))
        }
        return output
    }

    private func enterRoom(_ id: SoCRoomID) -> [StyledLine] {
        let script = room(id)
        var lines: [StyledLine] = []
        if let enter = script.onEnter(&state) {
            lines.append(contentsOf: enter)
        }
        lines.append(contentsOf: script.describe(state))
        if let back = script.autoReturnAfterEnter(state) {
            state.currentRoom = back
            lines.append(contentsOf: room(back).describe(state))
        }
        return lines
    }

    public var playerDiedOnLastTurn: Bool = false

    public func restart() {
        let delay = state.textDelay
        state = SoCGameState()
        state.textDelay = delay
        lastTransition = .stay
    }

    public func load(_ saved: SoCGameState) {
        state = saved
        lastTransition = .stay
    }

    public func setTextDelay(_ delay: TextDelay) {
        state.textDelay = delay
    }

    public func currentMedia() -> RoomMedia {
        Media.media(for: state.currentRoom.region)
    }
}

private extension Media {
    static func media(for region: Region) -> RoomMedia {
        RoomMedia(
            region: region,
            backgroundImage: Media.backgroundName(for: region),
            illustration: Media.illustrationName(for: region),
            ambientTrack: Media.ambientName(for: region)
        )
    }
}
