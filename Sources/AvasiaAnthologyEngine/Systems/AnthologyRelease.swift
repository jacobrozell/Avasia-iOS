import Foundation

/// Controls which anthology stories are playable in the current app release.
public enum AnthologyRelease {
    /// When `false` (1.0.0), only stories marked `shipsIn100` are available.
    /// Set `true` in tests that exercise deferred tiers, or when a full anthology update ships.
    public static var shipsFullAnthology = false

    public static func isStoryAvailable(_ meta: AnthologyStoryMeta) -> Bool {
        shipsFullAnthology || meta.shipsIn100
    }
}
