# Avasia: Blade of Courage — Engine Spec

> Part A documents the **Python prototype** (`Avasia-SoC/`). Part B sketches a
> **target architecture** for finishing the game and eventually shipping on iOS,
> reusing lessons from the KoN remake (`Sources/AvasiaEngine/`).

---

## Part A — Python prototype (current)

### A.1 Entry & loop

| File | Role |
|---|---|
| `game.py` | Thin launcher → `Logic/main.py` |
| `Logic/main.py` | Registers all rooms, calls `util.intro()`, runs `mainloop()` |
| `Logic/config.py` | Global singletons: player, enemy, combat, quest flags, colors |
| `Logic/util.py` | `containsAny`, `talk`, `intro`, color helpers |
| `Logic/Room_Storage.py` | Aggregates room imports |
| `Logic/Item_Storage.py` | Item singletons |
| `Logic/Save.py` | Pickle save/load |

**Main loop** (`mainloop`):

1. Resolve `current_room` from `all_rooms_id[config.current_room_id]`.
2. Call `room.event()` → `on_enter()` logic or default description.
3. Handle return tokens: `"reload"` (re-enter room), `"go back"` (restore prior room).
4. Prompt: *"Which way would you like to investigate?"*
5. Dispatch global commands (`INVENTORY`, `EAT`/`DRINK`, `SAVE`, `LOAD`, `QUIT`, `TROPHY`, `HELP`) or pass input to `room.direction()`.

### A.2 Room model

```python
Room(name, des, id, directions, on_enter=None)
```

- **Linking rooms** (`on_enter=None`): print name + description; directions dict
  maps `N/E/S/W/NE/NW/L/R/U/D` → target room id.
- **Logic rooms** (`on_enter=callable`): callable returns `"reload"`, `"go back"`, or
  mutates `config.current_room_id` and returns `"reload"`.

Direction matching uses substring `containsAny` (same family of parser as KoN).

### A.3 Player & progression

`Player/Player.py`:

| System | Implementation |
|---|---|
| Stats | ATK, SPEED, HP, LUCK (+ max values); set at class selection |
| Classes | `hunter`, `guardian`, `scout` via spirit animal choice |
| Gold | Start 100; cap 1000 |
| Inventory | Dict keyed by item object; parallel `printInventory` for display |
| Leveling | Levels 2–8 thresholds; +1 all max stats on level up |
| XP | Combat (`give_combat_exp`) and quest (`give_quest_exp` with first-time hint) |
| Trophies | 3 defined: `startedAdventure`, `fished`, `brother` |

**Class stats at enlistment:**

| Class | ATK | SPD | HP | LUCK |
|---|---|---|---|---|
| Hunter (Wolf) | 10 | 10 | 20 | 5 |
| Scout (Fox) | 15 | 15 | 15 | 5 |
| Guardian (Bear) | 10 | 1 | 25 | 5 |

### A.4 Combat

`Combat/Combat.py` — turn loop until death:

1. Roll initiative via speed comparison.
2. Roll hit threshold: `needed_luck_to_hit = randint(0, 11)`; attacker hits if
   `luck >= threshold`.
3. Commands: `ATTACK`, `HELP` (`HEAL` commented out).
4. On player death: flavor text from `enemy.text`, offer load save.

**Known bugs / debt:**

- `Enemy.get_luck()` returns `self.speed` (copy-paste bug) — luck checks are wrong.
- `Player.return_item` returns `False` inside the loop on first non-match (should
  continue).
- `command.upper()` results discarded — case normalization ineffective.
- Combat heal branch commented out with broken references.

### A.5 Quest flags (`config.py`)

| Flag | Purpose |
|---|---|
| `fountain` | Coin tossed in garden |
| `ulric` / `doran` | Blacksmith → fisherman quest chain |
| `portalRoom` | Vent/books puzzle solved; east door flavor |
| `varrustysword`, `varbrokenaxe`, `courtyard`, `returnfish` | Reserved / unused in current rooms |

### A.6 Save system

Pickle serializes player stats, inventory display dict, trophies, quest flags,
and `current_room_id`. Auto-save triggers in courtyard and portal room.

**Not saved:** full inventory object graph (commented out in `get_all_stats`).

### A.7 Dependencies

- Python 3
- `colorama` for terminal colors

---

## Part B — Target architecture (finish + iOS)

### B.1 Strategic choice

Two viable paths:

| Approach | Pros | Cons |
|---|---|---|
| **B1: Extend KoN engine** | Shared Swift package, one parser/UI stack, achievements/save patterns exist | KoN is mage-spell focused; SoC needs classes, XP, tactical combat |
| **B2: New `AvasiaSoCEngine` package** | Clean RPG models; no compromise to KoN fidelity | Duplicate infrastructure (rooms, parser, saves) |

