import Foundation

/// Saga foreshadowing for the Oceandale shore (`docs/FORESHADOWING.md`, `docs/NARRATIVE_LOGIC.md`).
public enum KoNBeachFlavor {
    /// New-game awakening — shore arrival, amnesia, grief (#1, #4).
    public static func awakeningLines() -> [StyledLine] {
        [
            .blank,
            .title("The Shore"),
            .body("You hear waves before you remember your name."),
            .body("But... where are you? You pull yourself to your feet."),
            .body("Salt stings a cut you do not recall earning. Your robes are Kaefden blue; your mind is an empty room."),
            .body("Oceandale smolders behind you — a warning strike, though you only know the ash."),
            .body("Somewhere under the grief is a memory of light: a pendant, a mother's face, a king's staff."),
            .body("Other mages limped toward Aylova. You could not remember your mother's face well enough to know which way hope lay."),
            .body("The sea does not care. It keeps its own anchor."),
            .blank
        ]
    }

    public static func lookLines() -> [StyledLine] {
        [
            .body("Tide pulls blue glass from the sand — not Anula, but close enough to sting."),
            .body("For a heartbeat you feel a weight at your throat, as if a silver pendant should hang there."),
            .body("The scatter threw sky-mages to shore-anchors. You washed up here — not because you chose Oceandale, but because the coast caught you."),
            .body("The feeling passes. The war does not.")
        ]
    }

    public static func yogaLines() -> [StyledLine] {
        [
            .body("You take a deep breath and do some yoga moves."),
            .blank,
            .body("A couple of back bends."),
            .body("A few Eagles."),
            .body("Even a Crow Pose."),
            .blank,
            .body("Both your body and mind feel revitalized.")
        ]
    }
}
