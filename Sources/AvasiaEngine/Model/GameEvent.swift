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
}
