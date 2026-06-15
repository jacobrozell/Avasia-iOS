# Oceandale Ridge

> Act IV battle set piece — two-wave assault (iOS authored, 2026-06-15).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `oceandaleFront` |
| **Display name** | Oceandale Ridge |
| **Room type** | logic |
| **Act** | IV |
| **Region** | `oceandale` |
| **Critical path** | **yes** |
| **iOS port** | ✅ authored |

## Story & purpose

Coalition assault on the ridge overlooking KoN's Oceandale. **Paladin** fire shows Vashirr's teaching.
Class-colored charge narrative; two authored fights.

## Combat

| Wave | Enemy | ATK | SPD | HP |
|---|---|---|---|---|
| 1 | Agromanian Raider | 6 | 6 | 14 |
| 2 | Agromanian Paladin | 9 | 5 | 22 |

Full heal between waves. +25 quest XP and `oceandaleVictor` trophy on clear.

## State flags

| Flag | When |
|---|---|
| `oceandaleFrontPhase` | Scene machine |
| `oceandaleFrontCleared` | Ridge secured |

## Navigation

`ADVANCE` → `mageOutpost`

## Related

[`northern-march.md`](northern-march.md) · [`mage-outpost.md`](mage-outpost.md)
