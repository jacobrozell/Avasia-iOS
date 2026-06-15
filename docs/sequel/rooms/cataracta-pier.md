# Doran's Pier

> Pay-or-referral gate into fishing minigame.

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `cataractaPier` |
| **Python `current_room_id`** | `Cataracta_Pier` |
| **Display name** | Doran's Pier |
| **Room type** | logic |
| **Act** | I |
| **Region** | `cataracta` |
| **Critical path** | optional |
| **iOS port** | ✅ ported |
| **Source file** | `Avasia-SoC/Cataracta/Cataracta_Pier.py` |

## Story & purpose

Gruff fisherman protects his pier; fishing is optional side content and trophies.

## Characters

| Name | Role | Appears when | Notes |
|---|---|---|---|
| **Doran** | Pier owner | On enter | Rough voice; brother of Ulric |

### First meeting (`config.doran == False`)

- "Oi! Whatya be doin' in my hut?"
- Player explains curiosity.
- Offers pier access for **15 gold** (rod + bait) — see quirks.

### Return (`config.doran == True`)

- "Welcome back! You here to fish or just stand there?"

## Prerequisites

| Path | Requirement |
|---|---|
| Paid fishing | 15 gold *(dead code — see quirks)* |
| Free fishing | `config.ulric == True` (Ulric referral) |

## State flags

| Flag | On enter | On success | Cleared by |
|---|---|---|---|
| `doran` | read | set `True` on first greeting | — |
| `ulric` | read | set `False` on free-fish path | — |

## Navigation

| Exit / trigger | Destination | Condition |
|---|---|---|
| `YES` + free path | `cataractaFishing` | `ulric == True` |
| `YES` + paid path | `cataractaFishing` | *unreachable in source* |
| `NO`, `LEAVE` | `cataractaShopping` | leave dialogue |

## Player options

| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|
| `YES` | raw-ish | `ulric` and `doran` both false | Pay 15g → fishing *(dead)* |
| `YES` | — | `ulric == True` | Free rod; trophy `brother`; → fishing |
| `NO`, `LEAVE` | — | — | Insult + return shopping |
| other | — | — | "Simple yes or no, boy." |

Loop prompt: **"What do ye say? 15 gold?"** even on free path.

## Items

| Item | Action | Cost | Effect |
|---|---|---|---|
| Old fishing rod + bait | borrow | 0 or 15g | Enables fishing room |

## Combat

None.

## Trophies & XP

| Reward | Trigger |
|---|---|
| `brother` — Brotherly Love | Free path via Ulric |

## Parser & commands

Input loop inside `on_enter`; uppercase substring match.

## iOS implementation

| Swift type | Path | Gap vs source |
|---|---|---|
| `SoCCataractaPier` | `SoCActIRooms.swift` | — |

## Source quirks

**Dead code:** First greeting sets `doran = True` before the YES branch, so
`ulric is False and doran is False` is never true — **15 gold path never runs**.
Live paths: Ulric referral (free) or NO → leave.

## Related rooms

[Ulric](cataracta-blacksmith.md), [Fishing](cataracta-fishing.md), [Shopping](cataracta-shopping.md).
