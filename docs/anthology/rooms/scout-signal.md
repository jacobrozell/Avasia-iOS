# Scout Signal — Splitpath smoke

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `scoutSignal` |
| **Story ID** | `storyZero` |
| **Display name** | Splitpath Signal |
| **Room type** | logic |
| **Critical path** | optional |
| **Region** | `mountain` |
| **iOS port** | ✅ authored |

## Story & purpose

Optional green signal fire for Silvarium riders. Sets `scoutSignalSent` when used.
Routes to `scoutFork` (REPORT / REFUSE only — no FOLLOW).

## Player options

| Input | Outcome |
|---|---|
| `SIGNAL` / `FIRE` | Green smoke; `scoutSignalSent = true` |
| `CONTINUE` | → `scoutFork` |

## Related

[Scout withdraw](scout-withdraw.md) · [Scout fork](scout-fork.md)
