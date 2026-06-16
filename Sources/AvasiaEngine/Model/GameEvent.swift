import Foundation

/// Semantic events produced by a turn, consumed by the achievement tracker (and
/// usable for analytics/telemetry later). Most are derived automatically by
/// `GameEngine` (flag diffs + transition); a few "flavor" events are emitted
/// explicitly by rooms via `TurnResult.events`.
public enum GameEvent: Sendable, Equatable {
    case gained(Flag)             // a spell or item was obtained
    case enteredRegion(Region)    // moved into a new region
    case died(DeathCause)         // a lethal turn
    case won                      // reached the canonical ending
    case heard42                  // the priestess's meaning-of-life answer
    case caughtGoldFish           // the golden fish (fishing roll 2)
    case tossedOrangeFish         // threw back a useless orange fish
    case didBeachYoga             // stretch or yoga on the shore
    case admittedNoIdea           // NOIDEA at the fireball pedestal
    case swamDreamBridge          // swim/jump through the memory bridge
    case heardGateGuardLore       // full schism speech at the north gate
    case relitLanternAtPedestal   // already lit fam
    case caughtOldShoe            // fishing roll 7-9
    case survivedFishingCrab      // fishing roll 3, lived
    case provedWithEars           // druid gate, ears not spells
    case heardTradingPostGrief    // merchant's wife
}
