# Avasia: King of Nacastrum — Engine Specification

> Specification for the iOS remake's text-adventure engine. It first documents
> **how the original game works** (`Avasia-KoN/GameDriver.py`, v. 4/3/17), then
> defines the **target architecture** for a faithful Swift/SwiftUI port.
>
> Design goal for this phase: **be as faithful to the original as possible.**
> Reproduce its content, pacing, parsing behavior, and progression exactly —
> including its deliberate jokes — while replacing the original's recursive,
> hardcoded structure with a clean, data-driven engine that is testable and
> extensible.
>
> Companion docs: `STORY.md` (narrative bible), `WORLD_MAP.md` (room graph).

---

## Part A — How the Original Works

The original is a single 4,274-line Python console program. There is no class
structure, no save system, and no data files: every location is a **function**,
all progress lives in **module-level global flags**, and all text is hardcoded
in `print()` statements.

### A.1 Control flow

- **Entry point:** the last line of the file, `textspeed()`.
- **Flow:** `textspeed()` (title + speed choice) → `intro()` (lore + state
  init) → `oceandale()` (first room) → … the world …
- **Rooms are functions; navigation is a function call.** "Going back" is
  *another call*, not a `return`. The original never unwinds — it runs on an
  ever-deepening recursive call stack. **The remake must NOT copy this**; model
  rooms as states/screens (see Part B).

### A.2 Helper functions (behavior to reproduce)

**`wait(time_multiplier=1)`** — the "delay between sentences" feature.
- Global `time` is `"ON"` (8 s base delay) or `"OFF"` (0 s). Multipliers seen in
  calls range from `.125` to `3`, so real pauses span ~1 s to ~24 s.
- If `time` is anything else, returns `False` without sleeping — used as a
  validity gate by `textspeed()` (`wait(0)`).

**`userinput(message)`** — normalizing reader. Uppercases input, then
`replace("USE","")`, `replace("CAST","")`, `replace(" ","")`. So
`"CAST LEVITATE"` → `"LEVITATE"`, `"GO NORTH"` → `"GONORTH"`. Empty stays empty.
- **Faithful quirk:** "USE"/"CAST" are stripped as *substrings*, mangling any
  word containing them (e.g. "BECAUSE" → "BECA").

**`containsAny(string, options)`** — returns `True` if any option is a
case-insensitive **substring** of the input. This is the core verb/direction
parser. Single-letter options therefore match broadly; the original mostly uses
full words to avoid false hits.

**`textspeed()`** — title screen + speed selection, and the **death/restart and
post-credits entry point**. Validates the speed answer via `wait(0)`, then calls
a fresh `intro()`.

**`intro()`** — prints the opening lore, **zeroes every global flag**, builds and
**shuffles** the `symbols` list, and calls `oceandale()`. Doubles as "new game".

**`decodesymbols(Array)`** — the fireball-puzzle answer generator: joins the
shuffled `symbols`, strips apostrophes, maps `^→1, ~→2, >→3, ;→4`.

### A.3 Per-room loop pattern

Each room: print description → `while True:` → read input → define local synonym
lists → dispatch via `containsAny` → call the target room (sometimes without
`break`). Invalid input reprints a hint or re-enters the room.

**Faithful quirk — mixed input handling:** most rooms use `userinput()`, but
several use raw `input()` + `.upper()` *without* stripping (notably the cave hub
`mcave`, the trading post, `bridge`, and yes/no & "cast again?" prompts). The
remake should reproduce per-room acceptance behavior (see §B.4).

---

## A.4 Global State / Flags (the complete progression model)

All flags are integers (0/1 unless noted), initialized in `intro()`. This table
is the authoritative save/progression model for the remake.

