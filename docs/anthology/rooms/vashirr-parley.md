# Vashirr Parley — Many Hands sermon

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `vashirrParley` |
| **Story ID** | `storyZero` |
| **Display name** | Vashirr's Camp |
| **Room type** | logic |
| **Critical path** | **yes** |
| **Region** | `mountain` |
| **iOS port** | ✅ authored |
| **Source** | `StoryZeroVashirrParleyRoom.swift` |

## Story & purpose

**Vashirr** addresses scouts directly — sincere ideology, not cartoon evil.
Phased sermon: schism fable → Many Hands doctrine → offer to walk away or listen
further. See [`../../VASHIRR.md`](../../VASHIRR.md).

## Characters

| Name | Role |
|---|---|
| **Vashirr** | Agroman leader; believes in ending schism by force |
| **Mira** | Silent; horrified |

## State flags

| Flag | Phases |
|---|---|
| `parleyPhase` | `arrival` → `schism` → `doctrine` → `offer` → `done` |

## Player options

| Input | Phase | Outcome |
|---|---|---|
| `CONTINUE` / `LISTEN` | each | Advance phase |
| `TALK` | any | Extra Vashirr line (ideology) |
| `CONTINUE` | `done` | → `scoutFork` |

## Prose beats (canonical)

1. **Arrival:** Disarmed but fed; Vashirr reads Sylvian kit + bark-strip cipher.
2. **Schism:** Two hands of one body — mages hoarded, kingdoms starved.
3. **Doctrine:** Train every soldier; end the schism; Kaefden's court is the obstacle.
4. **Offer:** Report truth or follow and learn — choice deferred to fork room.

## Related

[`../../VASHIRR.md`](../../VASHIRR.md) · [Scout fork](scout-fork.md)
