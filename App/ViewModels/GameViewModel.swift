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
    enum Screen { case saga, title, settings, game, credits, achievements, trophies, codex, timeline, privacyPolicy, chroniclerLedger }

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
    @Published private(set) var sagaProfile: SagaProfile
    @Published private(set) var recentChroniclerXP: [SagaXPEntry] = []
    @Published private(set) var recentlyUnlocked: [Achievement] = []
    @Published private(set) var recentlyUnlockedTrophies: [SoCTrophy] = []
    @Published private(set) var pendingLevelUp: Int?
    @Published private(set) var healthBarFlash: HealthBarFlash?
    @Published private(set) var combatPresentationEvents: [CombatPresentationEvent] = []
    @Published private(set) var displayedPlayerHp: Int = 0
    @Published private(set) var displayedEnemyHp: Int = 0
    @Published private(set) var displayedEnemyMaxHp: Int = 0
    @Published private(set) var displayedEnemyName: String = ""
    @Published private(set) var displayedGold: Int = 0
    @Published private(set) var goldFloatDelta: Int?
    @Published private(set) var combatStripVisible = false
    @Published private(set) var isCombatBusy = false
    @Published private(set) var bouncingSocItems: Set<SoCItem> = []
    @Published private(set) var lineEmphases: [Int: CombatLineEmphasis] = [:]
    @Published private(set) var lowHpVignette = false
    @Published private(set) var revealLineIndex: Int?
    @Published var input: String = ""
    @Published var showStoryPicker = false
    var achievementsReturn: Screen = .title
    var trophiesReturn: Screen = .title
    var codexReturn: Screen = .title
    var timelineReturn: Screen = .saga
    var chroniclerReturn: Screen = .saga
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
    private let sagaStore: SagaProfileStore
    private let audio = AudioManager.shared
    private var pendingSocName = false
    private var pendingSocNameConfirm: String?
    private var pacingTask: Task<Void, Never>?
    private var pacingContinuation: CheckedContinuation<Void, Never>?
    private var healthBarFlashTask: Task<Void, Never>?
    private var combatLineTriggers: [Int: [CombatTriggerAction]] = [:]
    private var combatBusyTask: Task<Void, Never>?
    private var goldFloatTask: Task<Void, Never>?
    private var lowHpVignetteTask: Task<Void, Never>?
    private var itemBounceTask: Task<Void, Never>?
    private var revealLineTask: Task<Void, Never>?
    private let haptics = HapticManager.shared

    var visibleTranscriptLines: [TranscriptDisplayLine] {
        var lines: [TranscriptDisplayLine] = []
        for index in 0..<completedLineCount {
            lines.append(
                TranscriptDisplayLine(
                    id: index,
                    line: transcript[index],
                    partialLength: nil,
                    emphasis: lineEmphases[index],
                    playReveal: index == revealLineIndex
                )
            )
        }
        if let partial = typingVisibleCount, completedLineCount < transcript.count {
            lines.append(
                TranscriptDisplayLine(
                    id: completedLineCount,
                    line: transcript[completedLineCount],
                    partialLength: partial,
                    showsCursor: cursorStyle.glyph != nil,
                    emphasis: lineEmphases[completedLineCount]
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
        anthologyStore: AnthologySaveStore = AnthologySaveStore(),
        sagaStore: SagaProfileStore = SagaProfileStore()
    ) {
        self.konEngine = konEngine
        self.socEngine = socEngine
        self.anthologyEngine = anthologyEngine
        self.konStore = konStore
        self.socStore = socStore
        self.anthologyStore = anthologyStore
        self.sagaStore = sagaStore
        self.achievements = konStore.loadAchievements()
        self.sagaProfile = sagaStore.load()
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

    /// Save or live state for journal unlock checks (title uses save; in-game uses live).
    var konCodexState: GameState? {
        guard product == .kon else { return nil }
        if screen == .game { return konEngine.state }
        return konStore.load()
    }

    var socCodexState: SoCGameState? {
        guard product == .soc else { return nil }
        if screen == .game { return socEngine.state }
        return socStore.load()
    }

    var sagaKonSave: GameState? { konStore.load() }
    var sagaSocSave: SoCGameState? { socStore.load() }
    var sagaAnthologySave: AnthologyGameState? { anthologyStore.load() }
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
        case .settings, .achievements, .trophies, .codex, .timeline, .privacyPolicy, .chroniclerLedger:
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

    func openTimeline(from screen: Screen) {
        timelineReturn = screen
        self.screen = .timeline
    }

    func openChroniclerLedger(from screen: Screen) {
        chroniclerReturn = screen
        self.screen = .chroniclerLedger
    }

    func claimChroniclerAchievement(_ achievement: Achievement) {
        guard achievements.has(achievement) else { return }
        if let entry = SagaXPTracker.claimAchievement(achievement, profile: &sagaProfile) {
            finishChroniclerGrants([entry])
        }
    }

    func resetChroniclerProgress() {
        sagaProfile = SagaProfile()
        sagaStore.reset()
    }

    var chroniclerPendingClaims: [Achievement] {
        Achievement.allCases.filter { achievements.has($0) && sagaProfile.canClaimAchievement($0) }
    }

    // MARK: - Lifecycle

    func startNewGame(loadError: Bool = false, playHaptic: Bool = true) {
        if playHaptic { haptics.play(.confirm) }
        resetTranscript()
        pendingDeath = false
        SagaXPTracker.beginRun(product: product, profile: &sagaProfile)
        switch product {
        case .kon:
            konEngine.restart()
            konEngine.setTextDelay(AppSettings.textDelay)
            if loadError {
                append([.hint("Your saved game could not be loaded. Starting fresh.")])
            }
            append([.title("Avasia: King of Nacastrum")])
            konEngine.restart()
            konEngine.setTextDelay(AppSettings.textDelay)
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
        syncDisplayedStats()
        persistSagaProfile()
    }

    func continueGame() {
        haptics.play(.confirm)
        resetTranscript()
        pendingDeath = false
        SagaXPTracker.resumeSession(profile: &sagaProfile)
        switch product {
        case .kon:
            guard let saved = konStore.load() else {
                startNewGame(loadError: true, playHaptic: false)
                return
            }
            konEngine.load(saved)
            append(konEngine.describeCurrent())
            recordStartingRegion()
        case .soc:
            guard let saved = socStore.load() else {
                startNewGame(loadError: true, playHaptic: false)
                return
            }
            socEngine.load(saved)
            append(socEngine.describeCurrent())
        case .stories:
            guard let saved = anthologyStore.load() else {
                startNewGame(loadError: true, playHaptic: false)
                return
            }
            anthologyEngine.load(saved)
            append(anthologyEngine.describeCurrent())
        }
        screen = .game
        syncDisplayedStats()
        persistSagaProfile()
    }

    private func recordStartingRegion() {
        let region = konEngine.currentMedia().region
        let unlocked = AchievementTracker.recordRegion(region, into: &achievements)
        finishAchievements(unlocked)
        let xp = SagaXPTracker.apply([.enteredRegion(region)], state: konEngine.state, profile: &sagaProfile)
        finishChroniclerGrants(xp)
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

    func submit(playHaptic: Bool = false) {
        if playHaptic { haptics.play(.tap) }
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
        let xp = SagaXPTracker.apply(konEngine.lastEvents, state: konEngine.state, profile: &sagaProfile)
        finishChroniclerGrants(xp)

        if konEngine.state.deathCount > before {
            if let cause = konEngine.lastDeath?.cause {
                finishChroniclerGrants([SagaXPTracker.recordKonDeath(cause: cause, profile: &sagaProfile)].compactMap { $0 })
            }
            presentDeath()
            return
        }
        if !completeBefore && konEngine.state.gameComplete {
            audio.play(.win)
        } else if case .move = konEngine.lastTransition {
            playMoveFeedback()
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
        let hpBefore = socEngine.state.playerHp
        let enemyHpBefore = socEngine.state.enemy?.hp
        let enemyMaxBefore = socEngine.state.enemy?.maxHp
        let enemyNameBefore = socEngine.state.enemy?.name
        let inCombatBefore = socEngine.state.inCombat
        let goldBefore = socEngine.state.gold
        let itemsBefore = socInventoryItems
        let lineStartIndex = transcript.count
        let lines = socEngine.submit(raw)
        queueSocCombatPlan(
            lines: lines,
            lineStartIndex: lineStartIndex,
            hpBefore: hpBefore,
            enemyHpBefore: enemyHpBefore,
            enemyMaxBefore: enemyMaxBefore,
            enemyNameBefore: enemyNameBefore,
            goldBefore: goldBefore,
            itemsBefore: itemsBefore,
            inCombatBefore: inCombatBefore
        )
        if inCombatBefore || socEngine.state.inCombat {
            isCombatBusy = true
        }
        append(lines)
        if socEngine.state.playerLevel > levelBefore {
            pendingLevelUp = socEngine.state.playerLevel
            haptics.play(.notify)
        }
        if case .move = socEngine.lastTransition, socEngine.state.currentRoom != roomBefore,
           let banner = SoCChapter.banner(for: socEngine.state.currentRoom) {
            append([.blank, banner])
        }
        finishSocTrophies(before: trophiesBefore, after: socEngine.state.trophies)
        if socEngine.playerDiedOnLastTurn {
            finishChroniclerGrants([SagaXPTracker.recordSocDeath(profile: &sagaProfile)].compactMap { $0 })
            presentDeath()
            return
        }
        if !completeBefore && socEngine.state.gameComplete {
            finishChroniclerGrants([SagaXPTracker.recordSocWin(profile: &sagaProfile)].compactMap { $0 })
        }
        if !audienceBefore && socEngine.state.throneAudience {
            audio.play(.win)
        }
        if !completeBefore && socEngine.state.gameComplete {
            audio.play(.win)
        }
        if case .move = socEngine.lastTransition {
            playMoveFeedback()
        }
        try? socStore.save(socEngine.state)
        try? socStore.save(socEngine.state, to: .checkpoint)
    }

    private func submitStories(_ raw: String) {
        let storiesBefore = anthologyEngine.state.completedStories
        let completeBefore = anthologyCompletedCount
        let hpBefore = anthologyEngine.state.arenaHp
        let enemyHpBefore = anthologyEngine.state.arenaEnemyHp
        let enemyNameBefore = anthologyEngine.state.arenaEnemyName
        let inCombatBefore = anthologyEngine.state.arenaInCombat
        let goldBefore = anthologyEngine.state.anthologyGold
        let lineStartIndex = transcript.count
        let lines = anthologyEngine.submit(raw)
        queueArenaCombatPlan(
            lines: lines,
            lineStartIndex: lineStartIndex,
            hpBefore: hpBefore,
            enemyHpBefore: enemyHpBefore,
            enemyNameBefore: enemyNameBefore,
            goldBefore: goldBefore,
            inCombatBefore: inCombatBefore
        )
        if inCombatBefore || anthologyEngine.state.arenaInCombat {
            isCombatBusy = true
        }
        append(lines)
        let newStories = anthologyEngine.state.completedStories.subtracting(storiesBefore)
        for storyID in newStories {
            let title = AnthologyCatalog.all.first(where: { $0.id == storyID })?.title ?? storyID.rawValue
            finishChroniclerGrants(
                [SagaXPTracker.recordAnthologyStoryComplete(
                    storyKey: storyID.rawValue,
                    title: title,
                    profile: &sagaProfile
                )].compactMap { $0 }
            )
        }
        if anthologyCompletedCount > completeBefore {
            audio.play(.win)
        }
        if case .move = anthologyEngine.lastTransition {
            playMoveFeedback()
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
        haptics.play(.notify)
        konStore.saveAchievements(achievements)
        recentlyUnlocked.append(contentsOf: unlocked)
        if AppSettings.chroniclerAutoClaimAchievements {
            for achievement in unlocked {
                claimChroniclerAchievement(achievement)
            }
        }
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.recentlyUnlocked.removeAll { unlocked.contains($0) }
        }
    }

    private func finishChroniclerGrants(_ entries: [SagaXPEntry]) {
        guard !entries.isEmpty else { return }
        persistSagaProfile()
        guard AppSettings.chroniclerShowXPToasts else { return }
        let visible = entries.filter { $0.amount > 0 }
        guard !visible.isEmpty else { return }
        recentChroniclerXP.append(contentsOf: visible)
        let ids = Set(visible.map(\.id))
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self?.recentChroniclerXP.removeAll { ids.contains($0.id) }
        }
    }

    private func persistSagaProfile() {
        sagaStore.save(sagaProfile)
    }

    private func finishSocTrophies(before: Set<SoCTrophy>, after: Set<SoCTrophy>) {
        let unlocked = after.subtracting(before).sorted { $0.rawValue < $1.rawValue }
        guard !unlocked.isEmpty else { return }
        haptics.play(.notify)
        recentlyUnlockedTrophies.append(contentsOf: unlocked)
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            self?.recentlyUnlockedTrophies.removeAll { unlocked.contains($0) }
        }
    }

    func dismissLevelUp() {
        haptics.play(.notify)
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

    func openCodex(from screen: Screen) {
        codexReturn = screen
        self.screen = .codex
    }

    func restartFromCheckpoint() {
        haptics.play(.confirm)
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
        syncDisplayedStats()
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
                completeCurrentLine()
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
        drainAllCombatTriggers()
    }

    private func resetTranscript() {
        pacingTask?.cancel()
        pacingTask = nil
        healthBarFlashTask?.cancel()
        healthBarFlashTask = nil
        combatBusyTask?.cancel()
        combatBusyTask = nil
        goldFloatTask?.cancel()
        goldFloatTask = nil
        lowHpVignetteTask?.cancel()
        lowHpVignetteTask = nil
        itemBounceTask?.cancel()
        itemBounceTask = nil
        healthBarFlash = nil
        combatPresentationEvents = []
        combatLineTriggers = [:]
        lineEmphases = [:]
        bouncingSocItems = []
        goldFloatDelta = nil
        lowHpVignette = false
        isCombatBusy = false
        combatStripVisible = false
        revealLineIndex = nil
        revealLineTask?.cancel()
        revealLineTask = nil
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
            drainAllCombatTriggers()
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
            completeCurrentLine()

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

    private func completeCurrentLine() {
        let index = completedLineCount
        processCombatTriggers(forLineIndex: index)
        completedLineCount += 1
        typingVisibleCount = nil
        scheduleLineReveal(for: index)
    }

    private func scheduleLineReveal(for index: Int) {
        guard activeTextDelay != .off else { return }
        revealLineIndex = index
        revealLineTask?.cancel()
        revealLineTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 220_000_000)
            guard !Task.isCancelled else { return }
            if self?.revealLineIndex == index {
                self?.revealLineIndex = nil
            }
        }
    }

    // MARK: - Intro text

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

    // MARK: - Feedback

    private func presentDeath() {
        audio.play(.death)
        haptics.play(.warning)
        pendingDeath = true
    }

    private func playMoveFeedback() {
        audio.play(.move)
        refreshAmbient()
        haptics.play(.impactLight)
    }

    // MARK: - Combat presentation

    private var socInventoryItems: Set<SoCItem> {
        Set(SoCItem.allCases.filter { socEngine.state.inventory[$0, default: 0] > 0 })
    }

    func syncDisplayedStats() {
        switch product {
        case .soc:
            let state = socEngine.state
            displayedPlayerHp = state.playerHp
            displayedGold = state.gold
            if let enemy = state.enemy {
                displayedEnemyHp = enemy.hp
                displayedEnemyMaxHp = enemy.maxHp
                displayedEnemyName = enemy.name
            } else {
                displayedEnemyHp = 0
                displayedEnemyMaxHp = 0
                displayedEnemyName = ""
            }
            combatStripVisible = state.inCombat
        case .stories:
            let state = anthologyEngine.state
            displayedPlayerHp = state.arenaHp
            displayedGold = state.anthologyGold
            displayedEnemyHp = state.arenaEnemyHp
            displayedEnemyMaxHp = state.arenaEnemyMaxHp
            displayedEnemyName = state.arenaEnemyName
            combatStripVisible = state.arenaInCombat
        default:
            break
        }
    }

    private func queueSocCombatPlan(
        lines: [StyledLine],
        lineStartIndex: Int,
        hpBefore: Int,
        enemyHpBefore: Int?,
        enemyMaxBefore: Int?,
        enemyNameBefore: String?,
        goldBefore: Int,
        itemsBefore: Set<SoCItem>,
        inCombatBefore: Bool
    ) {
        let after = socEngine.state
        let plan = CombatTriggerPlanner.planSoc(
            lines: lines,
            lineStartIndex: lineStartIndex,
            hpBefore: hpBefore,
            playerMaxHp: after.playerMaxHp,
            enemyHpBefore: enemyHpBefore,
            enemyMaxHp: enemyMaxBefore,
            enemyName: enemyNameBefore,
            goldBefore: goldBefore,
            newItems: socInventoryItems.subtracting(itemsBefore),
            inCombatBefore: inCombatBefore,
            after: after
        )
        combatPresentationEvents = plan.events
        mergeCombatTriggers(plan.triggers)
    }

    private func queueArenaCombatPlan(
        lines: [StyledLine],
        lineStartIndex: Int,
        hpBefore: Int,
        enemyHpBefore: Int,
        enemyNameBefore: String,
        goldBefore: Int,
        inCombatBefore: Bool
    ) {
        let after = anthologyEngine.state
        let plan = CombatTriggerPlanner.planArena(
            lines: lines,
            lineStartIndex: lineStartIndex,
            hpBefore: hpBefore,
            maxHp: after.arenaMaxHp,
            enemyHpBefore: enemyHpBefore,
            enemyMaxHp: after.arenaEnemyMaxHp,
            enemyName: enemyNameBefore,
            goldBefore: goldBefore,
            inCombatBefore: inCombatBefore,
            after: after
        )
        combatPresentationEvents = plan.events
        mergeCombatTriggers(plan.triggers)
    }

    private func mergeCombatTriggers(_ triggers: [Int: [CombatTriggerAction]]) {
        for (index, actions) in triggers {
            combatLineTriggers[index, default: []].append(contentsOf: actions)
        }
    }

    private func drainAllCombatTriggers() {
        let indices = combatLineTriggers.keys.sorted()
        for index in indices {
            processCombatTriggers(forLineIndex: index)
        }
        finishCombatBusyWindow()
    }

    private func processCombatTriggers(forLineIndex index: Int) {
        guard let actions = combatLineTriggers.removeValue(forKey: index) else { return }
        for action in actions {
            applyCombatTrigger(action, lineIndex: index)
        }
        if combatLineTriggers.isEmpty {
            finishCombatBusyWindow()
        }
    }

    private func applyCombatTrigger(_ action: CombatTriggerAction, lineIndex: Int) {
        switch action {
        case .setPlayerHp(let hp, let flash):
            displayedPlayerHp = hp
            if let flash { setHealthBarFlash(flash) }
            markCombatBusy()
        case .setEnemyHp(let hp, let max, let name):
            displayedEnemyHp = hp
            displayedEnemyMaxHp = max
            if let name, !name.isEmpty { displayedEnemyName = name }
            markCombatBusy()
        case .setGold(let gold, let delta):
            displayedGold = gold
            if let delta, delta > 0 { showGoldFloat(delta) }
        case .emphasis(let emphasis):
            lineEmphases[lineIndex] = emphasis
        case .playSound(let cue):
            audio.play(cue)
        case .haptic(let cue):
            haptics.play(cue)
        case .combatEnter:
            combatStripVisible = true
            switch product {
            case .soc:
                if let enemy = socEngine.state.enemy {
                    displayedEnemyHp = enemy.hp
                    displayedEnemyMaxHp = enemy.maxHp
                    displayedEnemyName = enemy.name
                }
            case .stories:
                let state = anthologyEngine.state
                displayedEnemyHp = state.arenaEnemyHp
                displayedEnemyMaxHp = state.arenaEnemyMaxHp
                displayedEnemyName = state.arenaEnemyName
            default:
                break
            }
        case .combatExit:
            Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 350_000_000)
                self?.combatStripVisible = false
            }
        case .bounceItem(let item):
            bouncingSocItems.insert(item)
            itemBounceTask?.cancel()
            itemBounceTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 700_000_000)
                self?.bouncingSocItems.remove(item)
            }
        case .lowHpVignette:
            lowHpVignette = true
            lowHpVignetteTask?.cancel()
            lowHpVignetteTask = Task { @MainActor [weak self] in
                try? await Task.sleep(nanoseconds: 450_000_000)
                self?.lowHpVignette = false
            }
        }
    }

    private func markCombatBusy() {
        isCombatBusy = true
        combatBusyTask?.cancel()
    }

    private func finishCombatBusyWindow() {
        combatBusyTask?.cancel()
        combatBusyTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard !Task.isCancelled else { return }
            self?.isCombatBusy = false
        }
    }

    private func showGoldFloat(_ delta: Int) {
        goldFloatDelta = delta
        goldFloatTask?.cancel()
        goldFloatTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 700_000_000)
            self?.goldFloatDelta = nil
        }
    }

    private func setHealthBarFlash(_ flash: HealthBarFlash) {
        healthBarFlash = flash
        healthBarFlashTask?.cancel()
        healthBarFlashTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            self?.healthBarFlash = nil
        }
    }
}
