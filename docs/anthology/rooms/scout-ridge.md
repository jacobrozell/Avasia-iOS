# Scout Ridge — Army sighting

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `scoutRidge` |
| **Story ID** | `storyZero` |
| **Display name** | Ridge Overlook |
| **Room type** | logic |
| **Critical path** | **yes** |
| **Region** | `mountain` |
| **iOS port** | ✅ authored |
| **Source** | `StoryZeroScoutRidgeRoom.swift` |

## Story & purpose

PC and Mira see **Agroman campfires** in the valley — too many for a raid.
Many Hands banners. Mira wants to withdraw and report; movement below suggests
they have already been seen.

## Player options

| Input | Outcome |
|---|---|
| `LOOK` | Valley army, Paladin pairs, Nacastrum + Agroman banners |
| `TALK` / `MIRA` | Report vs. stay debate |
| `WITHDRAW` / `NORTH` / `RUN` | → `scoutWithdraw` |
| `CONTINUE` / `DOWN` | → `scoutPicket` (captured path) |

## Prose (canonical)

Valley holds **hundreds of fires**. Many Hands banners mix with **Nacastrum blue**.
Pamphlet scraps mention *Many Hands* and *magic for every soldier*.

## Related

[Patrol camp](scout-patrol-camp.md) · [Scout withdraw](scout-withdraw.md) · [Picket](scout-picket.md)
