import Foundation
import SwiftUI
import AvasiaEngine
import AvasiaSoCEngine

/// Bridges engine(s) to SwiftUI. KoN and Sword of Courage are separate products
/// with separate saves, selected from `SagaTitleView`.
@MainActor
final class GameViewModel: ObservableObject {
    enum Screen { case saga, title, settings, game, credits, achievements, trophies }

    @Published var screen: Screen = .saga {
        didSet { screenDidChange() }
    }
    @Published var product: AvasiaProduct = .kon
    @Published private(set) var transcript: [StyledLine] = []
    @Published private(set) var pendingDeath = false
    @Published private(set) var achievements: AchievementState
    @Published private(set) var recentlyUnlocked: [Achievement] = []
    @Published private(set) var recentlyUnlockedTrophies: [SoCTrophy] = []
    @Published var input: String = ""
    var achievementsReturn: Screen = .title
    var trophiesReturn: Screen = .title
    var menuReturn: Screen = .saga

    private let konEngine: GameEngine
    private let socEngine: SoCGameEngine
    private let konStore: SaveStore
    private let socStore: SoCSaveStore
    private let audio = AudioManager.shared
    private var pendingSocName = false
    private var pendingSocNameConfirm: String?

    init(
        konEngine: GameEngine = GameEngine(),
        socEngine: SoCGameEngine = SoCGameEngine(),
        konStore: SaveStore = SaveStore(product: .kon),
        socStore: SoCSaveStore = SoCSaveStore()
    ) {
        self.konEngine = konEngine
        self.socEngine = socEngine
        self.konStore = konStore
        self.socStore = socStore
        self.achievements = konStore.loadAchievements()
    }

    var textDelay: TextDelay {
        get { activeTextDelay }
        set { setTextDelay(newValue) }
    }

    private var activeTextDelay: TextDelay {
        product == .kon ? konEngine.state.textDelay : socEngine.state.textDelay
    }

    private func setTextDelay(_ value: TextDelay) {
        if product == .kon {
            konEngine.setTextDelay(value)
        } else {
            socEngine.setTextDelay(value)
        }
    }

    var lastDeath: DeathInfo? { product == .kon ? konEngine.lastDeath : nil }

    var konState: GameState { konEngine.state }
    var socState: SoCGameState { socEngine.state }
    var displayDeathCount: Int {
        product == .kon ? konEngine.state.deathCount : socEngine.state.deathCount
    }

    var socCampaignComplete: Bool {
        socStore.load()?.gameComplete == true
    }

    var media: RoomMedia {
        product == .kon ? konEngine.currentMedia() : socEngine.currentMedia()
    }

    var soundEnabled: Bool {
        get { !audio.isMuted }
        set {
            audio.isMuted = !newValue
            if newValue { refreshAmbient() }
        }
    }

    func onLaunch() {
        if screen == .saga || screen == .title { audio.playAmbient(SoundCue.titleTheme.rawValue) }
    }

    private func screenDidChange() {
        switch screen {
        case .saga, .title, .credits:
            audio.playAmbient(SoundCue.titleTheme.rawValue)
        case .game:
            refreshAmbient()
        case .settings, .achievements, .trophies:
            break
        }
    }

    private func refreshAmbient() {
        audio.playAmbient(media.ambientTrack)
    }

    // MARK: - Saga navigation

    func openProduct(_ product: AvasiaProduct) {
        self.product = product
        screen = .title
    }

    func backToSaga() {
        screen = .saga
    }

    // MARK: - Lifecycle

    func startNewGame() {
        transcript = []
        pendingDeath = false
        switch product {
        case .kon:
            konEngine.restart()
            appendIntro()
            append(konEngine.describeCurrent())
            recordStartingRegion()
        case .soc:
            socEngine.restart()
            var fresh = socEngine.state
            fresh.unlockTrophy(.startedAdventure)
            socEngine.load(fresh)
            pendingSocName = true
            pendingSocNameConfirm = nil
            appendSocIntroPrologue()
            append([.hint("What is your name?")])
        }
        screen = .game
    }

    func continueGame() {
        transcript = []
        pendingDeath = false
        switch product {
        case .kon:
            guard let saved = konStore.load() else { startNewGame(); return }
            konEngine.load(saved)
            append(konEngine.describeCurrent())
            recordStartingRegion()
        case .soc:
            guard let saved = socStore.load() else { startNewGame(); return }
            socEngine.load(saved)
            append(socEngine.describeCurrent())
        }
        screen = .game
    }

    private func recordStartingRegion() {
        let unlocked = AchievementTracker.recordRegion(konEngine.currentMedia().region, into: &achievements)
        finishAchievements(unlocked)
    }

    var hasSave: Bool {
        switch product {
        case .kon: return konStore.load() != nil
        case .soc: return socStore.load() != nil
        }
    }

    // MARK: - Turn loop

    func submit() {
        let raw = input.trimmingCharacters(in: .whitespaces)
        input = ""
        guard !raw.isEmpty else { return }
        append([.hint("> \(raw)")])

        switch product {
        case .kon:
            submitKon(raw)
        case .soc:
            submitSoc(raw)
        }
    }

    private func submitKon(_ raw: String) {
        let before = konEngine.state.deathCount
        let lines = konEngine.submit(raw)
        append(lines)

        let unlocked = AchievementTracker.apply(konEngine.lastEvents, state: konEngine.state, into: &achievements)
        finishAchievements(unlocked)

        if konEngine.state.deathCount > before {
            audio.play(.death)
            pendingDeath = true
            return
        }
        switch konEngine.lastTransition {
        case .win:  audio.play(.win)
        case .move: audio.play(.move); refreshAmbient()
        default:    break
        }
        if lines.contains(where: { $0.style == .item }) {
            audio.play(lines.contains { $0.text.lowercased().contains("spell") } ? .spellLearned : .itemGained)
        }
        try? konStore.save(konEngine.state)
        try? konStore.save(konEngine.state, to: .checkpoint)
    }

