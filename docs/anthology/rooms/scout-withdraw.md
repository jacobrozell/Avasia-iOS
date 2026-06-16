# Scout Withdraw — Ridge retreat

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `scoutWithdraw` |
| **Story ID** | `storyZero` |
| **Display name** | Ridge Retreat |
| **Room type** | logic |
| **Critical path** | optional |
| **Region** | `mountain` |
| **iOS port** | ✅ authored |

## Story & purpose

PC and Mira pull back after `WITHDRAW` on the ridge. Sets `ridgeOutcome = withdrew`.
Skips capture and full Vashirr sermon.

## Player options

| Input | Outcome |
|---|---|
| `TALK` / `MIRA` | Orders-kept beat |
| `CONTINUE` | → `scoutSignal` |

## Related

[Scout ridge](scout-ridge.md) · [Scout signal](scout-signal.md)
