# Fishing (Varatho Pier)

> RNG fishing minigame; food, junk, gold purses.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaFishing` |
| **Python `current_room_id`** | `Cataracta_Fishing` |
| **Display name** | Fishing |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Fishing.py` |

## Story & purpose

Optional resource / trophy content. Reinforces Varatho river danger (Doran's warning).

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| Doran | *(off-screen)* | Exit | Return rod when done |

## Prerequisites

Rod from [Doran's Pier](cataracta-pier.md).

## State flags

None persisted (bait is local variable).

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `NO` to cast | `cataractaShopping` | quit early |
| bait == 0 | `cataractaShopping` | out of bait |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `YES`, `Y` | — | bait &gt; 0 | RNG catch; bait -= 1 |
| `NO`, `N` | — | — | Return rod; → shopping |

### RNG table (`randint(1, 10)` per cast)

| Roll | First time | Repeat same type |
|---|---|---|
| 1 | Old-shoe (junk) | "Whole lot of nothing..." |
| 2 | Small Fish (5 HP) | nothing |
| 3–5 | Soggy-Money Purse (+1–20 gold) | — |
| 6 | Big Fish (10 HP) | nothing |
| 7 | Crab (15 HP) | nothing |
| 8–10 | Seaweed (throw back) | — |

**Bait:** `randint(4, 7)` casts per session.

## Items

| Item | Type | Effect |
|---|---|---|
| Old-shoe | junk | value 2 |
| Small Fish | food | +5 HP |
| Big Fish | food | +10 HP |
| Crab | food | +15 HP |
| Gold purse | — | +1–20 gold |

## Combat

None.

## Trophies & XP

| Reward | Trigger |
|---|---|
| `fished` — Gone Fishin' | Bait reaches 0 |

## Parser & commands

Prompt: "Throw your cast in the water?"

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaFishing` | `SoCActIRooms.swift` | Inventory display in UI TBD |

## Source quirks

Duplicate-catch branches (`item == 1 and oldshoe`) are unreachable in same cast
logic — first catch sets flag but same roll can't repeat in one iteration.

## Related rooms

[Pier](cataracta-pier.md).
