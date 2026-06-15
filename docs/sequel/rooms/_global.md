# Global Systems — Sword of Courage

> Applies everywhere; not tied to a single room. Source: `Avasia-SoC/Logic/`,
> `Player/Player.py`, `Combat/Combat.py`, `Logic/main.py`.

---

## New game intro (`util.intro`)

| Step | Content |
|---|---|
| Load or new | Prompt: load save or start new |
| Name entry | Loop until player confirms; `config.player.set_name(name.title())` |
| Opening prose | Six months since Oceandale; Kaefden IV; Vashirr teaching magic; Cataracta volunteers |
| House scene | Join Legion today → head to courtyard |
| Starting gifts | **100 gold**, **1× Potion** (10 HP food) |
| Trophy | `startedAdventure` — "Started the Adventure" |
| Start room | `Cataracta_Housing` |

**iOS gap:** ~~Name entry~~ ✅ · Starting potion in `SoCGameState.init`

---

## Global commands (`mainloop`)

Available in any room after intro (substring match on uppercased input):

| Triggers | Action |
|---|---|
| `HELP`, `COMMANDS` | Print command list |
| `INVENTORY` | Print player inventory |
| `EAT`, `DRINK` | If HP &lt; max: pick food item by name; restore HP |
| `SAVE` | `save.saveParameters()` |
| `LOAD` | `loadParameters()` |
| `QUIT`, `EXIT` | Save + quit |
| `TROPHY`, `TROPHIES`, `ACHIEVEMENTS`, `ACHIEVEMENT` | Print obtained trophies |

Directional movement in **link** rooms uses the same input line as global commands.

**iOS gap:** Auto-save each turn; SAVE prints confirmation.

---

## Spirit animal classes (set in courtyard)

| Spirit | Class ID | ATK | SPD | HP | LUCK |
|---|---|---:|---:|---:|---:|
| Wolf | `hunter` | 10 | 10 | 20 | 5 |
| Bear | `guardian` | 10 | 1 | 25 | 5 |
| Fox | `scout` | 15 | 15 | 15 | 5 |

Luck check: `player.luck >= randint(0, 11)` to hit. Enemy default luck **0** (never set in `set_stats`).

---

## Combat (`Combat.py`)

| Triggers | Effect |
|---|---|
| `ATTACK`, `STRIKE`, `FIGHT` | Initiative roll → player/enemy attacks in speed order |
| `HELP`, `COMMANDS` | Prints `["ATTACK", "HEAL", "HELP"]` |
| `HEAL`, `EAT`, … | **Commented out** in source |

Death: enemy kill text + "You have died." → load-save prompt in Python; iOS uses checkpoint overlay.

---

## Item catalog (`Item_Storage.py`)

| ID | Name | Type | Restore | Shop value |
|---|---|---|---|---:|
| `potion` | Potion | food | 10 HP | 25 |
| `smallfish` | Small Fish | food | 5 HP | 5 |
| `bigfish` | Big Fish | food | 10 HP | 10 |
| `crab` | Crab | food | 15 HP | 15 |
| `oldshoe` | Old-shoe | junk | — | 2 |

---

## Trophy catalog (`Player.py`)

| Key | Display name | Source trigger |
|---|---|---|
| `startedAdventure` | Started the Adventure | New game intro |
| `fished` | Gone Fishin' | Exhaust bait at fishing pier |
| `brother` | Brotherly Love | Doran pier via Ulric referral (free rod) |

**iOS gap:** SoC trophies not wired to app achievements.

---

## XP (`Player.py`)

| Constant | Value | Used in source |
|---|---:|---|
| `smallQuestExp` | 15 | Library `LOOK` |
| `mediumQuestExp` | 50 | — |
| `largeQuestExp` | 100 | — |

Level thresholds exist (`levels` dict) but no room in source grants level-ups beyond library look.

---

## Config flags (cross-room)

| Python `config` | Swift `SoCGameState` | Set by |
|---|---|---|
| `fountain` | `fountain` | Garden coin toss |
| `ulric` | `ulric` | Ulric first visit (if `doran` false) |
| `doran` | `doran` | Pier first greeting |
| `portalRoom` | `portalRoom` | Enter library via portal puzzle |
| `ventFound` | `ventFound` | Portal search (local in Python; persisted in Swift) |
| `libraryLooked` | `libraryLooked` | Swift only (optional) |
| `courtyardComplete` | `courtyardComplete` | Swift only |
