# Room Spec Standard — Anthology

Same schema as [`../sequel/ROOM_SPEC_STANDARD.md`](../sequel/ROOM_SPEC_STANDARD.md),
adapted for anthology content (no Python source).

---

## File naming

| Pattern | Example |
|---|---|
| `rooms/<anthology-room-id>.md` | `rooms/scout-ridge.md` |
| Index | [`rooms/README.md`](rooms/README.md) |

`anthology-room-id` matches `AnthologyRoomID` in
`Sources/AvasiaAnthologyEngine/Model/AnthologyRoomID.swift`.

---

## Required sections

Use the sequel skeleton. Replace **Python** fields with:

| Field | Value |
|---|---|
| **Swift `AnthologyRoomID`** | … |
| **Story ID** | `storyZero` \| `goodOne` \| … |
| **Display name** | … |
| **Room type** | `link` \| `logic` |
| **Critical path** | yes \| optional |
| **iOS port** | ✅ \| ⬜ \| partial |
| **Source** | `AnthologyWorld.swift` · room struct name |

Include a **Prose (canonical)** subsection with the exact lines players should see
when the room is authored.

---

## Design intent

Mark future writing not yet in Swift:

```markdown
## Design intent (not in source)
…
```
