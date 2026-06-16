import Foundation

/// The art/audio binding for a room: which background, header illustration, and
/// ambient loop to present. Asset names follow a strict convention so the UI can
/// resolve them and so designers know exactly what to drop in (see docs/ASSETS.md).
public struct RoomMedia: Sendable, Equatable {
    public let region: Region
    /// Full-bleed background image asset name (e.g. "bg_cave").
    public let backgroundImage: String
    /// Header illustration asset name (e.g. "art_cave").
    public let illustration: String
    /// Ambient loop file base name without extension (e.g. "amb_cave"), or nil.
    public let ambientTrack: String?

    public init(region: Region, backgroundImage: String, illustration: String, ambientTrack: String?) {
        self.region = region
        self.backgroundImage = backgroundImage
        self.illustration = illustration
        self.ambientTrack = ambientTrack
    }
}

/// Resolves media for rooms and names the sound effects. Pure data — no I/O —
/// so the app layer (AudioManager, background views) stays a thin consumer.
public enum Media {
    /// Asset-name conventions (kept here so engine + app + docs agree).
    public static func backgroundName(for region: Region) -> String { "bg_\(region.rawValue)" }
    public static func illustrationName(for region: Region) -> String { "art_\(region.rawValue)" }
    public static func ambientName(for region: Region) -> String { "amb_\(region.rawValue)" }

    public static func media(for room: RoomID) -> RoomMedia {
        let region = room.region
        return RoomMedia(
            region: region,
            backgroundImage: backgroundName(for: region),
            illustration: illustrationName(for: region),
            ambientTrack: ambientName(for: region)
        )
    }
}

/// Named sound-effect cues. The app plays these on the corresponding game events
/// (see GameViewModel). Files are optional — playback no-ops if absent.
public enum SoundCue: String, Sendable, CaseIterable {
    case itemGained = "sfx_item"     // green "you obtained..." line
    case spellLearned = "sfx_spell"  // a spell joins your book
    case death = "sfx_death"         // the red "You have died." banner
    case win = "sfx_win"             // the canonical ending
    case move = "sfx_move"           // room transition footstep
    case titleTheme = "music_title"  // title-screen music loop
    case hit = "sfx_hit"
    case miss = "sfx_miss"
    case block = "sfx_block"
    case heal = "sfx_heal"
    case combatStart = "sfx_combat_start"
    case victory = "sfx_victory"
}
