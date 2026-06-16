import Foundation
import SwiftUI
import AvasiaEngine
import AvasiaSoCEngine
import AvasiaAnthologyEngine
#if canImport(UIKit)
import UIKit
#endif

/// Bridges engine(s) to SwiftUI. KoN and Blade of Courage are separate products
/// with separate saves, selected from `SagaTitleView`.
@MainActor
final class GameViewModel: ObservableObject {
    enum Screen { case saga, title, settings, game, credits, achievements, trophies, privacyPolicy }

    @Published var screen: Screen = .saga {
        didSet { screenDidChange() }
    }
    @Published var product: AvasiaProduct = .kon
    @Published private(set) var transcript: [StyledLine] = []
    @Published private(set) var completedLineCount = 0
    @Published private(set) var typingVisibleCount: Int?
    @Published private(set) var isPacingWaiting = false
    @Published private(set) var pendingDeath = false
    @Published private(set) var achievements: AchievementState
    @Published private(set) var recentlyUnlocked: [Achievement] = []
    @Published private(set) var recentlyUnlockedTrophies: [SoCTrophy] = []
    @Published private(set) var pendingLevelUp: Int?
    @Published var input: String = ""
    @Published var showStoryPicker = false
    var achievementsReturn: Screen = .title
    var trophiesReturn: Screen = .title
    var menuReturn: Screen = .saga
    var privacyReturn: Screen = .settings

    @Published var appearance: AppAppearance = AppSettings.appearance {
        didSet {
            AppSettings.appearance = appearance
            applyThemeRedraw()
        }
    }
    @Published var typewriterSpeed: TypewriterSpeed = AppSettings.typewriterSpeed {
        didSet { AppSettings.typewriterSpeed = typewriterSpeed }
    }
    @Published var cursorStyle: CursorStyle = AppSettings.cursorStyle {
        didSet { AppSettings.cursorStyle = cursorStyle }
    }
    @Published private(set) var systemColorScheme: ColorScheme = GameViewModel.initialSystemColorScheme
    @Published private(set) var themeRevision = 0

    private let konEngine: GameEngine
    private let socEngine: SoCGameEngine
    private let anthologyEngine: AnthologyGameEngine
    private let konStore: SaveStore
    private let socStore: SoCSaveStore
    private let anthologyStore: AnthologySaveStore
    private let audio = AudioManager.shared
    private var pendingSocName = false
    private var pendingSocNameConfirm: String?
    private var pacingTask: Task<Void, Never>?
    private var pacingContinuation: CheckedContinuation<Void, Never>?

    var visibleTranscriptLines: [TranscriptDisplayLine] {
        var lines: [TranscriptDisplayLine] = []
        for index in 0..<completedLineCount {
            lines.append(TranscriptDisplayLine(id: index, line: transcript[index], partialLength: nil))
        }
        if let partial = typingVisibleCount, completedLineCount < transcript.count {
            lines.append(
                TranscriptDisplayLine(
                    id: completedLineCount,
                    line: transcript[completedLineCount],
                    partialLength: partial,
                    showsCursor: cursorStyle.glyph != nil
                )
            )
        }
        return lines
    }

    var isPacingActive: Bool {
        completedLineCount < transcript.count || typingVisibleCount != nil || isPacingWaiting
    }

    init(
        konEngine: GameEngine = GameEngine(),
        socEngine: SoCGameEngine = SoCGameEngine(),
        anthologyEngine: AnthologyGameEngine = AnthologyGameEngine(),
        konStore: SaveStore = SaveStore(product: .kon),
        socStore: SoCSaveStore = SoCSaveStore(),
        anthologyStore: AnthologySaveStore = AnthologySaveStore()
    ) {
        self.konEngine = konEngine
        self.socEngine = socEngine
        self.anthologyEngine = anthologyEngine
        self.konStore = konStore
        self.socStore = socStore
        self.anthologyStore = anthologyStore
        self.achievements = konStore.loadAchievements()
        applyStoredPreferences()
        refreshThemePalette()
    }

