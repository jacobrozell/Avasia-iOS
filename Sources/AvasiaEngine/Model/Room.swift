import Foundation

/// What a turn produces: lines to print, where to go next, and any semantic
/// events for the achievement tracker.
public struct TurnResult: Sendable {
    public var lines: [StyledLine]
    public var transition: Transition
    public var events: [GameEvent]

    public init(_ lines: [StyledLine] = [], _ transition: Transition = .stay, events: [GameEvent] = []) {
        self.lines = lines
        self.transition = transition
        self.events = events
    }
}

/// The outcome of a command, applied by `GameEngine`.
public enum Transition: Sendable, Equatable {
    case stay                       // remain in the current room
    case move(RoomID)               // go to another room
    case death(DeathCause)          // lethal — increments deathCount, offers restart
    case win                        // reached the canonical ending
}

/// A room knows how to describe itself and handle player input. Implementations
/// are pure: they read and mutate `GameState` but perform no I/O. This makes the
/// whole world unit-testable by scripting input sequences.
public protocol RoomScript: Sendable {
    var id: RoomID { get }

    /// Which parser mode this room uses (most are `.normalized`; the cave hub,
    /// trading post, bridge and yes/no prompts use `.raw` — ENGINE_SPEC §B.4).
    var parseMode: Parser.Mode { get }

    /// The room's description, possibly branching on state (e.g. escort mode).
    func describe(_ state: GameState) -> [StyledLine]

    /// Handle one parsed command.
    func handle(_ input: ParsedInput, _ state: inout GameState) -> TurnResult
}

public extension RoomScript {
    var parseMode: Parser.Mode { .normalized }
}

// Shared synonym lists matching the original's per-room dispatch lists.
public enum Verb {
    public static let north = ["NORTH"]
    public static let east  = ["EAST"]
    public static let west  = ["WEST"]
    public static let south = ["SOUTH"]
    public static let back  = ["LEAVE", "BACK", "EXIT", "RETURN", "SOUTH"]
    public static let up    = ["UP", "STAIRS", "UPSTAIRS"]
    public static let down  = ["DOWN", "DOWNSTAIRS"]
    public static let left  = ["LEFT"]
    public static let right = ["RIGHT"]
    public static let look  = ["LOOK", "EXAMINE", "INSPECT"]
    public static let talk  = ["TALK", "SPEAK"]
    public static let take  = ["TAKE", "GRAB", "STEAL", "GET", "PICK"]
}
