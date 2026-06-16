import Foundation

/// Folds turn events and lifecycle hooks into `SagaProfile`. Pure evaluator — see
/// docs/META_PROGRESSION.md.
public enum SagaXPTracker {
    public static let konWinXP = 500
    public static let konCleanWinBonusXP = 50
    public static let socWinXP = 450

    // MARK: - Run lifecycle

    public static func beginRun(product: AvasiaProduct, profile: inout SagaProfile) {
        profile.currentRunID = UUID()
        profile.currentRunXP = 0
        profile.deathXPGrantsThisRun = 0
        profile.runEventKeys = []
        profile.incrementRunsStarted(product)
    }

    public static func resumeSession(profile: inout SagaProfile) {
        guard profile.currentRunID == nil else { return }
        profile.currentRunID = UUID()
        profile.currentRunXP = 0
        profile.deathXPGrantsThisRun = 0
        profile.runEventKeys = []
    }

    // MARK: - KoN events

    @discardableResult
    public static func apply(
        _ events: [GameEvent],
        state: GameState,
        profile: inout SagaProfile
    ) -> [SagaXPEntry] {
        var granted: [SagaXPEntry] = []
        for event in events {
            switch event {
            case .gained(let flag):
                guard flag.isSpell else { break }
                if let entry = grantOncePerRun(
                    key: "kon.gained.\(flag.rawValue)",
                    amount: 40,
                    label: "Learned \(spellLabel(flag))",
                    category: .milestone,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .enteredRegion(let region):
                if let entry = grantOncePerRun(
                    key: "kon.region.\(region.rawValue)",
                    amount: 25,
                    label: "Entered \(region.title)",
                    category: .exploration,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .died:
                break

            case .won:
                if let entry = recordKonWinImpl(state: state, profile: &profile) {
                    granted.append(entry)
                }

            case .heard42:
                if let entry = grantLifetime(
                    key: "kon.heard42",
                    amount: 80,
                    label: "The meaning of life",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .caughtGoldFish:
                if let entry = grantLifetime(
                    key: "kon.goldFish",
                    amount: 80,
                    label: "Golden fish",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .tossedOrangeFish:
                break

            case .didBeachYoga:
                if let entry = grantLifetime(
                    key: "kon.yoga",
                    amount: 80,
                    label: "Crow pose on the shore",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .admittedNoIdea:
                if let entry = grantLifetime(
                    key: "kon.noidea",
                    amount: 80,
                    label: "Thanks for your honesty",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .swamDreamBridge:
                if let entry = grantLifetime(
                    key: "kon.dreamBridge",
                    amount: 80,
                    label: "Swam the dream bridge",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .heardGateGuardLore:
                if let entry = grantOncePerRun(
                    key: "kon.gateGuard",
                    amount: 60,
                    label: "Gate guard schism speech",
                    category: .choice,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .relitLanternAtPedestal:
                if let entry = grantLifetime(
                    key: "kon.alreadyLit",
                    amount: 80,
                    label: "Already lit fam",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .caughtOldShoe:
                if let entry = grantLifetime(
                    key: "kon.oldShoe",
                    amount: 80,
                    label: "Sole survivor",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .survivedFishingCrab:
                if let entry = grantLifetime(
                    key: "kon.crab",
                    amount: 80,
                    label: "Claw and order",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .provedWithEars:
                if let entry = grantLifetime(
                    key: "kon.ears",
                    amount: 80,
                    label: "Ear apparent",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }

            case .heardTradingPostGrief:
                if let entry = grantLifetime(
                    key: "kon.widower",
                    amount: 80,
                    label: "Widower's lament",
                    category: .secret,
                    product: .kon,
                    profile: &profile
                ) { granted.append(entry) }
            }
        }
        return granted
    }

    @discardableResult
    public static func recordKonDeath(cause: DeathCause, profile: inout SagaProfile) -> SagaXPEntry? {
        recordDeath(label: "Death — \(cause.title)", product: .kon, profile: &profile)
    }

    @discardableResult
    public static func recordSocDeath(profile: inout SagaProfile) -> SagaXPEntry? {
        recordDeath(label: "Death in the war", product: .soc, profile: &profile)
    }

    @discardableResult
    public static func recordSocWin(profile: inout SagaProfile) -> SagaXPEntry? {
        recordProductWin(
            key: "soc.won",
            amount: socWinXP,
            label: "Blade of Courage — victory",
            product: .soc,
            profile: &profile
        )
    }

    @discardableResult
    public static func recordAnthologyStoryComplete(
        storyKey: String,
        title: String,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        let amount = chroniclerXP(forStoryKey: storyKey)
        guard let entry = grantOncePerLifetime(
            key: "stories.\(storyKey)",
            amount: amount,
            label: "\(title) — complete",
            category: .completion,
            product: .stories,
            profile: &profile
        ) else { return nil }
        profile.incrementCompletions(.stories)
        return entry
    }

    @discardableResult
    public static func claimAchievement(
        _ achievement: Achievement,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        let key = profile.achievementClaimKey(achievement)
        guard profile.canClaimAchievement(achievement) else { return nil }
        let amount = xpForAchievement(achievement)
        profile.achievementXPClaimed.insert(key)
        return appendGrant(
            amount: amount,
            label: "Claimed — \(achievement.title)",
            category: .achievementClaim,
            product: .kon,
            profile: &profile
        )
    }

    public static func xpForAchievement(_ achievement: Achievement) -> Int {
        switch achievement {
        case .kingOfNacastrum, .cleanCoronation: return 150
        case .fullArsenal, .fullyLoaded, .worldsEnd: return 120
        case .martyr, .grimCatalog: return 100
        case .firstSteps, .armed, .firekeeper, .earthshaper: return 75
        default: return 80
        }
    }

    public static func chroniclerXP(forStoryKey storyKey: String) -> Int {
        switch storyKey {
        case "story_zero": return 120
        case "good_one", "bad_one", "elk_feast": return 150
        case "good_two", "bad_two", "cave_record": return 200
        case "good_three", "bad_three", "neutral_three": return 275
        case "good_four", "bad_four", "neutral_four",
             "good_five", "bad_five", "neutral_five": return 350
        case "good_six", "bad_six", "neutral_six": return 450
        default: return 150
        }
    }

    // MARK: - Private

    private static func spellLabel(_ flag: Flag) -> String {
        switch flag {
        case .levitate: return "Levitate"
        case .fireball: return "Inflame"
        case .stonebend: return "Stonebend"
        default: return flag.rawValue
        }
    }

    @discardableResult
    private static func recordKonWinImpl(state: GameState, profile: inout SagaProfile) -> SagaXPEntry? {
        let winKey = "kon.won"
        guard !profile.runEventKeys.contains(winKey) else { return nil }
        profile.runEventKeys.insert(winKey)

        var total = konWinXP
        var note: String?
        if state.deathCount == 0 {
            total += konCleanWinBonusXP
            note = "Clean coronation"
        }
        profile.incrementCompletions(.kon)
        return appendGrant(
            amount: total,
            label: "King of Nacastrum — victory",
            category: .completion,
            product: .kon,
            modifierNote: note,
            profile: &profile
        )
    }

    @discardableResult
    private static func recordProductWin(
        key: String,
        amount: Int,
        label: String,
        product: AvasiaProduct,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        guard !profile.runEventKeys.contains(key) else { return nil }
        profile.runEventKeys.insert(key)
        profile.incrementCompletions(product)
        return appendGrant(
            amount: amount,
            label: label,
            category: .completion,
            product: product,
            profile: &profile
        )
    }

    @discardableResult
    private static func recordDeath(
        label: String,
        product: AvasiaProduct,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        guard profile.deathXPGrantsThisRun < SagaProfile.maxDeathXPGrantsPerRun else {
            _ = appendZeroDeathNote(label: label, product: product, profile: &profile)
            return nil
        }
        profile.deathXPGrantsThisRun += 1
        let grantLabel = "\(label) (\(profile.deathXPGrantsThisRun)/\(SagaProfile.maxDeathXPGrantsPerRun))"
        return appendGrant(
            amount: SagaProfile.deathXPPerGrant,
            label: grantLabel,
            category: .death,
            product: product,
            profile: &profile
        )
    }

    @discardableResult
    private static func appendZeroDeathNote(
        label: String,
        product: AvasiaProduct,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        appendGrant(
            amount: 0,
            label: label,
            category: .death,
            product: product,
            modifierNote: "No XP — grant cap",
            profile: &profile
        )
    }

    @discardableResult
    private static func grantOncePerRun(
        key: String,
        amount: Int,
        label: String,
        category: SagaXPCategory,
        product: AvasiaProduct,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        guard !profile.runEventKeys.contains(key) else { return nil }
        profile.runEventKeys.insert(key)
        return appendGrant(
            amount: amount,
            label: label,
            category: category,
            product: product,
            profile: &profile
        )
    }

    @discardableResult
    private static func grantLifetime(
        key: String,
        amount: Int,
        label: String,
        category: SagaXPCategory,
        product: AvasiaProduct,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        grantOncePerLifetime(
            key: key,
            amount: amount,
            label: label,
            category: category,
            product: product,
            profile: &profile
        )
    }

    @discardableResult
    private static func grantOncePerLifetime(
        key: String,
        amount: Int,
        label: String,
        category: SagaXPCategory,
        product: AvasiaProduct,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        guard profile.lifetimeEvents.insert(key).inserted else { return nil }
        return appendGrant(
            amount: amount,
            label: label,
            category: category,
            product: product,
            profile: &profile
        )
    }

    @discardableResult
    private static func appendGrant(
        amount: Int,
        label: String,
        category: SagaXPCategory,
        product: AvasiaProduct,
        modifierNote: String? = nil,
        profile: inout SagaProfile
    ) -> SagaXPEntry? {
        guard amount != 0 || modifierNote != nil else { return nil }
        let entry = SagaXPEntry(
            product: product,
            runID: profile.currentRunID,
            label: label,
            amount: amount,
            modifierNote: modifierNote,
            category: category
        )
        if amount > 0 {
            profile.sagaXP += amount
            profile.currentRunXP += amount
        }
        profile.ledger.append(entry)
        if profile.ledger.count > SagaProfile.ledgerCap {
            profile.ledger.removeFirst(profile.ledger.count - SagaProfile.ledgerCap)
        }
        return entry
    }
}
