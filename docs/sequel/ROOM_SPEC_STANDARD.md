# Room Spec Standard — Blade of Courage

Every playable location in *Avasia: Blade of Courage* has a **room spec** under
[`rooms/`](rooms/). Specs are **source-first**: content comes from
`Avasia-SoC/` unless a field is explicitly marked **Design intent** (future writing,
not in the prototype).

Use this schema when adding rooms, porting to iOS, or authoring new scenes later.

---

## File naming

| Pattern | Example |
|---|---|
| `rooms/<swift-room-id>.md` | `rooms/cataracta-athalos.md` |
| Index | [`rooms/README.md`](rooms/README.md) |
| Global systems | [`rooms/_global.md`](rooms/_global.md) |

`swift-room-id` matches `SoCRoomID` in `Sources/AvasiaSoCEngine/Model/SoCRoomID.swift`.

---

## Required sections (in order)

Copy this skeleton into every room file:

```markdown
# [Display name]

> One-line purpose.

## Metadata
| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | … |
| **Python `current_room_id`** | … |
| **Display name** | … |
| **Room type** | `link` \| `logic` |
| **Act** | I \| II \| III |
| **Region** | `cataracta` \| `nacastrum` |
| **Critical path** | yes \| optional \| dead-end |
| **iOS port** | ✅ ported \| ⬜ stub \| partial |
| **Source file** | `Avasia-SoC/…` |

## Story & purpose
Narrative role, emotional beat, placement in arc.

## Characters
| Name | Role | Appears when | Notes |
|---|---|---|---|

## Prerequisites
Flags, items, gold, class, or prior rooms required to enter or succeed.

## State flags
| Flag (`SoCGameState` / `config`) | On enter | On success | Cleared by |
|---|---|---|---|

## Navigation
| Exit / trigger | Destination | Condition |
|---|---|---|

## Player options
| Input (triggers) | Parser mode | Condition | Outcome |
|---|---|---|---|

## Items
| Item | Action | Cost | Effect |
|---|---|---|---|

## Combat
Enemy stats, death text, heals between fights — or *None*.

## Trophies & XP
| Reward | Trigger |
|---|---|

## Parser & commands
`normalized` vs `raw`. Room-specific invalid-command text.

## iOS implementation
| Swift type | Path | Gap vs source |
|---|---|---|

## Source quirks
Bugs, dead code, typos, unwired graph edges — faithful notes for porters.

## Related rooms
Quest chains, hub links, set-piece doc cross-ref.
```

---

## Field definitions

### Room type

| Type | Python pattern | Swift pattern |
|---|---|---|
| **link** | `Room` with `des` + `directions`, `on_enter=None` | `handle` only moves; `describe` is static |
| **logic** | `on_enter` function; may `return "go back"` / `"reload"` | `handle` runs scene; may `autoReturnAfterEnter` |

### Critical path

- **yes** — required to finish the prototype story spine.
- **optional** — side content before or after Act II.
- **dead-end** — source ends here (e.g. throne stub).

### Player options table

List **substring triggers** as in Python `containsAny` / Swift `ParsedInput.contains`.
Include synonyms on one row. Note **silent** outcomes (no text).

### State flags

Map Python `config.*` to Swift `SoCGameState` (see [`CONTENT_MANIFEST.md`](CONTENT_MANIFEST.md)).
Only document flags this room reads or writes.

### Design intent blocks

When future writing is discussed but **not in source**, use a subsection:

```markdown
## Design intent (not in source)
…
```

Never mix design intent into **Player options** or **Items** without a label.

---

## Global systems (not per-room)

Documented in [`rooms/_global.md`](rooms/_global.md):

- New-game intro, name entry, starting gold/items
- Global commands (`SAVE`, `EAT`, `INVENTORY`, `TROPHY`, …)
- Class stats (Wolf / Bear / Fox)
- Combat loop (`ATTACK`, `HELP`; `HEAL` commented out in source)
- Trophy catalog

---

## Index maintenance

When a room is ported or authored:

1. Update **iOS port** in its spec.
2. Update the status column in [`rooms/README.md`](rooms/README.md).
3. Update [`WORLD_MAP.md`](WORLD_MAP.md) only if the graph changes.

---

## Machine-friendly summary (optional)

For tooling later, each spec's **Metadata** table is the canonical row. A future
script can scrape `| **Swift SoCRoomID** |` and `| **iOS port** |` from every file.
