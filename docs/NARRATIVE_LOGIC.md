# Avasia — Narrative Logic Tracker

> Open continuity questions, proposed canon answers, and where to plant them.
> Companion to [`FORESHADOWING.md`](FORESHADOWING.md) (saga seeds) and
> [`STORY.md`](STORY.md) (story bible). **Do not ship new prose until a row is
> marked *Decided*.**
>
> Cross-refs: [`VASHIRR.md`](VASHIRR.md) · [`fiction/CHARACTERS.md`](fiction/CHARACTERS.md) ·
> [`SAGA.md`](SAGA.md) §8.3

---

## Status key

| Status | Meaning |
|---|---|
| **Open** | No author decision; players can spot the hole |
| **Proposed** | Working answer below — needs sign-off |
| **Decided** | Canon locked; implementation may still be pending |
| **Shipped** | In game text |

---

## KoN opening cluster

### 1. Why does the MC wake on Oceandale beach?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | Memory ends in Nacastrum courtyard; intro opens on the shore. No transit. |
| **Current text** | Intro: *"alongside a beach"* · Memory: *"last thing you remember before you woke up on the beach"* (`RoadRooms.swift`) |
| **Proposed canon** | Vashirr's scatter light **hurled** banished mages to fixed **sky-anchors** on the ground — fishing colonies and civic shores, not random wilderness. Oceandale was the nearest anchor south of Nacastrum. |
| **One-line fix** | *"The light that scattered Nacastrum did not gentle you down — it threw you to the nearest shore-anchor, where Agroman had already struck."* |
| **Plant in** | Memory flash (Ring of Malkos) · optional beach LOOK · Thekia magehouse (scatter exposition) |
| **Impl. gap** | `appendIntro()` + `KoNBeachFlavor.awakeningLines()` duplicate the wake-up; see #2 |

---

### 2. Double beach awakening (intro vs. first SOUTH)

| | |
|---|---|
| **Status** | Decided (implementation bug + lore) |
| **Problem** | `appendIntro()` wakes the player on the beach and walks them through the gate. `GameEngine.restart()` starts in `.oceandale`. First SOUTH fires `beachIntroShown` awakening again. |
| **Current text** | `GameViewModel.appendIntro()` · `OceandaleRooms` SOUTH → `KoNBeachFlavor.awakeningLines()` |
| **Proposed canon** | Single wake-up on the beach; hub is entered **from** the shore, not in parallel. |
| **One-line fix** | N/A — structural: start in `.beach` **or** set `beachIntroShown = true` on new game **or** merge intro into `KoNBeachFlavor` and drop duplicate. |
| **Plant in** | `GameEngine.restart()` · `GameViewModel.startNewGame()` · `OceandaleRooms` |
| **Impl. gap** | Engine start room + intro ownership |

---

### 3. Scatter amnesia vs. Oceandale attack ("last week")

| | |
|---|---|
| **Status** | Decided |
| **Problem** | Guard says Oceandale was attacked *"last week."* MC amnesia is from the scatter. Were both the same week? Did the MC witness the raid? |
| **Current text** | Intro guard lore · `STORY.md` §2.4 (Oceandale falls **before** Vashirr scatters) |
| **Proposed canon** | **Two events, one week:** Agroman sacked Oceandale as a warning strike; Vashirr used the panic to scatter Nacastrum the same week. MC was unconscious on the shore for days — wakes after the raid, before memory returns. |
| **One-line fix** | *"The raid was last week. The sky falling was three nights ago. You lost the days between."* |
| **Plant in** | Gate guard (extend) · beach awakening · memory flash epilogue line |
| **Impl. gap** | `KoNGateGuardLore` / `appendIntro` |

---

### 4. Why did the MC stay near Oceandale instead of fleeing to Aylova?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | `STORY.md` §3 says they *"remained near Oceandale"* unlike most mages — never explained in-game. |
| **Current text** | Author note only |
| **Proposed canon** | Scatter **dumped** them on Oceandale; amnesia + grief paralysis. Others walked north to Aylova; the MC could not remember **why** they should. |
| **One-line fix** | *"Other mages limped toward Aylova. You could not remember your mother's face well enough to know which way hope lay."* |
| **Plant in** | Beach LOOK · Thekia first meeting (after Kaefden answer) |
| **Impl. gap** | `KoNBeachFlavor` · `MagehouseRoom` |