    func updateSystemColorScheme(_ scheme: ColorScheme) {
        guard systemColorScheme != scheme else { return }
        systemColorScheme = scheme
        applyThemeRedraw()
    }

    func refreshThemePalette() {
        Theme.applyPalette(for: appearance, system: systemColorScheme)
    }

    private func applyThemeRedraw() {
        refreshThemePalette()
        themeRevision += 1
    }

    private static var initialSystemColorScheme: ColorScheme {
        #if canImport(UIKit)
        return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
        #else
        return .dark
        #endif
    }

    var preferredColorScheme: ColorScheme? {
        appearance.preferredColorScheme(system: systemColorScheme)
    }

    private func applyStoredPreferences() {
        let delay = AppSettings.textDelay
        konEngine.setTextDelay(delay)
        socEngine.setTextDelay(delay)
        audio.isMuted = !AppSettings.soundEnabled
    }

    var textDelay: TextDelay {
        get { activeTextDelay }
        set { setTextDelay(newValue) }
    }

    private var activeTextDelay: TextDelay {
        switch product {
        case .kon: return konEngine.state.textDelay
        case .soc: return socEngine.state.textDelay
        case .stories: return anthologyEngine.state.textDelay
        }
    }

    private func setTextDelay(_ value: TextDelay) {
        AppSettings.textDelay = value
        konEngine.setTextDelay(value)
        socEngine.setTextDelay(value)
        anthologyEngine.setTextDelay(value)
    }

    var socIsNaming: Bool { product == .soc && pendingSocName }
    var socIsConfirmingName: Bool { product == .soc && pendingSocNameConfirm != nil }

    var lastDeath: DeathInfo? { product == .kon ? konEngine.lastDeath : nil }
    var lastSocDeath: SoCDeathInfo? { product == .soc ? socEngine.lastSocDeath : nil }

    var socSaveSummary: String? {
        guard product == .soc, let saved = socStore.load() else { return nil }
        let name = saved.playerName.isEmpty ? "Druid" : saved.playerName
        let cls: String
        switch saved.playerClass {
        case .hunter: cls = "Wolf"
        case .guardian: cls = "Bear"
        case .scout: cls = "Fox"
        case .none: cls = "—"
        }
        let progress = saved.gameComplete ? "Complete" : SoCChapter.title(for: saved.currentRoom)
        return "\(name) · \(cls) · Lv \(saved.playerLevel) · \(progress)"
    }

    var konState: GameState { konEngine.state }
    var socState: SoCGameState { socEngine.state }
    var anthologyState: AnthologyGameState { anthologyEngine.state }
    var displayDeathCount: Int {
        switch product {
        case .kon: return konEngine.state.deathCount
        case .soc: return socEngine.state.deathCount
        case .stories: return 0
        }
    }

    var storiesSaveSummary: String? {
        guard product == .stories, let saved = anthologyStore.load() else { return nil }
        let fp = saved.factionPoints
        if saved.storyZeroComplete {
            return "\(fp) FP · alignment: \(saved.alignment.rawValue)"
        }
        return "Scout Patrol · in progress"
    }

    var socCampaignComplete: Bool {
        socStore.load()?.gameComplete == true
    }

    var media: RoomMedia {
        switch product {
        case .kon: return konEngine.currentMedia()
        case .soc: return socEngine.currentMedia()
        case .stories: return anthologyEngine.currentMedia()
        }
    }

