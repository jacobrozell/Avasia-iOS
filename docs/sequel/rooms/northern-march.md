# Northern March

> Act IV travel corridor with one patrol encounter (iOS authored, 2026-06-15).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `northernMarch` |
| **Python `current_room_id`** | — |
| **Display name** | Northern March |
| **Room type** | logic |
| **Act** | IV |
| **Region** | `aylova` |
| **Critical path** | **yes** |
| **iOS port** | ✅ authored |
| **Source file** | — · `SoCNorthernMarchRoom.swift` |

## Story & purpose

Connect Aylova camp to Oceandale front. Refugee column + single skirmisher fight
(authored encounter, not a grind corridor).

## Combat

| Enemy | ATK | SPD | HP | Luck |
|---|---|---|---|---|
| Agromanian Skirmisher | 7 | 7 | 16 | 0 |

## State flags

| Flag | When |
|---|---|
| `northernMarchPhase` | Scene machine |
| `northernMarchCleared` | After patrol victory |

## Player options

| Input | Outcome |
|---|---|
| `CONTINUE` | Refugees → ambush → aftermath → front |
| `SCOUT` / `STEALTH` | Scout class: skip patrol (`scoutShortcut`) |
| `ATTACK` | Combat during patrol |

## Navigation

→ `oceandaleFront` after march cleared

## Related

[`aylova-war-camp.md`](aylova-war-camp.md) · [`oceandale-front.md`](oceandale-front.md)
