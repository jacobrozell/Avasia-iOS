import Foundation

/// App-wide Chronicler persistence (`Application Support/Avasia/saga_profile.json`).
public final class SagaProfileStore: @unchecked Sendable {
    public static let defaultDirectoryName = "Avasia"
    public static let fileName = "saga_profile.json"

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(directory: URL? = nil) {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let folder = directory ?? base.appendingPathComponent(Self.defaultDirectoryName, isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        self.fileURL = folder.appendingPathComponent(Self.fileName)
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    public func load() -> SagaProfile {
        guard let data = try? Data(contentsOf: fileURL),
              let profile = try? decoder.decode(SagaProfile.self, from: data) else {
            return SagaProfile()
        }
        return profile
    }

    public func save(_ profile: SagaProfile) {
        guard let data = try? encoder.encode(profile) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    public func reset() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
