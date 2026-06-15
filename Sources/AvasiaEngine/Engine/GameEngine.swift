import Foundation

/// Drives the game: holds `GameState`, routes input to the current room, and
/// applies transitions. This is the replacement for the original's recursive
/// function-call control flow — here movement is an explicit state change, so
/// there is no unbounded call stack (ENGINE_SPEC §A.1, §B.1).
/// Details of the most recent death, for the death overlay.
public struct DeathInfo: Sendable, Equatable {
    public let cause: DeathCause
    public let narrative: [StyledLine]   // the room's verbatim death lines
    public let number: Int               // deathCount after this death
}

public final class GameEngine {
    public private(set) var state: GameState
    /// The transition produced by the most recent `submit` (for UI hooks like
    /// audio cues on move/death/win).
    public private(set) var lastTransition: Transition = .stay
    /// Semantic events from the most recent `submit` (for the achievement tracker).
    public private(set) var lastEvents: [GameEvent] = []
    /// Details of the most recent death (for the death overlay).
    public private(set) var lastDeath: DeathInfo?
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
        let script = currentRoom
        let prevRegion = state.currentRoom.region
        let flagsBefore = state.flags
        let input = Parser.parse(raw, mode: script.parseMode)
        let result = script.handle(input, &state)
        lastTransition = result.transition
        var output = result.lines
        var events = result.events

        switch result.transition {
        case .stay:
            break

        case .move(let dest):
            state.currentRoom = dest
            if dest.region != prevRegion { events.append(.enteredRegion(dest.region)) }
            output.append(.blank)
            output.append(contentsOf: room(dest).describe(state))

        case .death(let cause):
            state.deathCount += 1
            lastDeath = DeathInfo(cause: cause, narrative: result.lines, number: state.deathCount)
            events.append(.died(cause))
            output.append(.blank)
            output.append(.death("You have died."))
            // The caller (UI) decides restart vs. checkpoint; state is left as-is
            // so a checkpoint can be restored. `restart()` begins a fresh game.

        case .win:
            if !state.gameComplete {
                state.gameComplete = true
                events.append(.won)
                output.append(.blank)
                output.append(.title("Congratulations on completing the game!"))
            }
        }

        // Derive item/spell-gain events from the flag diff.
        for flag in state.flags.subtracting(flagsBefore) {
            events.append(.gained(flag))
        }
        lastEvents = events
        return output
    }

    /// Update the text-pacing preference (the `state` setter is private).
    public func setTextDelay(_ delay: TextDelay) {
        state.textDelay = delay
    }

    /// Art/audio binding for the current room.
    public func currentMedia() -> RoomMedia {
        Media.media(for: state.currentRoom)
    }

    /// Begin a brand-new game (equivalent to the original `intro()` reset):
    /// wipes state and reshuffles the runes.
    public func restart() {
        let delay = state.textDelay
        state = GameState()
        state.currentRoom = .oceandale
        state.textDelay = delay
    }

    /// Replace state wholesale (e.g. restoring a save or checkpoint).
    public func load(_ saved: GameState) {
        state = saved
    }
}
