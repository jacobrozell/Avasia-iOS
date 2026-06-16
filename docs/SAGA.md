# The Avasia Saga — Series Bible

> Cross-game vision: how the Avasia games fit together across story eras and
> how the **real engine** evolves to mirror in-world technological progress.
>
> Game-specific docs:
> - [KoN story](../STORY.md) · [KoN engine](../ENGINE_SPEC.md)
> - [SoC story](sequel/STORY.md) · [SoC roadmap](sequel/ROADMAP.md)
>
> **Holy canon:** §0 — saga pillars locked by author intent. Do not contradict in
> new prose, games, or anthology without an explicit saga-level decision.

---

## 0. Sacred pillars *(holy canon — do not break)*

> These are the **main sauce** of the Avasia saga. Details in §8 may be refined;
> these pillars may only change via a deliberate entry in §7 (decision log).
> When in doubt, protect the pillar and adjust surface lore around it.

### The anchor law

**Power in Avasia must be anchored** — sky, earth, flesh, or civic. It cannot
float free. Every game is a different *container* for the same law; Age-era
choices become post–Age **infrastructure** (Mistborn-style continuity).

### The duology argument

**Restoration** (Kaefden — consent, towers, law) vs **Many Hands** (Vashirr —
magic in every shield). Vashirr is defeated in SoC; **his argument is not**.
The coalition inherits what worked militarily.

### Survivor's legend

The **SoC protagonist lives**. Game 3 inherits their **myth** (broadsheets,
reliquaries, propaganda) — not a resurrection boss or betrayal of the player's
save file. Horror comes from **the system**, not from undoing SoC's victory.

### The trilogy question

```text
ERA 1 (KoN)  — Where is magic ALLOWED to live?
ERA 2 (SoC)  — Who can be FORCED to carry it?
ERA 3 (2D)   — Who can AFFORD to spend it?
```

Age era = **two text games only** (KoN + SoC). SoC must **close the war** and
**redistribute anchors** — not a text cliffhanger. Game 3 is the first **2D** era.

### The Commodity Era

Post–Age working name: **Commodity Era**. **Anula** is scarce **currency and
magic fuel**. Social commentary emerges from **playable tradeoffs** (mines,
debt, company towns, crystal lines) — not narrator sermons. Magic on the price board.

### Flesh magic cannot be fully banned

Licensed **Flesh-Wardens** (rotated, rationed) coexist with black-market rites.
**Partial ban breeds cults.** Each binding leaves an **echo**; unregulated stacking
erodes the mind — the **Red Litany** and kin are Many Hands **without order**, not
Vashirr's authorized program. Vashirr may reject them from his cell.

### The three-blade stack (game 3 horror)

```text
Anula economy    →  "You can't afford to be safe."
Flesh garrisons  →  "We keep you safe but never say what it costs us."
Red Litany cults →  "Safety is a lie — bleed and be free."
```

### Royal continuity

**Kaefden IV = KoN protagonist.** The duology's hidden symmetry is non-negotiable.

### What we never do

- Redeem Vashirr in the Age-era finale.
- Resurrect the SoC PC as game 3's villain.
- Introduce a third text adventure for the Age era.
- Replace anchor law with unrelated magic systems per game.

**Deep reference:** §8 (anchor types, economy, cults, consequence ledger).

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

**Age era = two text games only.** KoN and Blade of Courage tell the full
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

### Game 2 — *Avasia: Blade of Courage*

