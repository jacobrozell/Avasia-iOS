# Scout Epilogue — Story #0 close

## Metadata

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | `scoutEpilogue` |
| **Story ID** | `storyZero` |
| **Display name** | The Road Out |
| **Room type** | logic |
| **Critical path** | **yes** |
| **Region** | `splitpath` |
| **iOS port** | ✅ authored |

## Story & purpose

Short closing beat keyed to `alignment` and `ridgeOutcome`. Sets `storyZeroComplete = true`.
Routes to `storyHub` with alignment-specific next-story hint.

## Epilogue variants

| Alignment | Beat |
|---|---|
| `loyalist` | Splitpath; Oceandale ships foreshadowed |
| `loyalist` + withdrew | Signal / orders-kept variants |
| `agroman` | Column dust; Mira absent |
| `neutral` | Splitpath at dusk; Elk foreshadow |

## Player options

| Input | Outcome |
|---|---|
| `CONTINUE` | +500 FP; → `storyHub` |

## Related

[Scout camp exit](scout-camp-exit.md) · [Good #1 spec](../stories/STORY_GOOD_ONE.md)
