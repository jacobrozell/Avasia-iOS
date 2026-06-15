import Foundation

/// Player-facing text pacing for the "delay between sentences" feature.
public enum TextDelay: String, Codable, Sendable {
    case on             // ~8s base delay (original recommended default)
    case off            // instant
    case tapToAdvance   // mobile-friendly addition: reveal next line on tap
}

/// The complete, serializable game state. This replaces the original's loose
/// module-level globals (see ENGINE_SPEC §A.4 for the flag mapping). Being
/// `Codable` gives us save/restore and checkpointing for free.
public struct GameState: Codable, Sendable {
    /// Spells, items, and one-shot world markers.
    public var flags: Set<Flag> = []

    /// Remaining attempts on the cave fireball symbol puzzle (resets only on a
    /// new game, faithfully — see ENGINE_SPEC §A.4).
    public var guesses: Int = 3

    /// Road-to-Nacastrum gauntlet progress, replacing the original's broken
    /// `roadfir`/`roadgeo`/`roadlev` flags with one integer:
    /// 0 = ambush not started, 1 = ambush survived (now lethal without Inflame),
    /// 2 = ambush won, 3 = stone spires cleared, 4 = dream bridge crossed.
    public var roadProgress: Int = 0

    /// Count of "orange fish" thrown back; at >= 4 the roll-12 becomes the
    /// sea-serpent death (ENGINE_SPEC §A.5 fishing).
    public var orangeFishThrown: Int = 0

    public var escortActive: Bool = false          // was `escort`
    public var magehouseLocked: Bool = false       // was `lock`
    public var teleporterDiscovered: Bool = false  // was `lady`
    public var cataractaGateDone: Bool = false     // was `cgates`

    /// Surfaced in the UI (improvement over the original, which never showed it).
    public var deathCount: Int = 0

    /// Per-game shuffled rune order; the fireball puzzle answer.
    public var symbols: [RuneSymbol]

    public var currentRoom: RoomID = .oceandale
    public var textDelay: TextDelay = .on

    /// Start a fresh game (equivalent to the original `intro()` re-init),
    /// reshuffling the runes. Pass a seeded generator in tests for determinism.
    public init<G: RandomNumberGenerator>(using gen: inout G) {
        self.symbols = RuneSymbol.shuffled(using: &gen)
    }

    public init() {
        var gen = SystemRandomNumberGenerator()
        self.symbols = RuneSymbol.shuffled(using: &gen)
    }

    // MARK: - Convenience

    public func has(_ flag: Flag) -> Bool { flags.contains(flag) }
    public mutating func gain(_ flag: Flag) { flags.insert(flag) }

    /// The correct answer string for the current run's fireball puzzle.
    public var symbolAnswer: String { RuneSymbol.decode(symbols) }

    public var spells: [Flag] { Flag.allCases.filter { $0.isSpell && has($0) } }
    public var items: [Flag] { Flag.allCases.filter { $0.isItem && has($0) } }
}
