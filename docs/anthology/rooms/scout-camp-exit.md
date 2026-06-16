# Scout Camp Exit — Post-fork release

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `scoutCampExit` |
| **Story ID** | `storyZero` |
| **Display name** | (alignment-specific) |
| **Room type** | logic |
| **Critical path** | **yes** |
| **Region** | `mountain` |
| **iOS port** | ✅ authored |

## Story & purpose

Alignment-specific exit beat after fork resolves. Fixes off-screen teleport to Splitpath.

| Alignment | Beat |
|---|---|
| `loyalist` + captured | Vashirr releases reporters to treeline |
| `loyalist` + withdrew | Bark tallies, optional green smoke |
| `agroman` | Column edge; Mira gone (`miraStatus = brokeAway`) |
| `neutral` + captured | Vashirr: *Let them go* |
| `neutral` + withdrew | Splitpath alone |

## Player options

| Input | Outcome |
|---|---|
| `CONTINUE` | → `scoutEpilogue` |

## Related

[Scout fork](scout-fork.md) · [Scout epilogue](scout-epilogue.md)
