import Foundation

/// Drives the game: holds `GameState`, routes input to the current room, and
/// applies transitions. This is the replacement for the original's recursive
/// function-call control flow — here movement is an explicit state change, so
/// there is no unbounded call stack (ENGINE_SPEC §A.1, §B.1).
public final class GameEngine {
    public private(set) var state: GameState
    private let world: [RoomID: RoomScript]

    public init(state: GameState = GameState(), world: [RoomID: RoomScript] = World.build()) {
        self.state = state
        self.world = world
    }

    private func room(_ id: RoomID) -> RoomScript {
        world[id] ?? world[.stub]!
    }

    private var currentRoom: RoomScript { room(state.currentRoom) }

    /// The current room's description — call when entering a room or on demand.
    public func describeCurrent() -> [StyledLine] {
        currentRoom.describe(state)
    }

    /// Process one line of player input and return what to display. Side effects
    /// (state mutation, room change, death bookkeeping) are applied here.
    @discardableResult
    public func submit(_ raw: String) -> [StyledLine] {
        let room = currentRoom
        let input = Parser.parse(raw, mode: room.parseMode)
        let result = room.handle(input, &state)
        var output = result.lines

        switch result.transition {
        case .stay:
            break

        case .move(let dest):
            state.currentRoom = dest
            output.append(.blank)
            output.append(contentsOf: room(dest).describe(state))

        case .death(let reason):
            state.deathCount += 1
            output.append(.blank)
            output.append(.death("You have died."))
            if !reason.isEmpty { output.append(.death(reason)) }
            output.append(.hint("Restart from the beginning, or load your last checkpoint."))
            // The caller (UI) decides restart vs. checkpoint; state is left as-is
            // so a checkpoint can be restored. `restart()` begins a fresh game.

        case .win:
            output.append(.blank)
            output.append(.title("Congratulations on completing the game!"))
        }

        return output
    }

    /// Update the text-pacing preference (the `state` setter is private).
    public func setTextDelay(_ delay: TextDelay) {
        state.textDelay = delay
    }

    /// Begin a brand-new game (equivalent to the original `intro()` reset):
    /// wipes state and reshuffles the runes.
    public func restart() {
        state = GameState()
        state.currentRoom = .oceandale
    }

    /// Replace state wholesale (e.g. restoring a save or checkpoint).
    public func load(_ saved: GameState) {
        state = saved
    }
}