**Recommendation:** **B1 with a game-mode layer** — same room/graph/parser core as
`AvasiaEngine`, add SoC-specific modules (`CombatState`, `ClassStats`, `XPTable`).
The SwiftUI shell can share `GameView` patterns from the KoN app with a different
content bundle and combat UI.

### B.2 Proposed Swift modules (when porting)

```
Sources/
  AvasiaEngine/          # shared: Room, Parser, Narrative, Save
  AvasiaSoCContent/      # SoC rooms, items, enemies, scripts
  AvasiaSoCSystems/      # Combat, Classes, Leveling, Trophies
App/
  AvasiaSoCApp/          # SwiftUI target (or second scheme in existing app)
```

### B.3 Combat (target design)

**Design principle (author intent):** combat was always the hardest system to get
right. Fights must **not feel the same** and must **not become a chore**. The full
war scope does **not** mean random encounter grinding — it means **authored set
pieces** with distinct mechanics, stakes, and pacing.

#### What to avoid

- Identical turn loops repeated across dozens of fights.
- Mandatory grinding to level before story beats.
- Random battles on overworld travel (not in prototype; keep it out).

#### Encounter types (mix these)

| Type | Example | Feel |
|---|---|---|
| **Scripted story** | Courtyard Agromanian fights | Fixed outcome arc; mechanics teach the system |
| **Class puzzle** | Scout: avoid fight via stealth choice; Guardian: absorb hits for ally | Class identity, not just stat diff |
| **Boss / elite** | Vashirr lieutenant, Agromanian mage | Unique rules (shields, phases, environment) |
| **Optional skirmish** | Side quest defend a supply line | Rewarding but skippable |
| **Non-combat resolution** | Talk down, trap, environmental win | KoN-style ingenuity; zero repetition |

#### Core mechanics (evolve prototype)

- **Initiative:** speed comparison (keep).
- **Hit chance:** fix luck bug; consider `(luck + level) vs roll` instead of flat 0–11.
- **Actions:** Attack, Use Item (when relevant), Flee (when allowed), **class ability** (one per class, cooldown or once-per-fight).
- **Class hooks:**
  - *Hunter (Wolf):* bonus damage on first strike or when enemy wounded.
  - *Guardian (Bear):* damage reduction or intercept for ally NPC.
  - *Scout (Fox):* initiative bonus, flee reliability, or pre-fight intel.
- **War scale without spam:** represent armies as **narrative + single representative
  fight**, not hundreds of identical combats (e.g. Kimious's courtyard = the battle).
- **Death:** flavored messages + checkpoint load (mirror KoN death counter optional).

#### XP without grind

Quest XP and **first-time** encounter rewards (see prototype's `give_quest_exp`
hint). Re-fighting the same optional content should not be optimal.

### B.4 Content authoring

Python uses one file per logic room. For Swift, follow KoN's data-driven pattern:

- Room metadata in typed Swift or YAML/JSON generated at build time.
- Logic rooms as `RoomScript` closures or small structs.
- Verbatim text from Python preserved in content files for diffability.

### B.5 Fidelity checklist (sequel)

Unlike KoN, fidelity means **preserving implemented scenes verbatim** while freely
authoring new content:

- [ ] Intro text and Kimious/Vashirr courtyard speech match prototype
- [ ] Class stats and Dentros dialogue preserved
- [ ] Portal room puzzle logic (search → vent/books → library) preserved
- [ ] Library woman scene preserved
- [ ] Optional: fishing, fountain, shop NPCs
- [ ] Post-Cataracta: no return to destroyed city rooms
- [ ] Throne room and beyond: new writing (no prototype to match)

### B.6 iOS UX additions (non-content)

Same usability wins as KoN remake:

- Tap-to-advance narrative pacing
- Typed save slots / checkpoints
- Achievement/trophy screen (reuse KoN `AchievementsView` patterns)
- Combat as structured UI (action buttons vs free text)
- Optional: region art/audio hooks per `docs/ASSETS.md` pattern

---

## Part C — Python prototype maintenance

Until a Swift port begins, keep `Avasia-SoC/` runnable:

```bash
cd Avasia-SoC && python3 game.py
```

Priority fixes (see `ROADMAP.md` Phase 0):

1. Fix `Enemy.get_luck()`.
2. Fix `Player.return_item` loop.
3. Apply `.upper()` to commands.
4. Implement throne room or gate with *"To be continued"* message.
5. Remove `__pycache__` from VCS (gitignored).