| | |
|---|---|
| **Protagonist** | Named Druid recruit in Cataracta |
| **Timeline** | **Seven years** after KoN (Oceandale's fall and Kaefden IV's coronation); no Agromanian invasion since, until Vashirr's Paladins force the issue |
| **Arc** | Enlist → fall of Cataracta → warn Kaefden IV → **win the coalition war** and secure neutral allies via **Kaefden's Blade of Courage** |
| **Antagonist** | Vashirr (Agromanian king's right hand; forging Paladins) |
| **Status** | Python prototype + iOS Act IV campaign; Silvarium / Varatro Falls arc planned |

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
— see **§8.6** (Ring Roads, crystal lines, surveyed continent).

SoC's ending should leave Avasia in a **stable post-war state** with **anchor
redistribution** (§8.5) so game 3 can jump forward without requiring text game 3
to fill gaps.

---

## 4. Technology progression (fiction ↔ engine)

| In-world signal | Engine shift |
|---|---|
| Age of mages, oral tradition, letters | Text parser, sentence-by-sentence pacing (KoN) |
| War mobilization, maps, legions | RPG stats, authored combat set pieces (SoC) |
| **End of Age era** — SoC finale | Richest text systems; war resolved in prose |
| **New era begins** — game 3 | 2D tile engine, visible geography |
| Later eras | TBD |

Anchor law and era containers: **§8**. Pick game 3's primary in-world invention
when that project is scoped (§8.6).

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

## 6. Title — Game 2

**Canonical:** *Avasia: Blade of Courage*

The title names **Kaefden's Blade of Courage** — the first king's sword buried at
**Varatro Falls**, recovered to win the neutral city (**Ofelos**) through the
**Silvarium elders**. Personal virtue and the soldier's journey stay central; the
Blade is the ultimate symbol of honor the coalition needs.

| Former / alternate | Notes |
|---|---|
| *Blade of Courage* | Prototype working title; superseded 2026-06-15 |
| *Legion of Cataracta* | Faction framing — optional subtitle |
| *Kaefden's War* | Emphasizes duology tie-in |

---

## 7. Decision log (saga-level)

| Date | Decision |
|---|---|
| 2026-06-15 | Kaefden IV = KoN protagonist |
| 2026-06-15 | SoC scope = **full war**, not just messenger Act III |
| 2026-06-15 | Cataracta **may be revisitable** later in SoC |
| 2026-06-15 | Combat must vary by encounter — not a grind chore |
| 2026-06-15 | Title: *Blade of Courage* (working; superseded) |
| 2026-06-15 | **Title: *Blade of Courage*** — matches Varatro Falls relic quest |
| 2026-06-15 | **Timeline: 7 years since KoN** — Oceandale fell in game 1; long peace, then Paladin escalation |
| 2026-06-15 | **Revised:** Age era = **2 text games only** (KoN + SoC) |
| 2026-06-15 | **Revised:** Game 3 = **first 2D game** (post–Age era), not text |
| 2026-06-15 | **Found lore merged** — Agroman middle name, Silvarium/Suformin, Oceandale colony, cave prison; see [`LORE_ARCHIVE.md`](LORE_ARCHIVE.md) |
| 2026-06-15 | **Anchor law** (working) — unified magic thesis for cross-era continuity; see §8 |
| 2026-06-15 | **Survivor's legend** — SoC PC lives; game 3 inherits myth, not resurrection-boss |
| 2026-06-15 | **Era handoff** — SoC must redistribute how magic is anchored, not only defeat Vashirr |
| 2026-06-15 | **Commodity Era** (working name) — post–Age era where **Anula** is scarce currency + magic fuel; see §8.10 |
| 2026-06-15 | **Flesh-anchor persistence** — Paladin rites can't be fully banned; unregulated use breeds cult madness; see §8.11 |
| 2026-06-15 | **Sacred pillars locked** — §0 holy canon; saga sauce protected from casual retcon |
| 2026-06-15 | **KoN foreshadowing pass** — Anula, anchors, proto-Paladin; see [`FORESHADOWING.md`](FORESHADOWING.md) |
| 2026-06-15 | **SoC epilogue seeds** — commodity debt, chain line, chaplain; game 3 opening sketch in [`sequel/GAME3_OPENING.md`](sequel/GAME3_OPENING.md) |

---

## 8. Magic, anchors & eras *(expands §0 — refine details, not pillars)*

> **Holy summary:** §0. This section is the **working bible** for implementation:
> names, tables, open questions. Pillars are locked; specifics (cult proper noun,
> Anula wallet rules, era spelling) may iterate here without breaking §0.

### 8.1 The anchor law (one sentence)

**Power in Avasia must be *anchored* — it cannot float free.** Every working
spell, relic, or soldier-trick binds magic to a **vessel**. The Age War was fought
over *which anchors win*, not over whether magic exists.

When Nacastrum was scattered, magic **left the tower** and entered the marketplace —
first as refugees and legions, then (post-war) as roads, garrisons, and mines.

### 8.2 Four anchor types (Age era)

| Anchor | Tradition | In KoN / SoC | Who controls it |
|---|---|---|---|
| **Sky** | Malkos / mage academies | Levitate, Inflame, Stonebend; floating Nacastrum; **Rings of Malkos** | Councils, heirs, Kaefden crown |
| **Earth** | Druids / Sylvians | Shapeshifting; **Anula** crystals; Great Tree; Stonebend seal | Elders, Kimious's line, Silvarium |
| **Flesh** | Many Hands | **Paladins** — magic bound into plate and chant | Vashirr; Agromanian war machine |
| **Civic** | First Kaefden | **Blade of Courage** at Varatro Falls; oaths, memorials, coalition law | Ofelos elders; public honor |

**Rings of Malkos** = sky-anchors turned into **fixed geography** (teleport nodes).
**Anula** = earth-anchor commodity (Silvarium → Cataracta gift chain).
**Paladins** = flesh-anchor at industrial scale — Vashirr's thesis made flesh.

KoN teaches anchors through **personal restoration** (sky). SoC stress-tests them
through **war** (flesh beats sky in open battle; civic Blade wins neutrals).

### 8.3 Philosophical war (the duology argument)

| Side | Voice | Claim |
|---|---|---|
| **Restoration** | Kaefden IV | Magic belongs in lineage, towers, law — *consent and council* |
| **Many Hands** | Vashirr | Magic belongs in every shield — *unity without mage priesthood* |

Vashirr is defeated in SoC; **his argument is not**. The coalition wins the war
while inheriting the proof that flesh-anchors work. Era 3 runs on that compromise —
and on what happens when **regulated** flesh-magic (garrisons) and **unregulated**
rites (cults) diverge (§8.11).

### 8.4 Trilogy spine

```text
ERA 1 (KoN)  — Where is magic ALLOWED to live?     (Towers. Heirs. Councils.)
ERA 2 (SoC)  — Who can be FORCED to carry it?      (Paladins. Legions. War.)
ERA 3 (2D)   — Who can AFFORD to spend it?         (Mines. Markets. Debt. Myth.)
```

**SoC ending requirement:** close the Vashirr arc *and* **redistribute anchors**
— a structural change to how power flows (see §8.5). Game 3 inherits wreckage and
synthesis, not a blank slate.

### 8.5 Age-era release (what SoC changes forever)

SoC's epilogue should imply (in prose, not a checklist UI) several **irreversible**
shifts. Exact emphasis TBD; all are compatible with survivor's legend:

| Release | Fiction | Era 3 scar |
|---|---|---|
| **Paladin techniques retained** | Coalition adopts garrison doctrine | Licensed **Flesh-Wardens**; illegal **Red Litany** cults (§8.11) |
| **Ring network opened** | Malkos nodes for legions, not mages only | **Ring Roads** — surveyed travel between nodes |
| **Anula commodified** | Wartime requisition → peacetime trade | **Commodity Era** — Anula as currency, magic, and political leverage (§8.10) |
| **Ofelos in the system** | Neutrals marched with the Blade | Neutrality eroded; new taxes or draft law |
| **Messenger myth** | Living SoC PC honored; legend weaponized | Broadsheets, reliquaries, Paladin "saints" |
| **Vashirr bound, not redeemed** | Imprisoned; doctrine leaks | Prison pilgrimages; cults claim his scar as sacrament |

### 8.6 Post–Age era — the **Commodity Era** & why game 3 is 2D

**Working era name:** **Commodity Era** — the age after courage, when earth-anchor
power is weighed, priced, and spent.

The **parser Age** (oral tradition, letters, room-by-room revelation) ends when
the continent becomes **legible** — charted, priced, networked. Game 3 is 2D
because players now move through a **mapped economy**: towns, mines, markets,
and crystal relay towers are visible geography, not rooms described one line at a time.

| Layer | Role in Commodity Era |
|---|---|
| **Primary — Anula economy** | Scarce blue crystal is **money and magic**; scarcity drives plot |
| **Secondary — Crystal lines** | Anula relay towers along trade routes; news, contracts, surveillance |
| **Tertiary — Ring Roads** | Surveyed paths between Malkos nodes; cheap bulk travel for ore and troops |
| **Atmosphere** | Broadsheets, garrisons, company towns, debt ledgers |

Engine rule: **fiction justifies the format leap** — same anchor law, new container.
Full economic design: **§8.10**.

### 8.7 Saga consequence ledger (carry-forward pillars)

Track ~5–7 pillars across games (save-import optional; lore must reference them):

| Pillar | KoN / SoC seed | Era 3 echo (examples) |
|---|---|---|
| Nacastrum restoration depth | Mages return through portal | Sky-city prominence vs grounded academies |
| Throne recount style | Honor Dentros vs report facts | How Messenger myth is told |
| Stonebend / Silvarium seal | Blood lock on Great Tree | Who owns earth-anchor keys |
| Vashirr's fate | Bound at redoubt | Prison, cult, leaked garrison rites |
| Ofelos commitment | Blade alliance | Neutral resentment, draft law |
| Cataracta destruction | Diaspora survivors | Druid culture in exile; ruins pilgrimage |
| SoC PC survival | Memorial by name | Living cameo vs propaganda reliquary |

### 8.8 Game 3 antagonism (survivor's legend)

Game 3 does **not** resurrect the SoC protagonist as a villain. Threats grow from
**what the war built**:

- Paladin reliquary or "saint" forged from Many Hands heresy
- Corrupted ring node or **Anula monopoly** (charter company, crown reserve, cartel)
- Institution mining Sylvian earth under Kaefden law while elders protest enclosure
- **Red Litany** cell unleashed in a company town or mine district (§8.11)

The horror is **the system**, not a betrayal of the player's save file. Economic
pressure (Anula) and flesh-madness (cults) are **two blades of the same war debt**.

### 8.10 Anula & the Commodity Era *(working — social-economic spine)*

> **Tone goal:** systemic critique through **playable tradeoffs**, not sermonizing.
> The world should feel unfair in recognizable ways; NPCs disagree on fixes.

#### What Anula is

**Anula** is blue earth-anchor crystal — the same mineral on Cataracta's gates,
Suformin's dagger metal, mage pendants, and Silvarium shrine gifts. It **stores**
earth-anchor charge. In the Age era it was **gift, ornament, and ritual** (cartloads
from Sylvians to allies; fountain coins; shrine light).

After the coalition war, requisition and mine charters turn it into **the continent's
scarce resource** — simultaneously:

| Use | Fiction |
|---|---|
| **Currency** | Cut, graded, and stamped shards trade like coin; crown charters set weight standards |
| **Magic fuel** | Spent to power earth-anchor work — druid shifts, relays, ward-stones, some garrison rites |
| **Industrial input** | Crystal lines, street lamps, survey beacons, Paladin plate maintenance |

**Scarcity is real.** Anula forms slowly in living stone; deep mines are dangerous;
Silvarium's elders remember when it was **gift**, not **goods**.

#### Age era → Commodity Era pipeline

| Phase | Anula's role | Player feels |
|---|---|---|
| **KoN** | Sacred material on gates and relics; druid gift lore | Wonder; "blue means true power" |
| **SoC** | Fountain luck blessing; wartime **requisition** from Sylvian stocks | Home destroyed; war consumes everything |
| **SoC epilogue** | Kaefden speech implies peacetime **trade law** and coalition debt | Victory has a price tag |
| **Commodity Era (game 3)** | Standard currency; magic costs money; mines and lines map the world | Every spell is a budget choice |

The duology plants the turn: Vashirr wanted magic in every hand; the Commodity Era
delivers magic in every **wallet** — still unequal, now legible on a ledger.

#### The dual spend (core game 3 tension)

Earth-anchor magic **consumes** Anula (dust, shard, or charge). Money **is** power.

- Light a ward for the night → skip a meal's worth of crystal.
- Afford a druid heal → miss rent.
- Garrison officers draw rations from crown reserves; migrants sell heirlooms to eat.

This is the hour-one lesson for game 3 players: **you are not choosing spells; you
are choosing what not to buy.**

#### Social commentary (embedded, not preached)

Parallels to extractive capitalism are **intentional** but should emerge from systems
and NPC arguments — not narrator lectures.

| Fiction | Real-world echo (author intent) |
|---|---|
| Sylvian **gift economy** enclosed into mines | Commons privatized; indigenous / communal land vs charters |
| **Company towns** at mine mouths | Single employer owns wages and housing |
| **Crystal lines** carry prices and propaganda faster than truth | Information speed + market manipulation |
| **Paladin garrisons** funded by Anula tax | Security state paid for by the poor |
| **Messenger myth** on broadsheets while the real veteran struggles | Hero worship vs neglected veterans |
| **Black-market dust** and unsafe mining | Illicit labor, environmental sacrifice zones |
| Crown **reserve standard** (Kaefden backs notes with vault Anula) | Gold standard / central bank politics |
| Rich buy magic education; poor sell crystals to survive | Access inequality, credential gates |

**No faction is a clean author mouthpiece.** A Sylvian elder opposes mines but
benefited from wartime requisition. A Kaefden reformer wants public wards funded
by tax. A mine boss employs refugees from ruined Cataracta. Let the player pick
who sounds right and still feel the cost.

#### Who controls supply (faction hooks)

| Actor | Posture |
|---|---|
| **Silvarium elders** | Sacred enclosure; oppose open-pit mining near the Great Tree |
| **Kaefden crown** | Charter law, reserve vault, garrison requisitions |
| **Ofelos merchants** | Neutral no longer — finance lines and debt instruments |
| **Agroman remnants** | Western pits reopen under treaty labor; old grudges, new contracts |
| **Cataracta diaspora** | Miners, smugglers, druids who remember when crystal was tossed in fountains |
| **Cartels / dust-runners** | Black market when crown cracks down |

Game 3 antagonists grow from **who owns the scarcity** — not a dark lord who ignores economics.

#### Crystal lines (secondary infrastructure)

Relay towers burn **small** Anula charges to flash messages between cities —
market prices, warrant notices, war memorial announcements, Messenger propaganda.

- Lines make the economy **fast** (Mistborn's railroads as information + freight).
- Ring Roads move **bulk** ore and troops between Malkos nodes more cheaply.
- Together they explain a 2D map: **nodes** (cities, mines, relays) and **routes** (roads, lines).

#### SoC epilogue seeds (prose targets)

When revising SoC's ending, thread 1–2 lines that pay off here without info-dumping:

- Thekia or Kaefden mentions **coalition debt** to Sylvian stocks and western pits.
- A memorial merchant already sells **crystal shavings** "for the cause."
- Optional: a veteran complains that **honor doesn't grade Anula**.

#### Game 3 player fantasy

A new protagonist — dock clerk, mine surveyor, courier, diaspora druid — navigates
a continent where **magic is on the price board**. They may intersect the **survivor's
legend** (living Messenger or myth on every broadsheet) without being them.

Victory is not slaying a boss alone; it is **breaking, reforming, or escaping** a
system that prices courage by the gram.

### 8.11 Flesh-anchor, garrisons & the Red Litany *(working)*

> **Inspiration note:** Warhammer-style blood-cult horror — minds broken by power
> they invited into their bodies — but **rooted in Many Hands**, not a pasted-in
> chaos god. The "deity" is optional in-world; the **anchor echo** is the real monster.

#### Why flesh magic cannot be banned

After SoC, Kaefden law **must** keep some form of Paladin craft:

| Reason | Fiction |
|---|---|
| **Military arithmetic** | Flesh-anchors still beat sky-mages in a street fight; borders face Agroman remnants and bandit states |
| **Anula scarcity** | Earth-magic costs crystal; poor garrisons cannot ward every road |
| **Sky gates** | Mage towers cannot staff every village; Rings are strategic nodes, not patrol beats |
| **Political debt** | Western treaty forces employ Agroman veterans who already know the rites |

A full ban would leave the continent **defenseless** or hypocritical — the coalition
won using captives' techniques and scattered manuals. So the crown licenses
**Flesh-Wardens** (regulated garrison Paladins): rotated service, rationed binding
chants, crown chaplains, mandatory rest cycles.

**The ban is partial by design** — and partial bans breed black markets.

#### The cost (why cultists lose their minds)

Flesh-anchor magic binds power to **living tissue** — blood, scar tissue, chant-
grooved lungs, plate fused to skin. Each rite leaves an **echo**: a feedback loop
in the body that whispers the next verse of the binding.

| Exposure | Effect |
|---|---|
| **Licensed Warden** (low) | Numbness, nightmares, shortened lifespan; managed by rotation |
| **War surplus** (medium) | Compulsive repetition of training chants; veterans who "still hear the plate" |
| **Unregulated binding** (high) | Identity erosion — victim hears **many voices** in the scar; rage, euphoria, dissociation |
| **Deep cult rites** (extreme) | Subject becomes a **vessel** — tactical genius or berserk animal; rarely both for long |

This is not random corruption; it is **stacked anchors without release**. Vashirr's
Paladin program industrialized the first rung; cults chase the last rung seeking
power **without Anula** and without crown leash.

Kaefden's counter-argument in the Age era — *consent and council* — becomes Era 3's
question: **who consented to the echo in your blood?**

#### The Red Litany (working cult name)

Underground cells that worship or exploit the **echo** — the sensation cultists
describe as *"the warmth under the skin when the Many finally speak."*

| Trait | Detail |
|---|---|
| **Origin** | Leaked Paladin manuals; Vashirr prison sermons smuggled on broadsheets; deserter garrisons; Agroman war shrines |
| **Theology (their claim)** | Anula and towers **lie**; truth is blood; the echo is the continent's real god waking |
| **Visual** | Self-scarring in patterns like Vashirr's eye-scar; red thread stitched through plate; bare hands painted |
| **Behavior** | Chant in unison until sync breaks minds; sacrifice binding to "feed" the echo; frenzy assaults on mines and relays |
| **Not Vashirr** | He believed in **order** — one army, one law. Cults are Many Hands **without the general**: pure appetite |

Vashirr may **reject** them from his cell — still a believer, not a beast. That
contrast is useful: the ideology was sincere; the cult is what happens when the
ideology escapes pharmacy and becomes addiction.

**Alternate in-world names** (pick one later): *Unbound Hands*, *Scar Communion*,
*the Warm Below*.

#### Three-way tension (game 3 horror stack)

```text
ANULA economy     →  "You can't afford to be safe."
FLESH garrisons   →  "We keep you safe but never say what it costs us."
RED LITANY cults  →  "Safety is a lie — bleed and be free."
```

The player should meet **sympathetic Wardens** (broken, rotating, conscripted) and
**tragic cultists** (miners who tried one rite to survive a pit collapse) before
fighting true believers.

#### Commodity Era crossover

| Link | Story |
|---|---|
| **Anula vs flesh** | Cults recruit where crystal prices spike — "why buy blue when your veins are free?" |
| **Company towns** | Mine bosses hire Wardens; cults sabotage lines to crash prices |
| **Messenger myth** | Broadsheets call cultists "Paladin deserters"; veterans know the chant |
| **SoC survivor** | May have seen courtyard binding; recognizes the chant in a mine riot |

#### SoC seeds (prose targets)

- A garrison chaplain warns recruits: *"The chant stays in the plate when you take it off."*
- Post-redoubt rumor: some Paladins **liked** the echo — first deserters.
- Kaefden's speech: *"We will use what we must, and chain what we can."* (moral compromise on the record)

#### Writing rules

1. **Licensed Wardens are not cultists** — show rotation, trauma, and orders they hate.
2. **Cult horror is psychological first** — echolalia, dissociation, then gore.
3. **No redemption for deep vessels** — by the time they're boss-tier, the person is gone.
4. **Vashirr is not their god-king** — unless you want a late-game misinformation beat.
5. Keep **distinct from Anula plot** — economy starves; flesh cult **seduces** the starving.

### 8.9 Open questions (next iteration)

- [x] Name the post–Age era → **Commodity Era** (working)
- [x] Primary game 3 spine → **Anula economy**; crystal lines secondary; Ring Roads tertiary
- [ ] Exact Anula mechanics in game 3 (wallet + spell fuel unified or separate meters?)
- [ ] Mining geography — new western pits vs Sylvian border conflict
- [ ] Does Kaefden IV live to Era 3, abdicate, or become historical figure on currency?
- [ ] Hard rules: flesh-anchor **echo** thresholds — how many rites before personality loss?
- [ ] Cult proper noun: **Red Litany** vs Unbound Hands vs Warm Below
- [ ] Agroman faction post-war — defeated, partitioned, or integrated labor force?
- [ ] In-game primer: commodity tutorial in first town (market board, ward price, rent due)
- [ ] How blatant should real-world parallels be in NPC dialogue vs environmental storytelling?
