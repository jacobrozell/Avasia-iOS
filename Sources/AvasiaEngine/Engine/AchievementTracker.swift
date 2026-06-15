import Foundation

/// Pure evaluator: folds a turn's `GameEvent`s into persistent
/// `AchievementState`, returning the achievements newly unlocked this turn (for
/// toast UI). Criteria for every `Achievement` live here so the catalog
/// (`Achievement`) stays presentation-only. See docs/ACHIEVEMENTS.md.
public enum AchievementTracker {
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
                default: break
                }
                if state.has(.levitate) && state.has(.fireball) && state.has(.stonebend) {
                    unlock(.fullArsenal)
                }

            case .enteredRegion(let region):
                progress.regionsVisited.insert(region)
                if progress.regionsVisited.count >= 8 { unlock(.wanderer) }
                if progress.regionsVisited.count >= Region.allCases.count { unlock(.worldsEnd) }

            case .died(let cause):
                progress.totalDeaths += 1
                unlock(.firstBlood)
                if progress.totalDeaths >= 10 { unlock(.martyr) }
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

            case .heard42:
                unlock(.meaningOfLife)

            case .caughtGoldFish:
                unlock(.goldRush)

            case .tossedOrangeFish:
                progress.orangeFishTossed += 1
                if progress.orangeFishTossed >= 3 { unlock(.persistentAngler) }
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