| Flag | Init | Meaning · set by · what it gates |
|---|---|---|
| `time` | — | "ON"/"OFF" text-delay setting (set in title screen). |
| `lev` | 0 | **Levitate** owned. Set in `magehouse` (Old Mage gift). Gates the bridge→mountain, cave net section, druid gate, dream bridge. |
| `sword` | 0 | **Long Sword** owned. Set in `graveyard`. Gates cutting forest grass, ambush options, crab kill. |
| `lant` | 0 | **Lantern** owned. Set in `druidtalk` (Dentros). Required to enter the dark cave. |
| `druid` | 0 | Met Dentros. Set in `druidtalk`; gates repeat dialogue. |
| `fireball` | 0 | **Inflame** owned. Set in `fireballroom` (symbol puzzle). Gates the ambush, crab kill, narration variants. |
| `slipp` | 0 | **Dead flag** (never read/written). Keep for fidelity; no effect. |
| `ndoor` | 0 | North-cave stone gate opened. Set in `ncave`. |
| `grass` | 0 | Forest grass cut. Set in `forestgrass`. |
| `forestlore` | 0 | Heard the Silvarium intro. Set in `mforest`; gates long vs. short version. |
| `dagger` | 0 | **Suformin's Dagger** owned. Set in `treebutcher`. Required for the blood seal. |
| `armory` | 0 | Visited tree armory. Set in `treearmory`; repeat-dialogue only. |
| `blood` | 0 | Blood seal opened. **Never set in original** (dead shortcut); seal puzzle always re-runs. |
| `geo` | 0 | **Stonebend** owned. Set in `bloodsealspell`. Gates the road stone spires, druid-gate option. |
| `guesses` | 3 | Fireball-puzzle attempts. Decrement on wrong guess; 0 → death. Only reset by `intro()`. |
| `tunnel` | 0 | **Dead flag.** |
| `roadfir` | 0 | Ambush progress: 0 not started, 1 cornered (now lethal), 2 defeated (needs Inflame). |
| `roadgeo` | 0 | Road stone spires cleared. **Never set in original** (masked by call chaining). |
| `roadlev` | 0 | Road dream bridge passed. **Never set in original** (masked by call chaining). |
| `rod` | 0 | **Fishing Rod** owned. Set in `beachhut`. Gates fishing. |
| `deathcount` | 0 | Incremented on each death; never displayed (reset by intro). Surface it on iOS if desired. |
| `lady` | 0 | Teleporter first visit done. Set in `teleporter` (also flips `lock=0`). |
| `escort` | 0 | Old Mage accompanying (endgame). Set in `magehouse`. Switches hubs to escort-only versions. |
| `orange` | 0 | Count of "orange fish" thrown back; drives the sea-serpent death. |
| `lock` | 0 | Magehouse locked after first visit; reopened by `teleporter`. |
| `cgates` | 0 | Druid (Cataracta) gate encounter done. Set in `druidpath`. |
| `tran` | 0 | **Dead flag.** |
| `symbols` | `["^'","~'",">'",";'"]` shuffled | The randomized 4-symbol sequence; the fireball-room answer. |

**Critical-path spell gating:** `lev` opens the mountain/cave/forest; `fireball`
(cave) and `geo` (forest) are then required by the road to Nacastrum —
`fireball` (ambush) → `geo` (stone spires) → `lev` (dream bridge).

**Dead flags to preserve cosmetically (no logic):** `slipp`, `tunnel`, `tran`,
`solution`, `blood`, `roadgeo`, `roadlev`. For a clean port, drive the road
sequence with a single progress integer instead of the unused road flags.

---

## A.5 Items, Spells, Combat, Puzzles (faithful rules)

### Items (each a 0/1 flag — no inventory object)
1. **Long Sword** (`sword`) — graveyard corpse (LOOK then TAKE/GRAB/GET).
2. **Lantern** (`lant`) — gift from Dentros; required to enter the cave.
3. **Suformin's Dagger** (`dagger`) — butcher's chest (TALK then EXPLAIN); only
   tool that opens the blood seal.
4. **Fishing Rod** (`rod`) — beside the shoreside hut; enables fishing.
5. **Pickaxe** — NW cave; taking + mining = instant death; not persistent.
6. **The Staff** — narrative item the Old Mage carries in escort mode.
7. **Father's pendant** — narrative-only, in the ending.

### Spells (`lev`, `fireball`, `geo`)
- No MP/cooldown. "Casting" = typing the spell name (CAST is stripped).
- Cast-name lists: Levitate `["LEVITATE","LEV"]`, Inflame `["INFLAME","IN-FLAME"]`,
  Stonebend `["STONEBEND","STONE-BEND"]`.
- Each use site checks the ownership flag; if unowned → "You don't know that
  spell." Many misuse sites have jokey rejections — preserve them.

### Combat (scripted, no stats)
The only combat is the **Western Road Agromanian ambush**, staged via `roadfir`:
- `roadfir==0`: every choice (sword/dagger/levitate/stonebend/run) just advances
  to `roadfir==1` (cornered); **only Inflame** wins → `roadfir==2`.
- `roadfir==1`: every option **except Inflame** = death.
- `roadfir==2`: ambush over.
- No HP/rolls. Randomness (`randint(2,12)`) is used **only** in fishing.

### Death & restart
Every lethal branch prints a red "You have died.", `deathcount += 1`, then
`textspeed()` → fresh `intro()` → **full restart from the beach** (state wiped,
`symbols` re-shuffled). No checkpoints, no respawn-in-place. **The remake should
keep "death = restart" semantics but SHOULD add checkpointing/persistence (see
§B.6) — this is the one allowed deviation, because permadeath-to-title is a
usability problem on mobile.**

