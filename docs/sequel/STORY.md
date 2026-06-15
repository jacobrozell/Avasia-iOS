# Avasia: Blade of Courage — Story Bible

> Narrative reference for the sequel. Canon sources: `Avasia-SoC/Logic/util.py`
> (intro), room scripts under `Avasia-SoC/Cataracta/` and `Avasia-SoC/Nacastrum/`,
> and continuity from [`../STORY.md`](../STORY.md) (KoN).
>
> Companion docs:
> - `ENGINE_SPEC.md` — mechanics, classes, combat.
> - `WORLD_MAP.md` — room graph and walkthrough.
> - `ROADMAP.md` — what still needs to be written.

---

## 1. Title & Position in the Saga

| | KoN (Game 1) | Blade of Courage (Game 2) |
|---|---|---|
| **Protagonist** | Amnesiac mage (player's true identity: Nacastrum teacher, Kaefden heir) | Named Druid recruit in Cataracta |
| **Timeline** | Oceandale falls; player crowned at KoN's end | **Seven years later** — no Agromanian invasion since KoN; Paladin threat escalates now |
| **Perspective** | Mage / Kaefden loyalist | Druid / Cataractan legion volunteer |
| **Antagonist** | Vashirr (ex-king, Agromanian ally) | Vashirr — Agromanian king's **right hand**; forging **Paladins** |
| **Tone** | Earnest tragedy + meta humor | Similar register; more RPG framing (classes, XP, trophies) |

In-game title: **Avasia: Blade of Courage** — named for **Kaefden's Blade of
Courage**, buried with the first king at **Varatro Falls** (Act IV relic quest).

---

## 2. Opening Situation (canonical intro)

Delivered after the player chooses a new game and enters their name:

> *It has been seven years since the fall of Oceandale and the crowning of King Kaefden IV.*
> *In all that time, no Agromanian army has crossed the border — yet the Kaefdens have not rested.*
> *Nacastrum rises again while legions train for the war everyone knows is coming.*
> *Recently, word reached Aylova from Silvarium: Vashirr, the traitor ex-king of Nacastrum, stands at the Agromanian king's right hand — and teaches their warriors magic.*
> *They call these new soldiers Paladins.*
> *King Kaefden IV has begun recruiting in earnest before the northwest can muster.*

> *You are a druid living in the peaceful city of Cataracta.*
> *Cataracta has formed a pact with the people of Aylova to join the fight when the time comes.*
> *The leader of Cataracta is drafting an army and you have decided to volunteer.*
> *This is where your story begins...*

### Timeline reconciliation (KoN → SoC)

| Event | When |
|---|---|
| Oceandale attacked; KoN begins | Game 1 opening (*"last week"*) |
| KoN ends; Kaefden IV crowned | End of game 1 |
| **SoC opens** | **7 years** after coronation |
| Border quiet | No Agromanian invasion in those 7 years |
| Army buildup | Kaefden legions grow in response to standing threat |
| Paladin intel | Agromanian defector reaches **Silvarium**; news relayed to Aylova |
| Cataracta massacre | SoC Act II — first open Agromanian strike in years |

The player starts in their **house** (Southwest Cataracta), pockets **100 gold**
and a **potion**, and is directed to the **Legion courtyard** to enlist.

---

## 3. The World (sequel lens)

Continuity with KoN — see [`../STORY.md`](../STORY.md) §2 for full faction lore.

### 3.1 Factions at war

- **Kaefden** — King **Kaefden IV** rules from **Aylova**; **seven years** into
  rebuilding **Nacastrum** and swelling the legions. Cannot win alone against Paladins.
- **Agromanian** — Northwestern aggressors; **Vashirr** is the Agromanian king's
  right hand, training **Paladins** — magic-wrapped warriors stronger than anything
  Avasia has fielded.
- **Neutrals / Ofelos** — Neutral city; must be won via the **Silvarium elders**
  (see Act IV). Require **Kaefden's Blade of Courage** as the symbol of honor.
- **Cataracta** — Druid city in mountainous terrain; historically relied on hidden
  passages. Pact with Aylova to join the coming war. King **Kimious** leads.

### 3.2 Cataracta culture

Druids choose a **spirit animal** class tied to combat role:

| Spirit animal | Class ID | Role (in dialogue) |
|---|---|---|
| **Wolf** | `hunter` | Formidable in battle; hits hard, takes hits well |
| **Bear** | `guardian` | Front-line defense; high HP, low speed |
| **Fox** | `scout` | Fast, silent; scouting force |

Youths are taught to **fish, hunt, and survive** — not sent to an academy like
Nacastrum mages (`n_library` lore). The **Anula** blue crystal appears in the
castle garden fountain (echoing KoN's blue-crystal motif).

### 3.3 Key NPCs (implemented)

| Character | Role | Notes |
|---|---|---|
| **Dentros** | Legion recruiter | Guides class selection; dies shielding the player from Vashirr |
| **Kimious** | King of Cataracta | Rallies the legion; killed by Vashirr's dark bolt |
| **Vashirr** | Antagonist | Hooded, scarred, gray staff; portals Agromanian army into Cataracta |
| **Athalos** | Shopkeeper | "Althalos' Wares"; eccentric, struggling business |
| **Ulric** | Blacksmith | Sends player to brother Doran for fishing |
| **Doran** | Fisherman | Pier owner; rough but fair; brotherly-love trophy |
| **Thekia** | Nacastrum library | High Mage's Council; escorts player to king |

### 3.4 Name inconsistencies to resolve later

The prototype has typos and alternate spellings (`Althalos`/`Athalos`, `Dentros`/
`Destros`, `Nascastrum`/`Nacastrum`). Pick one spelling per character/place when
finishing the game.

---

## 4. Plot Arc (as implemented + intended)

### Act I — Peaceful Cataracta (optional exploration)

Before the courtyard, the player can wander:

- Cross the **Varatho river** bridge between housing and north town.
- Visit **shopping** (Athalos, Ulric, Doran's pier).
- **Fish** for junk, gold purses, and food (side content + trophy).
- Toss a coin in the **Anula fountain** (easter egg — nothing happens).
- Attempt **barracks** (turned away) and **hunter's path** (redirect to courtyard).

**Design intent:** Let the player bond with Cataracta before it burns.

### Act II — Enlistment & the Massacre (critical path)

1. **Courtyard** — Dentros assigns spirit-animal class and sets combat stats.
2. **Kimious's speech** — War is coming; hidden defenses are no longer enough.
3. **Vashirr's assault** — Portal opens at the keep; Agromanian horde; Kimious
   assassinated.
4. **Combat** — Two back-to-back fights (Grunt, then Warrior); player healed to
   full between (author note: needs better story justification).
5. **Dentros's death** — Killed while saving the player.
6. **Vashirr's message** — Staff to the player's head; demands the player tell
   Kaefden IV that Cataracta has fallen and Vashirr *"will not stop"* while
   Kaefden holds *"his unearned claim."*
7. **Mass execution** — Captured druids slaughtered; player knocked unconscious.
8. **Awakening** — Alone among ashes; castle in flames. **Cataracta is destroyed.**

Author TODO in `Logic/main.py`: *"Destroy all paths to cataracta"* — post-attack,
Cataracta should not remain explorable.

### Act III — Nacastrum (in progress)

After the massacre, `config.current_room_id` jumps to **`c_portal_room`**
(Cataractan portal chamber inside Nacastrum castle).

1. **Portal room** — Red/blue light; unused portal; east door locked (cast iron).
   Puzzle: search → vent or book stack → enter ceiling ducts → drop into library.
   Class gate: scouts/hunters too short for vent without books (bears can reach).
2. **Library** — Purple-robed woman hears the player's account; *"We must go and
   alert the king!"* Optional LOOK grants small quest XP.
3. **West hallway** — Hub: north → library, east → throne room, west → portal room.
4. **Throne room** — Audience with **King Kaefden IV** (the KoN protagonist).
   Delivery of Vashirr's message, mobilization, and the opening moves of the
   **full continental war**.

### Act IV — The war (implemented + planned)

Blade of Courage does not end at the throne room. The second half is the **full war**
against Vashirr and the Agromanians, plus the **neutral alliance** arc:

**Implemented (iOS):** mobilization at Aylova → **Silvarium elders** → **Varatro Falls**
(Blade dungeon) → **Ofelos** (neutral alliance) → northern march → Oceandale ridge →
mage outpost → Vashirr's redoubt → Age-era epilogue.

### Game 3 — first 2D game (future)

The **Age era ends with SoC.** There is no third text adventure. The next release
is game 3 in a **2D engine** — new era in-world, new format for the player. See
[`../SAGA.md`](../SAGA.md).

SoC must **resolve the war and Vashirr arc** within text. Game 3 inherits the
aftermath, not unfinished business.

---

## 4. Royal structure (canon)

| Role | Who | Notes |
|---|---|---|
| **King Kaefden IV** | KoN protagonist | Crowned at KoN's ending; **seven years** rebuilding Nacastrum and the legions |
| **Capital** | Aylova | Seat of Kaefden power; army mustering per intro |
| **Nacastrum** | Rebuilding under Kaefden IV | Castle/library scenes in SoC take place here |
| **King Kimious** | Ruler of Cataracta (deceased Act II) | Druid faction ally |
| **Vashirr** | Ex-king of Nacastrum; antagonist | Openly allied with Agromanians; teaches them magic |

The intro's *"seven years"* and *"King Kaefden IV"* at Aylova are the **same person**
— the mage-king from game 1, now a seasoned ruler facing Paladins.

---

## 5. Key Story Moments / Set Pieces

| Beat | Location | Status |
|---|---|---|
| Volunteer's pride leaving home | Housing intro text | ✅ |
| Class selection with Dentros | Courtyard | ✅ |
| Kimious war speech | Courtyard | ✅ |
| Portal invasion | Courtyard | ✅ |
| Vashirr unmasked + message | Courtyard | ✅ |
| City in ashes | Courtyard (post-fight) | ✅ |
| Portal room vent puzzle | Nacastrum | ✅ |
| Library witness | Nacastrum | ✅ |
| Alert the king | Throne room | ⬜ stub (source stops) |
| War camp muster | Aylova | ✅ iOS authored |
| Northern march patrol | Border road | ✅ iOS authored |
| Oceandale ridge | War front | ✅ iOS authored |
| Mage outpost | War front | ✅ iOS authored |
| Vashirr's redoubt | War front | ✅ iOS authored |
| Age-era epilogue | Aylova | ✅ iOS authored |
| Cataracta revisit | Ruins / survivors | ⬜ **not in source** |

---

## 6. Tone & Voice

Match KoN's dual register where possible:

- **Earnest:** genocide of Cataracta, Dentros's sacrifice, Vashirr's threat.
- **Meta / light:** fountain coin flip (*"I guess some things just aren't worth
  doing"*), Doran's gruff hospitality, Athalos's overstocked empty shop.

The sequel adds **RPG flavor text** (XP gains, trophy pop-ups, class banter) that
KoN lacked. Keep trophies diegetic (*"Trophy unlocked"*) or reskin for iOS
(achievement system like KoN remake).

---

## 7. Recurring Motifs

Carry forward from KoN (see [`../STORY.md`](../STORY.md) §8):

- **Blue crystal (Anula)** — garden fountain; ties Druid Cataracta to mage imagery.
- **Portals** — Vashirr's mass teleport; Cataractan portal room in Nacastrum.
- **Shapeshifting / spirit animals** — class identity as Druid cultural practice.
- **Vashirr's scar** — visual marker; first unhooded appearance in the series?

---

## 8. Author Notes (from prototype comments)

From `Logic/main.py`:

```
# Add more story -JR
# Make next city - JR
# Destroy all paths to cataracta - JR
#
# Change Combat to be outside of Cataracta and leave cataracta NOT destroyed?
```

These capture an unresolved fork from early development. **Current canon:** Cataracta
falls in Act II. A **later revisit** to the ruins remains possible (see Act IV).

---

## 9. Continuity Checklist (KoN → SoC)

| KoN ending element | SoC reference |
|---|---|
| Vashirr allied with Agromanians | Confirmed; now teaching them magic |
| Nacastrum rebuilding | Under Kaefden IV (KoN protagonist) |
| Mages returning home | Castle/library populated; war coalition forming |
| Player crowned in KoN | **Same person as Kaefden IV** — NPC in SoC |
| Rings of Malkos / blue gems | Anula crystal in Cataracta garden |

**Throne room writing note:** Kaefden IV should read as the mage-king the player
knows from KoN — pointed ears, shared history with Vashirr, weight of the crown.
The Druid PC may not know his full story; the *player* does.
