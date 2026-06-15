import Foundation
import SwiftUI
import AvasiaEngine

/// Bridges the pure `GameEngine` to SwiftUI: owns the transcript, applies text
/// pacing, autosaves, and exposes quick-action verbs. All game logic stays in
/// the engine; this layer is presentation + timing only.
@MainActor
final class GameViewModel: ObservableObject {
    enum Screen { case title, settings, game, credits, achievements }

    @Published var screen: Screen = .title {
        didSet { screenDidChange() }
    }
    @Published private(set) var transcript: [StyledLine] = []
    @Published private(set) var pendingDeath = false
    @Published private(set) var achievements: AchievementState
    /// Achievements unlocked in the last turn, surfaced as toasts.
    @Published private(set) var recentlyUnlocked: [Achievement] = []
    @Published var input: String = ""
    /// Where the Achievements screen returns to (title vs. in-game).
    var achievementsReturn: Screen = .title

    private let engine: GameEngine
    private let store = SaveStore()
    private let audio = AudioManager.shared

    init(engine: GameEngine = GameEngine()) {
        self.engine = engine
        self.achievements = store.loadAchievements()
    }

    var state: GameState { engine.state }

    /// Details of the most recent death, for the death overlay.
    var lastDeath: DeathInfo? { engine.lastDeath }

    /// Art/audio binding for the current room (drives backgrounds & illustration).
    var media: RoomMedia { engine.currentMedia() }

    var soundEnabled: Bool {
        get { !audio.isMuted }
        set {
            audio.isMuted = !newValue
            if newValue { refreshAmbient() }
        }
    }

    /// Called once when the app appears, to start title audio (a default value
    /// assignment doesn't fire `didSet`).
    func onLaunch() {
        if screen == .title { audio.playAmbient(SoundCue.titleTheme.rawValue) }
    }

    private func screenDidChange() {
        switch screen {
        case .title, .credits:
            audio.playAmbient(SoundCue.titleTheme.rawValue)
        case .game:
            refreshAmbient()
        case .settings, .achievements:
            break
        }
    }

    /// Switch the ambient loop to match the current region (idempotent).
    private func refreshAmbient() {
        audio.playAmbient(engine.currentMedia().ambientTrack)
    }
    var textDelay: TextDelay {
        get { engine.state.textDelay }
        set { engine.setTextDelay(newValue) }
    }

    // MARK: - Lifecycle

    func startNewGame() {
        engine.restart()
        transcript = []
        pendingDeath = false
        appendIntro()
        append(engine.describeCurrent())
        recordStartingRegion()
        screen = .game
    }

    func continueGame() {
        guard let saved = store.load() else { startNewGame(); return }
        engine.load(saved)
        transcript = []
        append(engine.describeCurrent())
        pendingDeath = false
        recordStartingRegion()
        screen = .game
    }

    /// `enteredRegion` events only fire on movement, so seed the current region.
    private func recordStartingRegion() {
        let unlocked = AchievementTracker.recordRegion(engine.currentMedia().region, into: &achievements)
        finishAchievements(unlocked)
    }

    var hasSave: Bool { store.load() != nil }

    // MARK: - Turn loop

    func submit() {
        let raw = input.trimmingCharacters(in: .whitespaces)
        input = ""
        guard !raw.isEmpty else { return }
        append([.hint("> \(raw)")])
        let before = engine.state.deathCount
        let lines = engine.submit(raw)
        append(lines)

        // Achievements fold over the turn's events (runs for every outcome,
        // including death and win).
        let unlocked = AchievementTracker.apply(engine.lastEvents, state: engine.state, into: &achievements)
        finishAchievements(unlocked)

        // Audio/art hooks keyed off the turn's result.
        if engine.state.deathCount > before {
            audio.play(.death)
            pendingDeath = true
            return
        }
        switch engine.lastTransition {
        case .win:  audio.play(.win)
        case .move: audio.play(.move); refreshAmbient()
        default:    break
        }
        if lines.contains(where: { $0.style == .item }) {
            audio.play(lines.contains { $0.text.lowercased().contains("spell") } ? .spellLearned : .itemGained)
        }
        try? store.save(engine.state)                      // autosave
        try? store.save(engine.state, to: .checkpoint)     // room-entry checkpoint
    }

    /// Persist any newly-unlocked achievements and surface them as toasts.
    private func finishAchievements(_ unlocked: [Achievement]) {
        guard !unlocked.isEmpty else { return }
        store.saveAchievements(achievements)
        recentlyUnlocked.append(contentsOf: unlocked)
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.recentlyUnlocked.removeAll { unlocked.contains($0) }
        }
    }

    func quickAction(_ verb: String) {
        input = verb
        submit()
    }

    func openAchievements(from screen: Screen) {
        achievementsReturn = screen
        self.screen = .achievements
    }

    // MARK: - Death handling (sanctioned improvement: offer checkpoint)

    func restartFromCheckpoint() {
        if let cp = store.load(.checkpoint) { engine.load(cp) }
        transcript = []
        append(engine.describeCurrent())
        pendingDeath = false
    }

    func restartFromBeginning() { startNewGame() }

    // MARK: - Helpers

    private func append(_ lines: [StyledLine]) {
        transcript.append(contentsOf: lines)
    }

    private func appendIntro() {
        append([
            .title("Avasia: King of Nacastrum"),
            .body("You hear waves and the sound of the ocean around you."),
            .body("But... Where are you?"),
            .body("You pull yourself to your feet."),
            .body("It appears that you are alongside a beach."),
            .blank,
            .body("The whisper of the ocean and the scream of the fierce wind penetrate your ears."),
            .body("You see the remains of a gate to your north."),
            .body("As you draw closer you see what appears to be an older gentleman, who seems out of place."),
            .body("This can't be the guard, you think to yourself."),
            .body("The guard is dressed in common-wear and has nothing to defend himself, other than a short broken spear."),
            .blank,
            .speech("Welcome to Oceandale."),
            .speech("Or what's left of it..."),
            .speech("Last week Oceandale was attacked by the faction of Agroman."),
            .blank,
            .speech("Once all of Avasia was united under the Kaefden family."),
            .speech("But the youngest son of the king thirsted for power."),
            .speech("He began a protest in Kaefden's capital, Aylova, which quickly became violent."),
            .speech("The youngest son urged his father for the crown and spited him for his lack of leadership."),
            .speech("Together, the older brother and the king, banished him from all of Kaefden."),
            .speech("The king couldn't allow for this behavior to fall upon his citizens, or certain chaos would follow."),
            .blank,
            .speech("The younger brother built the Agromanian faction from the ground up."),
            .speech("Of course, many Kaefden people followed of all races. Mages, Humans, and Druids alike."),
            .speech("Although the brothers, and the king are long gone, the rivalry and the hatred still exist."),
            .speech("The Agroman faction today believes in brotherhood and loyalty."),
            .speech("The Kaefden faction believes in order and integrity."),
            .speech("There's a city who remains neutral in the matter; the city of Ofelos."),
            .speech("They believe that a united Avasia would benefit the people more than petty fighting."),
            .speech("After Oceandale nearly fell to the Barbarians, I'm starting to see their point."),
            .blank,
            .speech("Go into the city. There isn't much left to see."),
            .blank,
            .body("You venture forth until you begin to see the debris of crumbling and post-burnt houses."),
            .blank
        ])
    }
}