    var soundEnabled: Bool {
        get { !audio.isMuted }
        set {
            audio.isMuted = !newValue
            AppSettings.soundEnabled = newValue
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
        case .settings, .achievements, .trophies, .privacyPolicy:
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

    func startNewGame(loadError: Bool = false) {
        resetTranscript()
        pendingDeath = false
        switch product {
        case .kon:
            konEngine.restart()
            konEngine.setTextDelay(AppSettings.textDelay)
            if loadError {
                append([.hint("Your saved game could not be loaded. Starting fresh.")])
            }
            appendIntro()
            append(konEngine.describeCurrent())
            recordStartingRegion()
        case .soc:
            socEngine.restart()
            socEngine.setTextDelay(AppSettings.textDelay)
            if loadError {
                append([.hint("Your saved game could not be loaded. Starting fresh.")])
            }
            var fresh = socEngine.state
            fresh.unlockTrophy(.startedAdventure)
            socEngine.load(fresh)
            pendingSocName = true
            pendingSocNameConfirm = nil
            appendSocIntroPrologue()
            append([.hint("What is your name?")])
        case .stories:
            anthologyEngine.restart()
            anthologyEngine.setTextDelay(AppSettings.textDelay)
            if loadError {
                append([.hint("Your saved game could not be loaded. Starting fresh.")])
            }
            appendStoriesIntro()
            append(anthologyEngine.describeCurrent())
            showStoryPicker = true
        }
        screen = .game
    }

    func continueGame() {
        resetTranscript()
        pendingDeath = false
        switch product {
        case .kon:
            guard let saved = konStore.load() else {
                startNewGame(loadError: true)
                return
            }
            konEngine.load(saved)
            append(konEngine.describeCurrent())
            recordStartingRegion()
        case .soc:
            guard let saved = socStore.load() else {
                startNewGame(loadError: true)
                return
            }
            socEngine.load(saved)
            append(socEngine.describeCurrent())
        case .stories:
            guard let saved = anthologyStore.load() else {
                startNewGame(loadError: true)
                return
            }
            anthologyEngine.load(saved)
            append(anthologyEngine.describeCurrent())
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
        case .stories: return anthologyStore.load() != nil
        }
    }

    func hasSave(for product: AvasiaProduct) -> Bool {
        switch product {
        case .kon: return konStore.load() != nil
        case .soc: return socStore.load() != nil
        case .stories: return anthologyStore.load() != nil
        }
    }

    func sagaSaveHint(for product: AvasiaProduct) -> String? {
        switch product {
        case .kon:
            guard let saved = konStore.load() else { return nil }
            let place = saved.currentRoom.region.title
            return saved.gameComplete ? "Complete · \(place)" : "Continue · \(place)"
        case .soc:
            guard let saved = socStore.load() else { return nil }
            let name = saved.playerName.isEmpty ? "Druid" : saved.playerName
            let progress = saved.gameComplete ? "Complete" : SoCChapter.title(for: saved.currentRoom)
            return "\(name) · Lv \(saved.playerLevel) · \(progress)"
        case .stories:
            guard let saved = anthologyStore.load() else { return nil }
            let fp = saved.factionPoints
            if saved.currentRoom == .storyHub, saved.storyZeroComplete {
                return "\(fp) FP · Story hub"
            }
            if saved.storyZeroComplete {
                return "\(fp) FP · \(saved.alignment.rawValue)"
            }
            return "Scout Patrol"
        }
    }

    // MARK: - Turn loop

    func submit() {
        flushPacing()
        let raw = input.trimmingCharacters(in: .whitespaces)
        input = ""
        guard !raw.isEmpty else { return }
        append([.hint("> \(raw)")])

        switch product {
        case .kon:
            submitKon(raw)
        case .soc:
            submitSoc(raw)
        case .stories:
            submitStories(raw)
        }
    }

    private func submitKon(_ raw: String) {
        let before = konEngine.state.deathCount
        let completeBefore = konEngine.state.gameComplete
        let lines = konEngine.submit(raw)
        append(lines)

        let unlocked = AchievementTracker.apply(konEngine.lastEvents, state: konEngine.state, into: &achievements)
        finishAchievements(unlocked)

        if konEngine.state.deathCount > before {
            audio.play(.death)
            pendingDeath = true
            return
        }
        if !completeBefore && konEngine.state.gameComplete {
            audio.play(.win)
        } else if case .move = konEngine.lastTransition {
            audio.play(.move)
            refreshAmbient()
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
        let levelBefore = socEngine.state.playerLevel
        let roomBefore = socEngine.state.currentRoom
        let lines = socEngine.submit(raw)
        append(lines)
        if socEngine.state.playerLevel > levelBefore {
            pendingLevelUp = socEngine.state.playerLevel
        }
        if case .move = socEngine.lastTransition, socEngine.state.currentRoom != roomBefore,
           let banner = SoCChapter.banner(for: socEngine.state.currentRoom) {
            append([.blank, banner])
        }
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

    private func submitStories(_ raw: String) {
        let completeBefore = anthologyCompletedCount
        let lines = anthologyEngine.submit(raw)
        append(lines)
        if anthologyCompletedCount > completeBefore {
            audio.play(.win)
        }
        if case .move = anthologyEngine.lastTransition {
            audio.play(.move)
            refreshAmbient()
            if anthologyEngine.state.currentRoom == .storyHub {
                showStoryPicker = true
            }
        }
        try? anthologyStore.save(anthologyEngine.state)
        try? anthologyStore.save(anthologyEngine.state, to: .checkpoint)
    }

    private var anthologyCompletedCount: Int {
        anthologyEngine.state.completedStories.count
    }

    func openStoryPicker() {
        showStoryPicker = true
    }

    func launchAnthologyStory(_ story: AnthologyStoryID) {
        flushPacing()
        showStoryPicker = false
        let lines = anthologyEngine.launchStory(story)
        append(lines)
        if case .move = anthologyEngine.lastTransition {
            audio.play(.move)
            refreshAmbient()
        }
        try? anthologyStore.save(anthologyEngine.state)
        try? anthologyStore.save(anthologyEngine.state, to: .checkpoint)
    }

    func launchArena() {
        flushPacing()
        showStoryPicker = false
        let lines = anthologyEngine.launchArena()
        append(lines)
        if case .move = anthologyEngine.lastTransition {
            audio.play(.move)
            refreshAmbient()
        }
        try? anthologyStore.save(anthologyEngine.state)
        try? anthologyStore.save(anthologyEngine.state, to: .checkpoint)
    }

    func openTrainingShop() {
        flushPacing()
        showStoryPicker = false
        let lines = anthologyEngine.openTrainingShop()
        append(lines)
        if case .move = anthologyEngine.lastTransition {
            audio.play(.move)
            refreshAmbient()
        }
        try? anthologyStore.save(anthologyEngine.state)
        try? anthologyStore.save(anthologyEngine.state, to: .checkpoint)
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

    func dismissLevelUp() {
        pendingLevelUp = nil
    }

    func quickAction(_ verb: String) {
        flushPacing()
        if socIsConfirmingName {
            switch verb.lowercased() {
            case "yes", "no": input = verb.lowercased()
            default: return
            }
            submit()
            return
        }
        if socIsNaming { return }
        if product == .stories, verb.lowercased() == "choose story" {
            openStoryPicker()
            return
        }
        if product == .soc {
            switch verb.lowercased() {
            case "attack": input = "attack"
            case "eat potion": input = "eat potion"
            case "advance": input = "advance"
            case "march": input = "march"
            case "visit ruins": input = "visit ruins"
            case "objectives": input = "objectives"
            case "inventory": input = "inventory"
            default: input = verb
            }
        } else {
            input = verb
        }
        submit()
    }

    func openPrivacyPolicy(from screen: Screen) {
        privacyReturn = screen
        self.screen = .privacyPolicy
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
        resetTranscript()
        pendingDeath = false
        switch product {
        case .kon:
            if let cp = konStore.load(.checkpoint) { konEngine.load(cp) }
            append(konEngine.describeCurrent())
        case .soc:
            if let cp = socStore.load(.checkpoint) { socEngine.load(cp) }
            append(socEngine.describeCurrent())
        case .stories:
            if let cp = anthologyStore.load(.checkpoint) { anthologyEngine.load(cp) }
            append(anthologyEngine.describeCurrent())
        }
    }

    func restartFromBeginning() { startNewGame() }

    // MARK: - Text pacing

    func advancePacing() {
        pacingTask?.cancel()
        pacingTask = nil

        if isPacingWaiting {
            pacingContinuation?.resume()
            pacingContinuation = nil
            return
        }

        if typingVisibleCount != nil {
            typingVisibleCount = nil
            if completedLineCount < transcript.count {
                completedLineCount += 1
            }
            startPacing()
            return
        }

        if completedLineCount < transcript.count {
            startPacing()
        }
    }

    func flushPacing() {
        pacingTask?.cancel()
        pacingTask = nil
        if isPacingWaiting {
            pacingContinuation?.resume()
            pacingContinuation = nil
        }
        isPacingWaiting = false
        typingVisibleCount = nil
        completedLineCount = transcript.count
    }

    private func resetTranscript() {
        pacingTask?.cancel()
        pacingTask = nil
        if isPacingWaiting {
            pacingContinuation?.resume()
            pacingContinuation = nil
        }
        isPacingWaiting = false
        transcript = []
        completedLineCount = 0
        typingVisibleCount = nil
    }

    private func append(_ lines: [StyledLine]) {
        guard !lines.isEmpty else { return }
        transcript.append(contentsOf: lines)
        startPacing()
    }

    private func startPacing() {
        pacingTask?.cancel()
        let mode = activeTextDelay
        if mode == .off {
            completedLineCount = transcript.count
            typingVisibleCount = nil
            isPacingWaiting = false
            return
        }
        guard completedLineCount < transcript.count else { return }

        pacingTask = Task { @MainActor [weak self] in
            await self?.runPacingLoop()
        }
    }

    private func runPacingLoop() async {
        while completedLineCount < transcript.count {
            if Task.isCancelled { return }

            let line = transcript[completedLineCount]
            let mode = activeTextDelay
            if mode == .off {
                completedLineCount = transcript.count
                typingVisibleCount = nil
                return
            }

            await typeLine(line)
            completedLineCount += 1
            typingVisibleCount = nil

            guard completedLineCount < transcript.count else {
                isPacingWaiting = false
                return
            }

            if mode == .tapToAdvance {
                isPacingWaiting = true
                await withCheckedContinuation { continuation in
                    pacingContinuation = continuation
                }
                isPacingWaiting = false
                if Task.isCancelled { return }
                continue
            }

            let seconds = line.text.isEmpty
                ? TextPacing.blankLineDelaySeconds
                : TextPacing.interLineDelaySeconds
            do {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            } catch {
                return
            }
        }
    }

    private func typeLine(_ line: StyledLine) async {
        if line.text.isEmpty {
            typingVisibleCount = 0
            do {
                try await Task.sleep(nanoseconds: UInt64(TextPacing.blankLineDelaySeconds * 1_000_000_000))
            } catch {
                return
            }
            typingVisibleCount = nil
            return
        }

        let total = line.text.count
        typingVisibleCount = 0
        for visible in 1...total {
            if Task.isCancelled { return }
            typingVisibleCount = visible
            guard visible < total else { break }
            let delay = TextPacing.characterDelay(for: line.style)
            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            } catch {
                return
            }
        }
        typingVisibleCount = nil
    }

    // MARK: - Intro text

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

    /// Scout Patrol (#0) — parallel anthology, not KoN or SoC protagonist.
    private func appendStoriesIntro() {
        append([
            .title("Short Stories"),
            .body("Parallel tales beside the Age-era duology. Earn faction points, unlock paths."),
            .body("Start with Scout Patrol — then spend FP on stories matching your alignment."),
            .blank
        ])
    }

    /// Opening narration from `Avasia-SoC/Logic/util.py` (verbatim where noted).
    /// Opening narration — canonical 7-year timeline (`docs/sequel/STORY.md` §2).
    private func appendSocIntroPrologue() {
        append([
            .title("Avasia: Blade of Courage"),
            .body("It has been seven years since the fall of Oceandale and the crowning of King Kaefden IV."),
            .body("In all that time, no Agromanian army has crossed the border — yet the Kaefdens have not rested."),
            .body("Nacastrum rises again while legions train for the war everyone knows is coming."),
            .body("Recently, word reached Aylova from Silvarium: Vashirr, the traitor ex-king of Nacastrum, stands at the Agromanian king's right hand — and teaches their warriors magic."),
            .body("They call these new soldiers Paladins."),
            .body("King Kaefden IV has begun recruiting in earnest before the northwest can muster."),
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
            .hint("Type OBJECTIVES anytime for your current goals."),
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
