# The Avasia Saga — Series Bible

> Cross-game vision: how the Avasia games fit together across story eras and
> how the **real engine** evolves to mirror in-world technological progress.
>
> Game-specific docs:
> - [KoN story](../STORY.md) · [KoN engine](../ENGINE_SPEC.md)
> - [SoC story](sequel/STORY.md) · [SoC roadmap](sequel/ROADMAP.md)

---

## 1. The big idea

Avasia is a **long-running saga** where each major era can ship in a **different
game format**. As time advances inside the fiction, technology advances too, and
each new era justifies a new engine:

| Era (working) | Games | Player format | Engine |
|---|---|---|---|
| **Age era** | 1 · 2 | Text adventure | Parser + rooms (Python → Swift) |
| **Next era** | 3 | **2D** (first visual game) | Tilemap / sprite engine |
| **Future eras** | TBD | TBD | Whatever the world demands |

The meta-promise to the player: *you are living through the history of Avasia, and
the way you play changes as the world modernizes.*

**Age era = two text games only.** KoN and Sword of Courage tell the full
text-based chapter. There is no third text adventure.

---

## 2. Age era — two text games

### Game 1 — *Avasia: King of Nacastrum*

| | |
|---|---|
| **Protagonist** | Amnesiac mage (Kaefden heir) |
| **Arc** | Recover memory, restore Nacastrum, expose Vashirr, reunite the mages |
| **Ending** | Crowned king; mages return through the portal; *"Let us go, my king."* |
| **Status** | Original complete; iOS remake in progress (`Sources/AvasiaEngine/`) |

### Game 2 — *Avasia: Sword of Courage*

| | |
|---|---|
| **Protagonist** | Named Druid recruit in Cataracta |
| **Timeline** | Six months after Oceandale |
| **Arc** | Enlist → fall of Cataracta → warn Kaefden IV → **fight and conclude the full war** against Vashirr and the Agromanians |
| **Antagonist** | Vashirr (now openly teaching Agromanian mages) |
| **Status** | Python prototype ~30% (`Avasia-SoC/`); stops at throne-room stub |

**Royal continuity:** **King Kaefden IV is the KoN protagonist.** The SoC Druid
delivers Vashirr's message to the same king the player crowned in game 1.

**Age-era closer:** SoC must **finish the text-era story** — the war resolves here
(Vashirr arc, factions, cost of the conflict). It sets up the *world* game 3
inherits, not an unfinished text cliffhanger.

---

## 3. Game 3 — first 2D game

| | |
|---|---|
| **Format** | **2D** — exploration, movement, and combat on a visual plane |
| **Era** | Opens the **post–Age era** in-world (technology and society have moved on) |
| **Scope** | TBD — new protagonist generation, new regions, new threats or aftermath |
| **Status** | Not started |

Game 3 is the **format leap**, not a third text chapter. Towns and battlefields are
rendered, not described. The fiction should explain why the world now "plays" in 2D
(printing, maps, gunpowder, or whatever fits when you design it).

SoC's ending should leave Avasia in a **stable post-war state** (or a clear new
status quo) so game 3 can jump forward without requiring text game 3 to fill gaps.

---

## 4. Technology progression (fiction ↔ engine)

| In-world signal | Engine shift |
|---|---|
| Age of mages, oral tradition, letters | Text parser, sentence-by-sentence pacing (KoN) |
| War mobilization, maps, legions | RPG stats, authored combat set pieces (SoC) |
| **End of Age era** — SoC finale | Richest text systems; war resolved in prose |
| **New era begins** — game 3 | 2D tile engine, visible geography |
| Later eras | TBD |

Document the in-world "invention" that justifies 2D when game 3 is designed.

---

## 5. Playable characters across the saga

| Game | PC | Lens |
|---|---|---|
| KoN | Mage (amnesiac → Kaefden IV) | Personal destiny, restoration |
| SoC | Druid soldier | Ground-level war; Kaefden IV is NPC commander |
| Game 3 (2D) | TBD | New generation in a changed world |
| Future | TBD | Era dictates format |

KoN's protagonist appears in SoC as **King Kaefden IV**. The SoC player is a
witness and soldier — different face, same war.

---

## 6. Working title — Game 2

**Canonical for now:** *Avasia: Sword of Courage*

Alternatives if you want something that signals the duology or Druid POV:

| Title | Angle |
|---|---|
| *Sword of Courage* **(current)** | Personal virtue; soldier's journey |
| *Avasia: Legion of Cataracta* | Faction + military framing |
| *Avasia: The Druid's March* | POV + war movement |
| *Avasia: Ashes of Cataracta* | Opens on loss; darker tone |
| *Avasia: Kaefden's War* | Ties directly to game 1's ending |

No rename required — *Sword of Courage* holds up.

---

## 7. Decision log (saga-level)

| Date | Decision |
|---|---|
| 2026-06-15 | Kaefden IV = KoN protagonist |
| 2026-06-15 | SoC scope = **full war**, not just messenger Act III |
| 2026-06-15 | Cataracta **may be revisitable** later in SoC |
| 2026-06-15 | Combat must vary by encounter — not a grind chore |
| 2026-06-15 | Title: *Sword of Courage* unless a better fit emerges |
| 2026-06-15 | **Revised:** Age era = **2 text games only** (KoN + SoC) |
| 2026-06-15 | **Revised:** Game 3 = **first 2D game** (post–Age era), not text |
