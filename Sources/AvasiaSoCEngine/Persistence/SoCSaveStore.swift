import Foundation
import AvasiaEngine

/// JSON persistence for `SoCGameState` — separate from KoN saves.
public final class SoCSaveStore {
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
            self.directory = base.appendingPathComponent(AvasiaProduct.soc.saveDirectoryName, isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    private func url(for slot: Slot) -> URL {
        directory.appendingPathComponent("\(slot.rawValue).json")
    }

    public func save(_ state: SoCGameState, to slot: Slot = .autosave) throws {
        let data = try encoder.encode(state)
        try data.write(to: url(for: slot), options: .atomic)
    }

    public func load(_ slot: Slot = .autosave) -> SoCGameState? {
        guard let data = try? Data(contentsOf: url(for: slot)) else { return nil }
        return try? decoder.decode(SoCGameState.self, from: data)
    }
}
