import Foundation
import AvasiaEngine

/// Act labels shown on room transitions and the continue screen.
public enum SoCChapter {
    public static func title(for room: SoCRoomID) -> String {
        switch room {
        case .cataractaHousing, .cataractaNorth, .cataractaShopping, .cataractaHunterPath,
             .cataractaBarracks, .cataractaAthalos, .cataractaBlacksmith, .cataractaPier,
             .cataractaFishing, .cataractaGarden:
            return "Act I — Cataracta"
        case .cataractaCourtyard:
            return "Act II — The Massacre"
        case .portalRoom, .library, .westHallway, .throneRoom:
            return "Act III — Nacastrum"
        case .aylovaWarCamp, .silvariumElders, .varatroFalls, .ofelos,
             .northernMarch, .oceandaleFront, .mageOutpost, .vashirrStand:
            return "Act IV — The War"
        case .ageEpilogue:
            return "Epilogue — Aylova"
        case .cataractaRuins:
            return "Coda — Cataracta Ruins"
        }
    }

    public static func banner(for room: SoCRoomID) -> StyledLine? {
        .title(title(for: room))
    }
}
