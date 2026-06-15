# Achievements & the Death Screen

How the achievement system and the flavored death screen work, the full
achievement catalog, and how to add more.

## Death screen

Every lethal outcome carries a structured `DeathCause`
(`Sources/AvasiaEngine/Model/DeathCause.swift`) instead of a free-form string.
Each cause provides:

- a **title** (e.g. "Into the Chasm", "Crab Dinner", "Too Greedy"), and
- a sardonic **epitaph** (e.g. "The water was farther down than it looked.").

The room still prints its **verbatim** death narration into the transcript; the
`DeathCause` powers the overlay. `GameEngine` records the most recent death as
`DeathInfo { cause, narrative, number }`, and the overlay
(`App/Views/GameView.swift` → `deathOverlay`) shows a skull, the cause title in
red serif, the epitaph, "You have died · Death #N", and the
**Restart from checkpoint** / **New game** buttons (ENGINE_SPEC §B.6).

Causes: `chasm, crab, seaSerpent, stalactite, mining, neckCut, ambush, fireball,
generic`.

## Achievement architecture

```
Room.handle ──► TurnResult(lines, transition, events)
                          │
GameEngine.submit ────────┼─ derives events: .gained(flag) from flag diff,
                          │  .enteredRegion on a region change, .died(cause),
                          │  .won; merges room-emitted events (.heard42,
                          │  .caughtGoldFish, .tossedOrangeFish)
                          ▼
                  engine.lastEvents : [GameEvent]
                          │
GameViewModel.submit ─────► AchievementTracker.apply(events, state, &progress)
                          │      → unlocks, mutates AchievementState
                          ▼
                  SaveStore.saveAchievements (achievements.json)  +  toast UI
```

- **`GameEvent`** (`Model/GameEvent.swift`) — the semantic event stream.
- **`Achievement`** (`Model/Achievement.swift`) — the catalog enum + presentation
  metadata (`title`, `detail`, `isSecret`). Criteria are **not** here.
- **`AchievementState`** (`Model/Achievement.swift`) — persistent, **cross-run**
  progress: `unlocked: Set<Achievement>`, `totalDeaths`, `regionsVisited`,
  `orangeFishTossed`. Saved separately from `GameState` (which resets each new
  game) in `achievements.json`.
- **`AchievementTracker`** (`Engine/AchievementTracker.swift`) — the pure
  evaluator. `apply(events:state:into:)` folds events into progress and returns
  the achievements newly unlocked this turn (for toasts). `recordRegion` seeds
  the starting region on a new/continued game (since `enteredRegion` only fires
  on movement).

### Why cross-run persistence
Death counts and exploration accumulate over many attempts; `GameState` is wiped
on every new game. Achievements therefore live in their own `Codable` store and
survive death/restart. `totalDeaths` here is the lifetime counter (distinct from
`GameState.deathCount`, which is per-run).

## Catalog

Legend: **P** progression · **E** exploration · **F** flavor · **D** death.
Secret achievements are masked ("??? (Secret)") in the list until earned.

| ID | Title | Type | Secret | Unlocks when |
|---|---|---|---|---|
| `firstSteps` | First Steps | P | no | learn Levitate |
| `armed` | Armed | P | no | take the Long Sword |
| `firekeeper` | Firekeeper | P | no | learn Inflame |
| `earthshaper` | Earthshaper | P | no | learn Stonebend |
| `fullArsenal` | Full Arsenal | P | no | know all three spells |
| `kingOfNacastrum` | King of Nacastrum | P | no | complete the game |
| `druidFriend` | Friend of the Druids | E | no | get Dentros's lantern |
| `wanderer` | Wanderer | E | no | visit 8 distinct regions |
| `worldsEnd` | To the World's End | E | no | visit every region |
| `meaningOfLife` | The Meaning of Life | F | yes | hear the priestess say "42" |
| `goldRush` | Gold Rush | F | yes | catch the golden fish |
| `persistentAngler` | Persistent Angler | F | yes | throw back 3 orange fish |
| `firstBlood` | First Blood | D | yes | die once |
| `intoTheDeep` | Into the Deep | D | yes | die in the chasm |
| `crabDinner` | Crab Dinner | D | yes | die to the fishing crab |
| `swallowedWhole` | Swallowed Whole | D | yes | die to the sea serpent |
| `pointedEnd` | A Pointed End | D | yes | die to the cave stalactites |
| `tooGreedy` | Too Greedy | D | yes | die mining the crystals |
| `theWrongCut` | The Wrong Cut | D | yes | die cutting your neck |
| `ambushed` | Ambushed | D | yes | die in the road ambush |
| `burnedToAsh` | Burned to Ash | D | yes | run out of guesses at the pedestal |
| `martyr` | Martyr | D | yes | die 10 times (lifetime) |

`regionsVisited` counts the 12 `Region` cases, so `worldsEnd` requires all 12 and
`wanderer` requires 8.

## UI surfaces

- **Toasts** — `GameView.achievementToasts` shows a trophy + title banner for
  ~4s when `recentlyUnlocked` is non-empty.
- **Achievements screen** — `App/Views/AchievementsView.swift`: progress count,
  lifetime deaths, and a row per achievement (trophy if unlocked, lock/`???` if
  not). Reached from the title menu and the in-game trophy button
  (`openAchievements(from:)` remembers where to return).

## Adding a new achievement

1. Add a case to `Achievement` with `title`/`detail`/`isSecret`.
2. If a new signal is needed, add a `GameEvent` case and either derive it in
   `GameEngine.submit` or emit it from a room via `TurnResult(..., events: [...])`.
3. Add the unlock rule to `AchievementTracker.apply`.
4. Add a test in `AchievementsTests`.

No UI changes are needed — the list and toasts are catalog-driven.

## Future ideas (not yet implemented)

- Speedrun / "Fastest run" timer achievement (the original brags a 1:59.2 time).
- "Pacifist" (win without ever dying), "Completionist" (all spells + rod + visit
  every NPC), per-NPC "talked to everyone in Silvarium".
- Game Center integration (map `Achievement.rawValue` → GC identifiers).