    private func submitSoc(_ raw: String) {
        if handleSocNameEntry(raw) { return }

        let audienceBefore = socEngine.state.throneAudience
        let completeBefore = socEngine.state.gameComplete
        let trophiesBefore = socEngine.state.trophies
        let lines = socEngine.submit(raw)
        append(lines)
        finishSocTrophies(before: trophiesBefore, after: socEngine.state.trophies)
        if socEngine.playerDiedOnLastTurn {
            audio.play(.death)
            pendingDeath = true
            return
        }
        if !audienceBefore && socEngine.state.throneAudience {
            audio.play(.win)
        }
        if !completeBefore && socEngine.state.gameComplete {
            audio.play(.win)
        }
        if case .move = socEngine.lastTransition {
            audio.play(.move)
            refreshAmbient()
        }
        try? socStore.save(socEngine.state)
        try? socStore.save(socEngine.state, to: .checkpoint)
    }

    private func finishAchievements(_ unlocked: [Achievement]) {
        guard !unlocked.isEmpty else { return }
        konStore.saveAchievements(achievements)
        recentlyUnlocked.append(contentsOf: unlocked)
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.recentlyUnlocked.removeAll { unlocked.contains($0) }
        }
    }

    private func finishSocTrophies(before: Set<SoCTrophy>, after: Set<SoCTrophy>) {
        let unlocked = after.subtracting(before).sorted { $0.rawValue < $1.rawValue }
        guard !unlocked.isEmpty else { return }
        recentlyUnlockedTrophies.append(contentsOf: unlocked)
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.recentlyUnlockedTrophies.removeAll { unlocked.contains($0) }
        }
    }

    func quickAction(_ verb: String) {
        if product == .soc {
            switch verb.lowercased() {
            case "attack": input = "attack"
            case "eat potion": input = "eat potion"
            case "advance": input = "advance"
            case "march": input = "march"
            case "inventory": input = "inventory"
            default: input = verb
            }
        } else {
            input = verb
        }
        submit()
    }

    func openSettings(from screen: Screen) {
        menuReturn = screen
        self.screen = .settings
    }

    func openCredits(from screen: Screen) {
        menuReturn = screen
        self.screen = .credits
    }

    func openAchievements(from screen: Screen) {
        achievementsReturn = screen
        self.screen = .achievements
    }

    func openTrophies(from screen: Screen) {
        trophiesReturn = screen
        if screen == .title, let saved = socStore.load() {
            socEngine.load(saved)
        }
        self.screen = .trophies
    }

    func restartFromCheckpoint() {
        transcript = []
        pendingDeath = false
        switch product {
        case .kon:
            if let cp = konStore.load(.checkpoint) { konEngine.load(cp) }
            append(konEngine.describeCurrent())
        case .soc:
            if let cp = socStore.load(.checkpoint) { socEngine.load(cp) }
            append(socEngine.describeCurrent())
        }
    }

    func restartFromBeginning() { startNewGame() }

    // MARK: - Intro text

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

    /// Opening narration from `Avasia-SoC/Logic/util.py` (verbatim where noted).
    private func appendSocIntroPrologue() {
        append([
            .title("Avasia: Sword of Courage"),
            .body("It has been six months since the Agromanian's, a viscious people of the northwest, attack on Oceandale."),
            .body("Nacastrum, the city of the Mage, is still being rebuilt under the diligent leadership of its new king."),
            .body("Recently, news was brought to King Kaefden IV that Vashirr, the traitor ex-king of Nacastrum, is teaching the Agromanians magic."),
            .body("With this knowledge, King Kaefden IV has begun to recruit an army to march on the Agromanians before they have a chance to muster."),
            .blank,
            .body("You are a druid living in the peaceful city of Cataracta."),
            .body("Cataracta has formed a pact with the people of Aylova to join the fight when the time comes."),
            .body("The leader of Cataracta is drafting an army and you have decided to volunteer."),
            .body("This is where your story begins...")
        ])
    }

    private func appendSocHouseIntro() {
        let name = socEngine.state.playerName
        append([
            .blank,
            .title("\(name)'s House"),
            .body("Today is the day you join Cataracta's Legion."),
            .body("To join, you must head to the Legion's courtyard."),
            .body("You collect your belongings and leave your home with a sense of pride."),
            .blank
        ])
    }

    private func handleSocNameEntry(_ raw: String) -> Bool {
        let upper = raw.uppercased()
        let yes = upper.contains("YES") || upper == "Y"
        let no = upper.contains("NO") || upper == "N"

        if let candidate = pendingSocNameConfirm {
            if yes {
                var state = socEngine.state
                state.playerName = titleCaseName(candidate)
                socEngine.load(state)
                pendingSocNameConfirm = nil
                appendSocHouseIntro()
                append(socEngine.describeCurrent())
                try? socStore.save(socEngine.state)
                try? socStore.save(socEngine.state, to: .checkpoint)
                return true
            }
            if no {
                pendingSocNameConfirm = nil
                pendingSocName = true
                append([.hint("What is your name?")])
                return true
            }
            append([.body("Your name is \(titleCaseName(candidate))? (yes/no)")])
            return true
        }

        if pendingSocName {
            let trimmed = raw.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { return true }
            pendingSocName = false
            pendingSocNameConfirm = trimmed
            append([
                .blank,
                .body("Your name is \(titleCaseName(trimmed))? (yes/no)"),
                .hint("You can't change it once it's set.")
            ])
            return true
        }

        return false
    }

    private func titleCaseName(_ raw: String) -> String {
        raw.split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
}