### Puzzles (exact solutions)
- **A. Bridge** — Jump/Swim/Dive = death; **Levitate** crosses (needs `lev`).
- **B. Magehouse faction Q** — answer must contain `KAEFDEN`.
- **C. North-cave gate** — three buttons `%'`,`)*`,`<~`; PUSH then **1 / `%'`**
  opens it (`ndoor=1`).
- **D. Symbols puzzle (central)** — the four glyphs are revealed in different
  cave rooms by slot:
  - `ecave` → `symbols[3]` (the final symbol)
  - `wcavefork` LEFT → `symbols[0]` (repeats at the start)
  - `nwcavecontinue` → `symbols[1]` (second of four)
  - `necavecage` (Levitate up) → `symbols[2]` (third symbol)
  Answer = `decodesymbols(symbols)`: read the four glyphs in slot order and
  convert via the **fixed** legend `^=1, ~=2, >=3, ;=4`. Wrong → `guesses-1`;
  0 → death. (`"NO IDEA"` → joke line.)
- **E. Druid gate** — prove you're a mage: **EAR/EARS**, **Levitate**, or
  **Stonebend** (Inflame rejected). Sets `cgates=1`.
- **F. Forest grass** — **cut with Sword**; then `ftrap` (if `lev`) or
  `ftrapnolev`. Inflame/Levitate refused.
- **G. Blood seal (tree floor 4)** — CUT + blade + body part. **NECK = death**
  (with confirm); **Sword = nothing** (wrong blade); **Dagger on hand/leg** →
  opens seal → learn **Stonebend** (`geo=1`).
- **H. Road stone spires** — only **Stonebend** breaks them.
- **I. Dream bridge** — inversion of the real bridge: **Swim/Jump/Dive**
  reveals Nacastrum → `teleporter` (Levitate just loops you back).
