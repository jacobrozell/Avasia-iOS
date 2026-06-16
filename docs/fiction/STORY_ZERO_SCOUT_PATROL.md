# Story 0 — The Scout Patrol (design spec)

> **Status:** Design only — does **not** replace KoN or SoC openings.
> Archived from found author notes; expanded with Many Hands + schism lore.
> See [`../LORE_ARCHIVE.md`](../LORE_ARCHIVE.md) §2.1 · [`../VASHIRR.md`](../VASHIRR.md).

---

## Position in the saga

| | KoN / SoC (shipped) | Story 0 (this spec) |
|---|---|---|
| **When** | Age era, canonical | **Before or beside** — pre-Oceandale strike, or anthology branch |
| **PC** | Mage (KoN) / Druid (SoC) | **Scout** — Kaefden, Agromanian, or neutral border patrol |
| **Vashirr** | Off-screen → on-stage villain | **First meeting** — fork: report or follow |
| **Format** | Full games | Short intro adventure (30–45 min text) |

Story 0 is the **alignment prologue** for a future anthology layer (faction points,
Story #1 unlocks). It must **not** retcon Kaefden IV's arc.

---

## Premise

You are a **scout** on routine border patrol — Sylvian, Cataractan, or Kaefden
legion (author picks one; Sylvian fits Silvarium 20% stayers). You crest a ridge
and see an **Agromanian column** larger than any report admitted, led by a hooded
mage with a gray staff.

You recognize the sigil of **Nacastrum** mixed with Agromanian banners. Word on
the wind says his name is **Vashirr**.

---

## Act structure

### I — Ordinary duty
- Establish patrol, comrade, orders ("report, do not engage").
- Optional: mention Oceandale fishing traffic; elders' north migration; cold border.

### II — The sighting
- Army in valley — **Paladin prototypes** among them (early, fewer than SoC).
- Vashirr speaks to officers; player overhears **Many Hands** rhetoric:
  *"Magic for every gauntlet, not towers."*

### III — The approach
- Vashirr's scouts detect the player (or player stumbles into picket).
- Brought to him unharmed — he **wants** a messenger, not a corpse.

### IV — The sermon (religious beat)
Vashirr does not threaten first. He **converts**:

- Names the **schism** — Agroman from a prince's middle name; Kaefden order that
  never healed.
- Names **Nacastrum's cage** — mages above the war Oceandale already proved.
- Offers a vision: **one army, one law**, Paladins as honest soldiers.
- Asks: *"Will you carry truth to Aylova — or keep feeding a crown that rebuilds
  failure?"*

**Design rule:** From the PC's POV this should feel like **almost religious** —
 abandoning home, comrade, and name should cost as much as SoC's Cataracta loss.
 Only Vashirr's certainty makes it possible.

### V — The fork

| Choice | Path | Outcome |
|---|---|---|
| **REPORT** | White hat / Kaefden | Escape or send signal; warn Oceandale garrison; Story unlocks **Good #1** |
| **FOLLOW** | Black hat / Agroman | Walk down into camp; Vashirr marks you; Story unlocks **Bad #1** (*Walking with Vashirr*) |
| **REFUSE both** (optional third) | Neutral | Flee alone; hunted by both sides; neutral story track |

No choice is "game over" in Story 0 — each routes to a **different Story #1**
in the anthology economy ([`../ANTHOLOGY_ROADMAP.md`](../ANTHOLOGY_ROADMAP.md)).

---

## Key characters

| Name | Role |
|---|---|
| **Vashirr** | Sincere reformer; scar visible if unhooded; gray staff |
| **Patrol partner** | Emotional anchor — name them; REPORT path may lose them |
| **Sergeant / elder contact** | Who ordered the patrol; receives REPORT |

---

## Tone

- Earnest, no meta humor in the sermon beat.
- KoN-style humor only in Act I camp life (optional).
- Vashirr wins arguments on **logic**; Kaefden wins on **cost** — player chooses
  which horror they can live with.

---

## Canon ties

- **Agroman** = banished prince's middle name ([`../LORE_ARCHIVE.md`](../LORE_ARCHIVE.md))
- **Many Hands** = Paladin doctrine ([`../VASHIRR.md`](../VASHIRR.md))
- **Oceandale** = colony the army will strike if REPORT fails or arrives late
- **KoN PC** = different person years later (teacher mage, not this scout)

---

## Implementation notes (iOS / future)

- Separate **`AvasiaAnthology`** module or menu entry: *Stories* beside KoN / SoC.
- State: `alignment` (loyalist / agroman / neutral), `factionPoints`, `storiesUnlocked`.
- Story 0 sets flags only — no shared save with KoN protagonist stats.
- Estimated rooms: 8–12 (patrol camp, ridge, valley overlook, picket, Vashirr tent,
  fork epilogue).

---

## Acceptance criteria

- [ ] Player understands Vashirr's motive before choosing
- [ ] REPORT and FOLLOW both feel valid, not good/bad labels in prose
- [ ] No contradiction with KoN opening (amnesiac mage) or SoC (Druid volunteer)
- [ ] Unlocks documented in anthology manifest
