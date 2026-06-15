import Foundation

/// JSON persistence for `GameState`: a single autosave plus a checkpoint taken
/// on each room entry (ENGINE_SPEC §B.6). This is the sanctioned improvement
/// over the original's permadeath-to-title behavior.
public final class SaveStore {
    public enum Slot: String { case autosave, checkpoint }

    private let directory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? FileManager.default.temporaryDirectory
            self.directory = base.appendingPathComponent("AvasiaKoN", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    private func url(for slot: Slot) -> URL {
        directory.appendingPathComponent("\(slot.rawValue).json")
    }

    public func save(_ state: GameState, to slot: Slot = .autosave) throws {
        let data = try encoder.encode(state)
        try data.write(to: url(for: slot), options: .atomic)
    }

    public func load(_ slot: Slot = .autosave) -> GameState? {
        guard let data = try? Data(contentsOf: url(for: slot)) else { return nil }
        return try? decoder.decode(GameState.self, from: data)
    }

    public func clear() {
        try? FileManager.default.removeItem(at: url(for: .autosave))
        try? FileManager.default.removeItem(at: url(for: .checkpoint))
    }

    // MARK: - Achievements (cross-run, persisted separately from GameState)

    private var achievementsURL: URL {
        directory.appendingPathComponent("achievements.json")
    }

    public func saveAchievements(_ progress: AchievementState) {
        if let data = try? encoder.encode(progress) {
            try? data.write(to: achievementsURL, options: .atomic)
        }
    }

    public func loadAchievements() -> AchievementState {
        guard let data = try? Data(contentsOf: achievementsURL),
              let progress = try? decoder.decode(AchievementState.self, from: data) else {
            return AchievementState()
        }
        return progress
    }
}