- **J. Teleporter** — 1st visit (`lady=0`): can't solve alone → `lady=1,
  lock=0`, go fetch the Old Mage. 2nd visit (escort): Mage uses staff → memory
  flashback → `nacastrum`.

### Fishing minigame (`randint(2,12)`)
2 = gold fish · 3 = crab (death unless sword/fireball) · 4–6 = nothing ·
7–9 = old shoe · 10–11 = fish · 12 = orange fish (`orange++`), but once
`orange>=4` the roll-12 becomes the **sea-serpent death**. Consolidate the two
duplicate implementations into one parameterized minigame.

---

## Part B — Target iOS Architecture

Faithful **content and behavior**, modern **structure**. Replace recursion +
globals with a data-driven state machine. Recommended stack: **Swift + SwiftUI**,
no third-party deps required.

### B.1 Layered design

```
┌─────────────────────────────────────────────┐
│ Presentation (SwiftUI)                        │
│  - TranscriptView (scrolling styled text)     │
│  - InputBar (free text) + QuickActionChips    │
│  - Title/Settings/Credits screens             │
├─────────────────────────────────────────────┤
│ Engine (pure Swift, no UI, fully testable)    │
│  - GameEngine: holds GameState, runs turns     │
│  - Parser: normalize + match (userinput/contains)│
│  - Room model + RoomScript handlers            │
│  - TextScheduler: sentence pacing              │
├─────────────────────────────────────────────┤
│ Content (data)                                │
│  - Rooms, dialogue, items, spells, puzzles     │
│  - String catalogs (verbatim original text)    │
├─────────────────────────────────────────────┤
│ Persistence                                   │
│  - Codable GameState (save/restore/checkpoint) │
└─────────────────────────────────────────────┘
```

### B.2 Core model

```swift
struct GameState: Codable {
    // Spells & items as a typed set (replaces individual globals)
    var flags: Set<Flag> = []          // .levitate, .sword, .lantern, .dagger,
                                       // .fireball, .stonebend, .rod, .metDentros …
    var guesses: Int = 3
    var roadProgress: Int = 0          // replaces roadfir/roadgeo/roadlev
    var orangeFishThrown: Int = 0
    var escortActive: Bool = false
    var magehouseLocked: Bool = false
    var teleporterDiscovered: Bool = false   // was `lady`
    var cataractaGateDone: Bool = false      // was `cgates`
    var deathCount: Int = 0            // surfaced in UI (improves on original)
    var symbols: [Symbol]              // shuffled at new-game
    var currentRoom: RoomID
    var textDelay: TextDelay = .on     // .on / .off / .tapToAdvance (new)
}
```

- Each former global maps to a `Flag` case or a typed field. **Dead flags**
  (`slipp`, `tunnel`, `tran`, `blood`, etc.) are **dropped** — they have no
  logic — except where preserving them as cosmetic no-ops aids fidelity.
- `symbols` and the fixed `^=1 ~=2 >=3 ;=4` legend are reproduced exactly.

### B.3 Rooms as data + handlers

Model each location as a `Room` with: an ID, a description provider (can branch
on state, e.g. escort mode), and an ordered list of **commands** (synonym lists →
actions). A command's action mutates `GameState` and/or returns a transition to
another `RoomID`. This replaces the recursive function calls with explicit
transitions, so "go back" is a normal transition and there is no stack growth.

```swift
struct Command {
    let synonyms: [String]            // e.g. ["NORTH"], ["LEAVE","BACK","EXIT","RETURN","SOUTH"]
    let requires: [Flag]              // gate (e.g. .levitate)
    let action: (inout GameState) -> TurnResult
}
enum TurnResult { case stay, go(RoomID), output([StyledLine]), death(String), win }
```

### B.4 Parser — reproduce original behavior faithfully

Two parsing modes, selectable per room to match the original:
- **Normalized mode** (default, = `userinput`): uppercase, strip `"USE"`,
  `"CAST"`, and spaces; then `containsAny` substring match.
- **Raw mode** (for `mcave`, trading post, `bridge`, yes/no & "cast again?"
  prompts): uppercase only; exact or substring match per the original's lists.

Keep the **exact synonym lists** from the original so acceptance behavior
(including substring quirks) matches. Quick-action chips in the UI should map to
these same canonical verbs.

### B.5 Text pacing (the "delay between sentences" feel)

- A `TextScheduler` emits lines one at a time with the original's 8 s × multiplier
  delays when `textDelay == .on`, instantly when `.off`.
- **Add a mobile-friendly third mode** `.tapToAdvance` (tap to reveal next line)
  and let any active delay be skipped by tapping. The settings screen mirrors the
  original "On is strongly recommended for first time players." prompt.

### B.6 Persistence (allowed improvement over the original)

- `GameState` is `Codable` → JSON. Auto-save on every room transition.
- On death: keep the original's narrative "you have died → restart" *framing*,
  but offer **Restart from last checkpoint** (room entry) in addition to **New
  game**. Checkpoint at each room entry; never mid-puzzle in a way that traps the
  player.
- A New Game re-runs the `intro()` equivalent (reset state, reshuffle symbols).

### B.7 Styling (map ANSI → SwiftUI)

| Original ANSI | Meaning | iOS style |
|---|---|---|
| `\033[1;32;48m` green | item acquired | green callout line |
| `\033[1;31;48m` red | death | red banner |
| `\033[1;33;48m` yellow | puzzle symbols | amber monospace |
| `\033[2;36;48m` cyan | title | cyan title styling |

Recurring **blue-crystal** motif (see `STORY.md` §8) should be the app's accent.

### B.8 Fidelity checklist (definition of "faithful")

- [ ] All room text reproduced verbatim, including jokes ("It's already lit fam",
      "42", "Thanks for your honesty", "Items don't just appear…").
- [ ] Exact synonym/verb lists and per-room parse mode.
- [ ] Symbols puzzle: per-game shuffle + fixed legend + slot-based clue reveals.
- [ ] Spell/item gating identical to the flag table (§A.4).
- [ ] Ambush is unwinnable without Inflame; road needs Inflame→Stonebend→
      Levitate(dream-swim).
- [ ] Fishing odds and the orange-fish/sea-serpent threshold.
- [ ] Escort-mode hubs (reduced exits) once the Old Mage joins.
- [ ] Single canonical win → ending → credits.
- [ ] Allowed deviations only: state machine (no recursion), typed state (no
      globals), checkpoint persistence, tap-to-advance pacing, surfaced
      `deathCount`. Everything player-facing otherwise matches the original.

### B.9 Suggested module layout (repo)

```
AvasiaKoN/                 # Xcode project (to be created)
  Engine/                  # pure Swift, unit-tested
    GameState.swift
    GameEngine.swift
    Parser.swift
    Room.swift
    Puzzles/…
  Content/                 # data + verbatim strings
    Rooms/…                # one file/area: Oceandale, Cave, Forest, Road…
    Strings/…
  UI/                      # SwiftUI views
  Persistence/
  Resources/               # art, fonts, sfx (blue-crystal theme)
AvasiaKoNTests/            # engine unit tests (puzzles, gating, parser)
docs/                      # STORY.md, ENGINE_SPEC.md, WORLD_MAP.md
```

Build the **Engine + Content** layer first and validate it against the original
by scripting known solution paths in unit tests before adding UI.