---

## Identity & antagonism cluster

### 5. What does "Kaefden heir" mean?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | `SAGA.md` calls the PC *"Kaefden heir"*; `CHARACTERS.md` says the crown must feel **earned, not inherited**. Blood seal opens for the PC, not Sylvian elders. Father's pendant in the King's Castle. No explicit lineage dump. |
| **Current text** | Worthy-blood motif · blood seal · ending *"my king"* |
| **Proposed canon** | **Not** the Aylova royal prince. **Heir to Restoration** — collateral **Malkos-lineage** mage blood (father's pendant = sky-anchor key), raised by the Academy at eight. Crown at KoN's end is **earned** by reopening Nacastrum, not birthright to Aylova. Name **Kaefden IV** = fourth Restoration king of the **mage polity**, aligned with but not identical to the Aylova crown. |
| **One-line fix** | *"Your father wore what kings of Nacastrum wore before Vashirr — not Aylova's crown, but the anchor that kept the sky-city honest."* |
| **Plant in** | Aylova pendant beat · blood seal LOOK · Thekia Nacastrum speech · `CHARACTERS.md` (lock after decide) |
| **Impl. gap** | `EndgameRooms` · `ForestRooms` seal · docs sync |

---

### 6. Was Vashirr afraid of the protagonist at scatter?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | Players infer Chosen-One targeting; memory says *"You among hundreds of mages."* |
| **Current text** | Mass scatter · father killed for running · `VASHIRR.md` teacher/student |
| **Proposed canon** | **No** — at scatter the PC is collateral. Vashirr's fear is **ideological** (Restoration, council nostalgia), sharpened **later** when the PC rebuilds Nacastrum (SoC *"boy-king"*). Personal hatred locks when he kills the father. |
| **One-line fix** | *"He did not hunt you. He hunted the city — and your father ran."* |
| **Plant in** | Memory flash (Thekia comfort after scream) · SoC redoubt (already partly there) |
| **Impl. gap** | `RoadRooms` post-memory · `SoCVashirrStandRoom` |

---

### 7. Who is Vashirr's scatter speech aimed at?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | *"Avasia cannot survive **your** nostalgia!"* — crowd sermon or personal address? |
| **Current text** | `RoadRooms.swift` line after father's death |
| **Proposed canon** | **Both:** shouted to the **crowd** (mages clinging to Nacastrum), but Vashirr's eyes find his **former star student** in the front — the teacher who still preached Restoration in his classroom. |
| **One-line fix** | *"He screamed it to the courtyard — but his scarred eye found yours."* |
| **Plant in** | Memory flash (one added line) · optional SoC redoubt callback |
| **Impl. gap** | `RoadRooms` |

---

### 8. Why was the mother taken through the portal?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | *"Women and children"* through Agromanian portals — mother's face singled out in the memory, but no reason **she** among hundreds. |
| **Current text** | Memory flash · Agromanian alliance at scatter |
| **Proposed canon** | **Political game + anchor law (merged):** The father was not Aylova royalty — he was the family's **ground-anchor**: a rooted Kaefden liaison the High Mage's Council required for sky-lineage heirs (see #5). His pendant registered the **sky–earth bond** (earth-crystal in silver). The mother held the **oath** that tied that bond to a civic shore — Oceandale. Vashirr's scatter was built to **break paired anchors**: sky mages hurled to shore nodes; **ground-oathed kin** dragged through Agromanian portals as hostages and early flesh-anchor stock. The father ran because he understood the game; Vashirr killed him to **sever the line publicly**. The mother was taken because she **was** the earth-side anchor — not random, not because the PC was hunted. |
| **One-line fix** | *"They took ground-oathed kin first — the anchors that kept sky-blood honest. Your mother wore that chain. Your father tried to cut it."* |
| **Also plant** | Pendant beat (#5) · trading-post merchant (parallel abduction) · Thekia: Council used ground houses to cage floating pride · SoC flesh-anchor intel (Paladin forge foreshadow) |
| **Impl. gap** | `RoadRooms` memory flash · `EndgameRooms` pendant · `STORY.md` §6 · `fiction/CHARACTERS.md` family table |
| **Open sub-question** | Where the mother is held (Agromanian camp? flesh-forge?) — **defer** to post–Age era or game 3; KoN only needs the *why*, not the rescue. |

---

### 8b. Was the father part of the political game?

| | |
|---|---|
| **Status** | Decided (folded into #8) |
| **Answer** | **Yes** — but as **anchor-bearer**, not crown prince. The Council's compromise: Nacastrum's floating pride had to keep **roots on the ground** (fishing colonies, civic oaths). Father maintained that root; pendant = key. Vashirr's coup targeted anchor-pairs to prove towers could not hold Avasia together. |
| **One-line fix** | *"He was never king — he was the weight that kept your sky from drifting."* |
| **Plant in** | Memory flash · King's Castle corpse · Thekia Nacastrum speech |

---

## World-state cluster

### 9. Why is Thekia's magehouse untouched?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | Oceandale is ruined; west house *"appears untouched, unmarked by the Agroman faction."* |
| **Current text** | `OceandaleRoom.describe` |
| **Proposed canon** | **Thekia's warding.** When she left Nacastrum she bound a **Levitate-anchored ward** to the house — Agroman torches slide off; raiders feel the threshold and turn aside. Not Vashirr's lure; her fingerprint on Oceandale, waiting for the heir she believed would wash ashore. Establishes her power before the door-slam scene. |
| **One-line fix (hub LOOK)** | *"Ash stops in a clean arc west of the magehouse, as if the air itself refuses the burn."* |
| **One-line fix (first enter)** | *"The ward still hums at the threshold — old magic, patient, yours almost by inheritance."* |
| **Plant in** | Oceandale LOOK · magehouse first `describe` (pre-Levitate) · optional: guard mentions fishers won't cross the ward line |
| **Impl. gap** | `OceandaleRooms` · `MagehouseRoom` |

---

### 10. Why doesn't the gate guard react to a washed-up amnesiac mage?

| | |
|---|---|
| **Status** | Decided |
| **Problem** | Guard delivers faction history to a stranger in blue robes with no questions. |
| **Current text** | `appendIntro()` |
| **Proposed canon** | Oceandale has seen **scattered mages** wash up all week; guard assumes another survivor. |
| **One-line fix** | *"Another one from the sky, eh? Blue robes, empty eyes — sit if you must. I'll tell you what happened while you still have ears to hear."* |
| **Plant in** | Intro guard beat · `KoNGateGuardLore` |
| **Impl. gap** | `GameViewModel.appendIntro()` |

---

## SoC / saga bridges (KoN holes that echo later)

| # | Question | Proposed answer | Plant in |
|---|---|---|---|
| 11 | Why does Vashirr message **Kaefden IV** specifically in SoC? | He recognizes his **failed student** who rebuilt Nacastrum — ideological rival, not random king. | SoC throne (existing) · courtyard sermon |
| 12 | Father's corpse in **King's Castle** — why there? | Father **broke into the castle courtyard** during scatter to reach mother; killed at the anchor threshold; body never moved; pendant = registered sky–earth key (#8). | Memory flash + `EndgameRooms` (one line each) |
| 13 | PC opens blood seal; elders cannot | Malkos-lineage mage blood, not Sylvian hunter line — foreshadows Restoration thesis. | Seal LOOK (exists) · librarian line (exists) — link explicitly in #5 |

---

## Implementation priority

| Priority | Item | Type |
|---|---|---|
| P0 | #2 Double awakening | Code + prose |
| P0 | #1 Beach transit | Prose (memory flash) |
| P1 | #3 Timeline (last week) | Prose (intro guard) |
| P1 | #5 Heir definition | Prose (pendant + Thekia) |
| P1 | #7 Scatter speech aim | Prose (one line) |
| P1 | #8 Mother's abduction + father anchor role | Prose (memory flash + pendant) |
| P1 | #9 Thekia warding | Prose (Oceandale LOOK + magehouse) |
| P2 | #10 Guard reaction | Prose polish |

---

## Changelog

| Date | Change |
|---|---|
| 2026-06-15 | Initial tracker — beach, scatter, heir, Vashirr targeting, implementation gaps |
| 2026-06-15 | **#8 decided** — ground-anchor political game + sky–earth bond; **#9 decided** — Thekia warding |
| 2026-06-15 | **Shipped** — P0/P1 prose + double-awakening fix (`KoNBeachFlavor`, gate guard, memory flash, magehouse ward, pendant, blood seal) |
