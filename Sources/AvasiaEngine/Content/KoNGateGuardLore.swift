import Foundation

/// Canonical Oceandale gate-guard schism speech (`docs/STORY.md` §2.1).
/// Used by new-game intro (`GameViewModel`) and graveyard revisit (`GraveyardRoom`).
public enum KoNGateGuardLore {
    public static func approachLines() -> [StyledLine] {
        [
            .body("You see the remains of a gate to your north."),
            .body("As you draw closer you see what appears to be an older gentleman, who seems out of place."),
            .body("This can't be the guard, you think to yourself."),
            .body("The guard is dressed in common-wear and has nothing to defend himself, other than a short broken spear."),
            .blank,
            .speech("Another one from the sky, eh? Blue robes, empty eyes."),
            .speech("Welcome to Oceandale."),
            .speech("Or what's left of it..."),
            .speech("Last week Oceandale was attacked by the faction of Agroman."),
            .speech("The sky falling was three nights ago. You lost the days between — that's common."),
            .speech("Sit if you must. I'll tell you what happened while you still have ears to hear."),
            .blank
        ]
    }

    public static func schismSpeech() -> [StyledLine] {
        [
            .speech("Once all of Avasia was united under the Kaefden family."),
            .speech("But the youngest son of the king thirsted for power."),
            .speech("He began a protest in Kaefden's capital, Aylova, which quickly became violent."),
            .speech("The youngest son urged his father for the crown and spited him for his lack of leadership."),
            .speech("Together, the older brother and the king, banished him from all of Kaefden."),
            .speech("The king couldn't allow for this behavior to fall upon his citizens, or certain chaos would follow."),
            .blank,
            .speech("His middle name was Agroman. The exiles took it for their faction — a wound that outlived the brothers."),
            .speech("The younger brother built the Agromanian faction from the ground up."),
            .speech("Of course, many Kaefden people followed of all races. Mages, Humans, and Druids alike."),
            .speech("Although the brothers, and the king are long gone, the rivalry and the hatred still exist."),
            .speech("Power must cling to something — crown, tower, blood oath, or shrine."),
            .speech("Kaefden binds it to law. Agroman binds it to brotherhood. The fight is over which anchor holds."),
            .speech("The Kaefden faction believes in order and integrity."),
            .speech("The Agroman faction today believes in brotherhood and loyalty."),
            .speech("There's a city who remains neutral in the matter; the city of Ofelos."),
            .speech("They believe that a united Avasia would benefit the people more than petty fighting."),
            .speech("After Oceandale nearly fell to the Barbarians, I'm starting to see their point."),
            .blank,
            .speech("Go into the city. There isn't much left to see.")
        ]
    }

    public static func fullEncounter() -> [StyledLine] {
        approachLines() + schismSpeech()
    }

    /// Player tries to leave north without hearing the guard (`GraveyardRoom`).
    public static func northGateBlockedLines() -> [StyledLine] {
        [
            .body("You approach the broken north gate. An older gentleman in common-wear — a broken spear his only weapon — watches the road."),
            .body("He doesn't raise the spear. He doesn't step aside either."),
            .speech("If you're headed north, mage, you'll want words with me first."),
            .hint("TALK to the gate guard.")
        ]
    }
}
