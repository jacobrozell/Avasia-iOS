# Avasia: King of Nacastrum — World Map & Room Graph

> The navigation reference: every area, its exits, and the gates between them.
> Derived faithfully from `Avasia-KoN/GameDriver.py`. Pair with `STORY.md`
> (what happens in each place) and `ENGINE_SPEC.md` (how transitions work).

Legend: **→** exit · `[flag]` = gate required · ⚑ = item/spell gained ·
☠ = death option · 🔁 = escort-mode variant exists.

---

## Overview

```
                        Forest / Silvarium (N)
                               │
   Western Road (W) ──── SPLITPATH ──── Bridge → Mountain (E)
        │                      │
   (to Nacastrum)        Graveyard / Upper Oceandale
                               │
                          OCEANDALE (hub)
                               │
                            Beach (S)
```

The world has three "spokes" out of **Splitpath**: the **Forest** (north,
Stonebend), the **Mountain/Cave** (east, Inflame + Lantern), and the **Western
Road** (west, the road to Nacastrum). You start south at Oceandale and must
learn **Levitate** before any spoke is reachable (the bridge gate).

---

## 1. Oceandale region (start)

### Oceandale (hub) 🔁
- **N** → Graveyard / Upper Oceandale
- **E** → Trading post (grieving merchant; flavor only)
- **W** → Magehouse `[locked after first visit]`
- **S** → Beach
- *Escort variant:* only **N** (to Nacastrum quest) and **S** (beach) remain.

### Beach (south)
- Stretch/yoga flavor. Fishing if `[rod]` → fishing minigame.
- **back** → Oceandale.

### Trading post (east)
- TALK = merchant's lament; no items. **back** → Oceandale.

### Magehouse (west) — quest hub
- First visit `[lev==0]`: meet the Old Mage, answer the faction question
  (must contain **KAEFDEN**) ⚑ **Levitate**; sets `lock=1`.
- Locked visit `[lock==1]`: "no longer home."
- Staff visit `[lady==1]`: Old Mage returns ⚑ **Staff**, begins **escort**.
- Escort `[escort==1]`: depart together.

---

## 2. Upper Oceandale / Graveyard

### Graveyard / Upper Oceandale 🔁
- **N** → Splitpath (through the northern gate)
- **E** → Corpse pile: LOOK then TAKE ⚑ **Long Sword**
- **W** → Church (burned; flavor only)
- **S** → Oceandale
- *Escort variant:* funnels toward Splitpath.

---

## 3. Splitpath (central hub) 🔁

- **N** → Forest entrance
- **E** → Bridge → Mountain
- **W** → Western Road
- **S** → Graveyard
- *Escort variant:* only **W** (to Nacastrum) is valid.

---

## 4. Mountain & Cave (east)

### Bridge `[lev]`
- Jump / Swim / Dive → ☠ death. Sword → "no trees long enough."
- **Levitate** → cross to Mountain.

### Mountain (hub)
- **N** → Cave entrance
- **E** → Dentros (druid scout): TALK ⚑ **Lantern**, cave tip-off
- **W** → West Mountain
- **S** → back across the bridge

### West Mountain → Druidpath (Cataracta gate)
- **N** `[!cgates]` → blue-crystal gate; TALK → wolf transforms; prove you're a
  mage: **EAR/EARS**, **Levitate**, or **Stonebend** (Inflame rejected).
  Cellious turns you away; sets `cgates=1`. Cataracta is never entered.

### Cave entrance `[lant]`
- Needs the **Lantern** (LIGHT/LANTERN). Swim through the flooded hole →
  Main cave. (Levitate here → ☠ stalactites.)

