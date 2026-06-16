import Foundation
import AvasiaEngine

public final class AnthologySaveStore {
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
            self.directory = base.appendingPathComponent(AvasiaProduct.stories.saveDirectoryName, isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    private func url(for slot: Slot) -> URL {
        directory.appendingPathComponent("\(slot.rawValue).json")
    }

    public func save(_ state: AnthologyGameState, to slot: Slot = .autosave) throws {
        let data = try encoder.encode(state)
        try data.write(to: url(for: slot), options: .atomic)
    }

    public func load(_ slot: Slot = .autosave) -> AnthologyGameState? {
        guard let data = try? Data(contentsOf: url(for: slot)) else { return nil }
        return try? decoder.decode(AnthologyGameState.self, from: data)
    }
}
