# Story 0 — The Scout Patrol (design spec)

> **Status:** Design only — does **not** replace KoN or SoC openings.
> Archived from found author notes; expanded with Many Hands + schism lore.
> See [`../LORE_ARCHIVE.md`](../LORE_ARCHIVE.md) §2.1 · [`../VASHIRR.md`](../VASHIRR.md).

---

## Position in the saga

| | KoN / SoC (shipped) | Story 0 (this spec) |
|---|---|---|
| **When** | Age era, canonical | **Days before Oceandale naval landing** — land column musters in parallel |
| **PC** | Mage (KoN) / Druid (SoC) | **Silvarium scout** — border patrol with partner Mira |
| **Vashirr** | Off-screen → on-stage villain | **First meeting** — fork: report or follow |
| **Format** | Full games | Short intro adventure (30–45 min text) |

Story 0 is the **alignment prologue** for a future anthology layer (faction points,
Story #1 unlocks). It must **not** retcon Kaefden IV's arc.

---

## Premise

You are a **Silvarium scout** on routine border patrol with partner **Mira**. You crest a ridge
and see an **Agromanian column** larger than any report admitted, led by a hooded
mage with a gray staff.

You recognize the sigil of **Nacastrum** mixed with Agromanian banners. Word on
the wind says his name is **Vashirr**.

---

## Locked design decisions (2026-06)

| Topic | Rule |
|---|---|
| **Timeline** | Valley land muster ≠ Oceandale naval strike; Good #1 is a race to the coast |
| **REPORT** | PC warns **Silvarium**; Vashirr may **want** an honest count (psyop/dread) and releases reporters on purpose |
| **REFUSE** | Vashirr orders pickets to stand down; PC is not hunted **in Story #0** — Elk Feast is truce-week breather |
| **Ridge agency** | `WITHDRAW` path skips capture; fork offers REPORT / REFUSE only (no FOLLOW without parley) |
| **Identity** | Vashirr reads **Sylvian kit + bark-strip cipher** — not omniscience |

---

## Act structure

### I — Ordinary duty
- Establish patrol, comrade, orders ("report, do not engage").
- Optional: mention Oceandale fishing traffic; elders' north migration; cold border.

### II — The sighting
- Army in valley — **Paladin prototypes** among them (early, fewer than SoC).
- Many Hands banners mixed with **Nacastrum blue**.
- Player may **WITHDRAW** and signal elders, or **CONTINUE** down into capture.

### III — The approach
- If captured: Vashirr's pickets escort both scouts — he **wants** a messenger, not a corpse.
- If withdrew: splitpath signal optional; fork without full sermon.

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
| **REPORT** | Loyalist | Warn Silvarium; camp exit beat; unlocks **Good #1** |
| **FOLLOW** | Agroman | Only if captured; Mira breaks away; unlocks **Bad #1** |
| **REFUSE both** | Neutral | Vashirr releases by order (captured) or ridge choice alone; unlocks **Elk Feast** |

No choice is "game over" in Story 0 — each routes to a **different Story #1**
in the anthology economy ([`../ANTHOLOGY_ROADMAP.md`](../ANTHOLOGY_ROADMAP.md)).

### VI — Camp exit
After the fork, alignment-specific release beat (`scoutCampExit`) before epilogue.

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
- Estimated rooms: patrol camp, ridge, withdraw, signal, picket, Vashirr parley,
  fork, camp exit, epilogue.

---

## Acceptance criteria

- [x] Player understands Vashirr's motive before choosing
- [x] REPORT and FOLLOW both feel valid, not good/bad labels in prose
- [x] Ridge withdraw path respects "observe, do not engage"
- [x] Camp exit beat for each alignment
- [ ] No contradiction with KoN opening (amnesiac mage) or SoC (Druid volunteer)
- [x] Unlocks documented in anthology manifest