### Main cave `mcave` (hub) — *raw-input, exact directions*
- **N** → North cave → Fireball room
- **NE** → NE cave (cage)
- **NW** → NW cave (miner's body)
- **E** → E cave
- **W** → W cave → fork
- **S** → exit to cave entrance

Cave clue map (the symbols puzzle):
| Room | Reveals |
|---|---|
| E cave | `symbols[3]` (final) |
| W cave fork, LEFT dead-end | `symbols[0]` (start) |
| NW cave continue | `symbols[1]` (second) |
| NE cave cage `[lev]` | `symbols[2]` (third) |

- **North cave gate:** PUSH then **button 1 / `%'`** → `ndoor=1` → Fireball room.
- **Fireball room:** PUSH, then enter the 4-glyph order = `decodesymbols(symbols)`
  (legend `^=1 ~=2 >=3 ;=4`). Correct ⚑ **Inflame**; wrong → `guesses-1`, 0 → ☠.
- **NW cave:** optional pickaxe; mining → ☠.

---

## 5. Forest / Silvarium (north)

### Forest entrance → Forest grass `[sword]`
- Cut grass with the **Sword** (`grass=1`) → `ftrap` (if `[lev]`) or
  `ftrapnolev`; both lead to Silvarium. (Inflame/Levitate refused.)

### Forest trap (`ftrap`)
- Net sprung; the **Sylvian marksman** frees you and guides you in.

### Silvarium (`mforest`)
- First visit sets `forestlore=1` (long intro). Then **N** → the Great Tree;
  **S** → back.

### The Great Tree (4 floors)
- **Floor 1** (`treeenterance`): boy **Marlux**; **UP** → Floor 2.
- **Floor 2** (`treefloor2`):
  - **LEFT** → Butcher: TALK then EXPLAIN ⚑ **Suformin's Dagger** (chest)
  - **RIGHT** → Armory: guard bars entry (`armory=1`)
  - **UP** → Floor 3 · **DOWN** → Floor 1
- **Floor 3** (`treefloor3`):
  - **LEFT** → Church of Suformin (priestess; "42" easter egg)
  - **RIGHT** → Library (fox-coat librarian)
  - **UP** → Floor 4 · **DOWN** → Floor 2
- **Floor 4** (`treefloor4`): the **blood seal** — CUT + blade + part.
  **NECK** → ☠ (confirm). **Sword** → nothing. **Dagger** `[dagger]` on
  hand/leg → opens seal → ⚑ **Stonebend** (`geo=1`).

---

## 6. Western Road & the road to Nacastrum (west) 🔁

### Western Road
- **N** → Road to Nacastrum (danger sequence)
- **W** → Shoreside
- **E** → Splitpath
- *Escort variant:* leads the Old Mage toward the teleporter.

### Shoreside
- **Beach hut:** ROD/TAKE ⚑ **Fishing Rod**
- **Shore:** fishing minigame (if `[rod]`)

### Road to Nacastrum — sequential gauntlet
1. **Agromanian ambush** (`roadfir`): only **Inflame** wins (`roadfir=2`);
   `roadfir==1` makes every non-Inflame option lethal ☠.
2. **Stone spires** `[geo]`: only **Stonebend** breaks through.
3. **Dream bridge** `[lev]` (inversion): **Swim/Jump/Dive** → reveals Nacastrum
   → Teleporter (Levitate just loops back).

### Teleporter platform (Ring of Malkos)
- 1st visit `[lady==0]`: can't solve alone → `lady=1, lock=0`; return for the
  Old Mage.
- 2nd visit (escort): Mage uses the **Staff** → **memory flashback** →
  Nacastrum.

---

## 7. Endgame

### Nacastrum (floating city)
- Explore the ruined city; the **King's Castle** courtyard holds the father's
  corpse ⚑ **pendant** → proceed.

### Aylova (capital of Kaefden — final scene)
- Thekia opens a Ring of Malkos, rallies the banished mages; they return through
  the portal to repopulate Nacastrum → **ending** → credits.

---

## Critical-path summary (shortest faithful win)

1. Magehouse ⚑ Levitate → 2. Graveyard ⚑ Sword → 3. Splitpath
4. Bridge (Levitate) → Mountain → Dentros ⚑ Lantern
5. Cave: gather 4 symbols → North gate → Fireball room ⚑ Inflame
6. Forest: cut grass → Tree Floor 2 ⚑ Dagger → Floor 4 blood seal ⚑ Stonebend
7. Western Road → ambush (Inflame) → spires (Stonebend) → dream bridge (swim)
8. Teleporter (1st visit) → return to Magehouse ⚑ Staff (escort begins)
9. Escort west → Teleporter (2nd visit) → memory reveal → Nacastrum → Aylova →
   **win**.

Optional/non-critical: Fishing Rod & fishing, Cataracta gate, trading post,
church, beaches.
