# UI Wireframes

Low-fidelity layouts for the iOS app. Screens map directly to the SwiftUI views
in `App/Views/`. Visual language: night background, parchment serif text, and a
**blue-crystal** accent (STORY.md §8). Styled text colors follow ENGINE_SPEC §B.7.

Navigation map:

```
        ┌──────────┐   New Game / Continue   ┌──────────┐
        │  Title    │ ───────────────────────▶ │   Game    │
        │  (menu)   │ ◀─────────  menu  ─────── │  (play)   │
        └────┬─────┘                            └────┬─────┘
             │  Settings / Credits                   │ death
             ▼                                        ▼
   ┌──────────────────┐                      ┌──────────────────┐
   │ Settings / Credits│                      │  Death overlay    │
   └──────────────────┘                      │ checkpoint / new  │
                                             └──────────────────┘
   Win → Ending text in transcript → Credits
```

---

## 1. Title  (`TitleView`)

```
┌─────────────────────────────────────┐
│                                       │
│                                       │
│              A V A S I A               │   ← 52pt serif, blue-crystal
│           King of Nacastrum            │   ← italic serif, parchment
│                                       │
│                                       │
│          ┌───────────────────┐        │
│          │     New Game       │        │
│          └───────────────────┘        │
│          ┌───────────────────┐        │
│          │     Continue       │        │   ← only if a save exists
│          └───────────────────┘        │
│          ┌───────────────────┐        │
│          │     Settings       │        │
│          └───────────────────┘        │
│          ┌───────────────────┐        │
│          │     Credits        │        │
│          └───────────────────┘        │
│                                       │
│  On is strongly recommended for       │   ← echoes original prompt
│  first time players.                   │
└─────────────────────────────────────┘
```

---

## 2. Game  (`GameView`)  — the core screen

```
┌─────────────────────────────────────┐
│ ☰   ✦Levitate ✦Inflame  🗡 🏮      ☠ 2 │  ← status strip: menu · spells · items · deaths
├─────────────────────────────────────┤
│                                       │
│  You draw nearer to the house, when   │  ← transcript (scrolling)
│  the door bursts open...              │     body = parchment
│                                       │
│  "You recognize one of your own       │  ← speech = italic serif
│   don't you? Mage to mage."           │
│                                       │
│  > kaefden                            │  ← echoed player input (hint style, muted)
│                                       │
│  You have learned the spell LEVITATE. │  ← item = green
│                                       │
│  > jump                               │
│  You have died.                       │  ← death = red
│                                       │
│            (auto-scrolls to bottom)    │
│                                       │
├─────────────────────────────────────┤
│ [North][East][South][West][Look][Talk]│  ← horizontal quick-action chips
├─────────────────────────────────────┤
│ ┌─────────────────────────────┐  ⬆   │  ← free-text input + send
│ │ What do you do?              │      │
│ └─────────────────────────────┘      │
└─────────────────────────────────────┘
```

Behavior notes:
- **Transcript** is the source of truth; every turn appends styled lines and the
  view auto-scrolls. Long descriptions reveal line-by-line under the active
  **text pacing** (On / Off / Tap-to-advance); a tap skips an in-progress delay.
- **Quick-action chips** are shortcuts that submit canonical verbs — identical to
  typing them. Context-aware chips (e.g. `Fish`, `Up`, `Down`, `Cast…`) can be
  added per room later.
- **Free-text input** is the primary interface, preserving the original parser
  feel (`cast levitate`, `go north`, `take sword`).
- **Status strip**: ☰ opens the menu (back to title); spells/items appear as they
  are gained; ☠ shows the death counter (surfaced — an improvement on the
  original).

---

## 3. Death overlay  (modal over `GameView`)

```
┌─────────────────────────────────────┐
│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│  ← dimmed scrim
│                                       │
│            You have died.             │  ← large red serif
│                                       │
│     ┌───────────────────────────┐     │
│     │  Restart from checkpoint   │     │  ← last room entry (new convenience)
│     └───────────────────────────┘     │
│     ┌───────────────────────────┐     │
│     │        New game            │     │  ← faithful full restart
│     └───────────────────────────┘     │
│                                       │
└─────────────────────────────────────┘
```

The original sent every death back to the title for a full restart. We keep that
option ("New game") but add a checkpoint restart so a single mistake doesn't cost
the whole run (ENGINE_SPEC §B.6).

---

## 4. Settings  (`SettingsView`)

```
┌─────────────────────────────────────┐
│              Settings                 │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │ Text pacing                      │ │
│  │ Delay between sentences. On is   │ │
│  │ strongly recommended for first   │ │
│  │ time players.                    │ │
│  │ ┌────────┬────────┬───────────┐  │ │
│  │ │  On    │  Off   │ Tap to adv │  │ │  ← segmented control
│  │ └────────┴────────┴───────────┘  │ │
│  └─────────────────────────────────┘ │
│                                       │
│          ┌───────────────────┐        │
│          │       Back         │        │
│          └───────────────────┘        │
└─────────────────────────────────────┘
```

Future settings to slot in here: font size, sound/music toggles, haptics,
colour-blind-safe palette, reset save.

---

## 5. Credits  (`CreditsView`)

```
┌─────────────────────────────────────┐
│                                       │
│       Avasia: King of Nacastrum       │
│                                       │
│      Original game by Jacob Rozell     │
│   with Chase Pernatozzi, Devan        │
│   Deloach, and Joshua Rogers          │
│                                       │
│            iOS remake                  │
│                                       │
│          ┌───────────────────┐        │
│          │       Back         │        │
│          └───────────────────┘        │
└─────────────────────────────────────┘
```

Reached from the title menu and automatically after the canonical win (the
ending text prints in the transcript, then offers Credits).

---

## Component inventory (for design hand-off)

| Component | Used by | Notes |
|---|---|---|
| `MenuButton` | Title, Settings, Credits, Death | bordered blue-crystal capsule/box |
| `LineView` | Game transcript | styled per `StyledLine.Style` (Theme.swift) |
| Quick-action chip | Game | capsule, submits a verb |
| Input bar | Game | free-text + send button |
| Status strip | Game | spells/items/death-count |
| Death overlay | Game | scrim + two restart options |

## Art / asset direction (later)

- Per-region header illustration or color wash (ruined Oceandale, pink-crystal
  cave, the great tree, the floating city) keyed to `RoomID`.
- Blue-crystal accent everywhere a "true mage / Ring of Malkos" beat lands.
- Optional ambient SFX per region (waves, dripping cave, wind on the bridge).
- A subtle parchment paper texture behind the transcript.
