import Foundation

/// Pure evaluator: folds a turn's `GameEvent`s into persistent
/// `AchievementState`, returning the achievements newly unlocked this turn (for
/// toast UI). Criteria for every `Achievement` live here so the catalog
/// (`Achievement`) stays presentation-only. See docs/ACHIEVEMENTS.md.
public enum AchievementTracker {
    private static let kitFlags: [Flag] = [
        .levitate, .fireball, .stonebend, .sword, .lantern, .dagger, .rod
    ]

    private static func unlockFullyLoadedIfReady(_ state: GameState, unlock: (Achievement) -> Void) {
        guard kitFlags.allSatisfy({ state.has($0) }) else { return }
        unlock(.fullyLoaded)
    }

    @discardableResult
    public static func apply(_ events: [GameEvent],
                             state: GameState,
                             into progress: inout AchievementState) -> [Achievement] {
        var newly: [Achievement] = []
        func unlock(_ a: Achievement) {
            if progress.unlocked.insert(a).inserted { newly.append(a) }
        }

        for event in events {
            switch event {
            case .gained(let flag):
                switch flag {
                case .levitate:  unlock(.firstSteps)
                case .sword:     unlock(.armed)
                case .fireball:  unlock(.firekeeper)
                case .stonebend: unlock(.earthshaper)
                case .lantern:   unlock(.druidFriend)
                case .rod:       unlock(.goneFishin)
                default: break
                }
                if state.has(.levitate) && state.has(.fireball) && state.has(.stonebend) {
                    unlock(.fullArsenal)
                }
                unlockFullyLoadedIfReady(state, unlock: unlock)

            case .enteredRegion(let region):
                progress.regionsVisited.insert(region)
                if progress.regionsVisited.count >= 8 { unlock(.wanderer) }
                if progress.regionsVisited.isSuperset(of: Region.konPlayable) { unlock(.worldsEnd) }

            case .died(let cause):
                progress.totalDeaths += 1
                unlock(.firstBlood)
                if progress.totalDeaths >= 10 { unlock(.martyr) }
                if cause != .generic {
                    progress.deathCausesExperienced.insert(cause)
                    if progress.deathCausesExperienced.isSuperset(of: DeathCause.konAchievable) {
                        unlock(.grimCatalog)
                    }
                }
                switch cause {
                case .chasm:      unlock(.intoTheDeep)
                case .crab:       unlock(.crabDinner)
                case .seaSerpent: unlock(.swallowedWhole)
                case .stalactite: unlock(.pointedEnd)
                case .mining:     unlock(.tooGreedy)
                case .neckCut:    unlock(.theWrongCut)
                case .ambush:     unlock(.ambushed)
                case .fireball:   unlock(.burnedToAsh)
                case .generic:    break
                }

            case .won:
                unlock(.kingOfNacastrum)
                if state.deathCount == 0 { unlock(.cleanCoronation) }

            case .heard42:
                unlock(.meaningOfLife)

            case .caughtGoldFish:
                unlock(.goldRush)

            case .tossedOrangeFish:
                progress.orangeFishTossed += 1
                if progress.orangeFishTossed >= 3 { unlock(.persistentAngler) }

            case .didBeachYoga:
                unlock(.crowPose)

            case .admittedNoIdea:
                unlock(.thanksForHonesty)

            case .swamDreamBridge:
                unlock(.againstInstinct)

            case .heardGateGuardLore:
                unlock(.schismScholar)

            case .relitLanternAtPedestal:
                unlock(.alreadyLitFam)

            case .caughtOldShoe:
                unlock(.soleSurvivor)

            case .survivedFishingCrab:
                unlock(.clawAndOrder)

            case .provedWithEars:
                unlock(.earApparent)

            case .heardTradingPostGrief:
                unlock(.widowersLament)
            }
        }
        return newly
    }

    /// Record simply being in a region (e.g. the starting room on a new game),
    /// since `enteredRegion` events only fire on movement.
    @discardableResult
    public static func recordRegion(_ region: Region, into progress: inout AchievementState) -> [Achievement] {
        apply([.enteredRegion(region)], state: GameState(), into: &progress)
    }
}
