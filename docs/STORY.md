# Avasia: King of Nacastrum — Story Bible

> The canonical narrative reference for the iOS remake. This document captures
> the lore, plot, world, characters, and key scenes of the original game
> (`Avasia-KoN/GameDriver.py`, v. 4/3/17 by Jacob Rozell & contributors) as
> faithfully as possible. Where the original text sets the tone, it is quoted
> directly so the remake can reproduce it verbatim.
>
> Companion docs:
> - `ENGINE_SPEC.md` — how the game machinery works (state, parsing, rooms).
> - `WORLD_MAP.md` — the room/area graph and connections.

---

## 1. Tone & Voice

Avasia is an earnest high-fantasy tragedy told in second person ("You hear
waves...") with a deliberate streak of fourth-wall-winking, modern humor in its
fail states and dead ends. A faithful remake **must preserve both registers**:

- **Earnest:** the war, the banished mages, the murdered father, the dying town.
- **Meta/comic:** failure messages and dead-ends such as *"It's already lit
  fam,"* *"Items don't just appear out of thin air ya'know?,"* *"Care will
  prevent 9 out of 10 forest fires,"* the meaning-of-life answer of *"42,"* and
  *"Thanks for your honesty"* when the player types nonsense at a puzzle.

The prose is delivered sentence-by-sentence with an optional delay between lines
(see `ENGINE_SPEC.md` §"Text pacing"). The remake should keep this dramatic
pacing as a core feel.

---

## 2. The World of Avasia

**Avasia** is a continent once united under a single royal house, the
**Kaefden family**. It is home to several peoples:

- **Mages** — the player's people; pointed ears, blue robes. Part of the Kaefden
  faction. Lived in the floating city of **Nacastrum**.
- **Humans** — common folk found across the factions.
- **Druids** — shapeshifters (fox, wolf, elk forms) from the city of
  **Cataracta**; allied with the Kaefden/mages. Organized into class groups
  (hunters, healers, scouts). Serve their own paranoid king.
- **Barbarians** — a hostile northern people. Not a faction; a looming external
  threat. They nearly took Oceandale.

### 2.1 The Kaefden royal family & the great schism

Delivered in the intro by the old guard at the broken gate of Oceandale:

> *"Once all of Avasia was united under the Kaefden family."*
> *"But the youngest son of the king thirsted for power."*
> *"He began a protest in Kaefden's capital, Aylova, which quickly became violent."*
> *"The youngest son urged his father for the crown and spited him for his lack of leadership."*
> *"Together, the older brother and the king, banished him from all of Kaefden."*
> *"The king couldn't allow for this behavior to fall upon his citizens, or certain chaos would follow."*

> *"The younger brother built the Agromanian faction from the ground up."*
> *"Of course, many Kaefden people followed of all races. Mages, Humans, and Druids alike."*
> *"Although the brothers, and the king are long gone, the rivalry and the hatred still exist."*

### 2.2 The three factions

- **Kaefden** — the original royal/loyalist faction. *"The Kaefden faction
  believes in order and integrity."* Capital: **Aylova**. The Mages are Kaefden.
- **Agroman (Agromanian)** — founded by the banished youngest son. *"The Agroman
  faction today believes in brotherhood and loyalty."* The antagonist faction:
  they sacked the region around Oceandale, abduct and prey on travelers, and are
  secretly allied with Vashirr.
- **Neutrals / Ofelos** — *"There's a city who remains neutral in the matter;
  the city of Ofelos."* *"They believe that a united Avasia would benefit the
  people more than petty fighting."* The Neutrals reside in Ofelos.

### 2.3 Nacastrum and the mages

The Mages lived in **Nacastrum**, a **floating city**. Their current king is
**Vashirr** (crowned when the player was 13). Their first king was **Malkos**,
after whom the teleporter rings — the **Rings of Malkos** — are named. The mages
were governed in part by a secret **High Mage's Council**.

The central mystery: after the fall of Oceandale, Vashirr claimed to have heard
druid rumors that **Nacastrum was about to be attacked by the full force of the
northern barbarians**. He used his power to teleport/banish all of Nacastrum's
citizens; most fled east to Aylova. The Old Mage doubts this story:

> *"Vashirr didn't save you. His true intentions are certainly clouded. He
> scattered his people for a reason. All this seems to me, that he has sided
> with the Agromanians. The mages lived in a floating city... What real threat
> did the barbarians pose?"*

---

## 3. The Player Character

The player is an **amnesiac Mage** of the Kaefden people — pointed ears, blue
mage robes. They wake on the beach beside ruined Oceandale with no memory of how
they arrived. They are one of the banished citizens of Nacastrum, but unlike the
others who fled to Aylova, they remained near Oceandale.

The Old Mage recognizes the player as special:

> *"You recognize one of your own don't you? Mage to mage; Kaefden to Kaefden.
> But... YOU are lost, terribly lost."* … *"You might have what it takes."*

**True identity (revealed at the climax — see §6):** a mage who was taken from
his parents at age 8 to join the Academy, graduated, and became a teacher of
young mages. During Vashirr's banishment his **mother was abducted through a
portal** and his **father was murdered by Vashirr** for trying to save her.

**Goal:** unlock the gates to Nacastrum, restore the floating city, reunite the
scattered Mage people — and become **King of Nacastrum**.

---

## 4. Plot / Quest Arc

### Act I — Oceandale & the quest-giver
The player explores ruined Oceandale, then enters the untouched **magehouse** to
the west and meets the **Old Mage** (later named **Thekia**). She delivers the
lore, gives the spell **Levitate**, and sets the quest:

> *"This is your quest! You must unlock the gates to Nacastrum and unite our people!"*

### Act II — Gathering the spells
The player travels north through Oceandale to the **Splitpath**, the central hub.
To open Nacastrum's portal, the player must collect three more spells (plus tools
and clues), each hidden by the Old Mages and guarded by a puzzle:

- **Inflame** (fireball) — in the **mountain cave**, behind a 4-symbol rune
  puzzle whose clues are scattered across the cave's branches. Requires the
  **lantern** (from Dentros) to enter the dark cave.
- **Stonebend** (geo) — at the top of the giant tree in **Silvarium** (the
  forest-druid city). Requires **Suformin's Dagger** for a blood-seal ritual on
  the 4th-floor seal.
- Tools gathered along the way: **Long Sword** (graveyard), **Lantern**
  (Dentros), **Suformin's Dagger** (tree butcher), **Fishing Rod** (beach hut,
  optional).

### Act III — The road to Nacastrum
The **Western Road** north presents three obstacles in sequence:
1. **Agromanian ambush** — survivable only with **Inflame**. Every other choice
   eventually leads to death.
2. **Stone spires** roadblock — passable only with **Stonebend**.
3. **The memory bridge** — a dreamlike repetition of the mountain bridge; the
   player must counterintuitively **jump/swim into the water** to break the
   illusion, revealing floating Nacastrum overhead and the **Ring of Malkos**
   teleporter platform.

### Act IV — Return, reveal, activation
The player cannot operate the Ring alone, so returns for the Old Mage. She gives
the **Staff** (the key to the Rings of Malkos), and they escort together back to
the platform. She activates it; the player passes through and **regains all
memories** (the central reveal — see §6), then confronts the ruined city.

### Act V — The ending / win condition
The Old Mage reveals she is **Thekia** of the **High Mage's Council**. In the
King's Castle the player finds their **father's corpse** and takes his
silver-and-blue-gemstone pendant. Thekia opens a Ring of Malkos to **Aylova**,
rallies the banished mages, and they return through the portal to Nacastrum. The
city repopulates — mages and non-mages alike join the cause against Vashirr and
the Agroman.

There is **one canonical winning ending**. All other terminal outcomes are
deaths that restart the game (tracked by `deathcount`). The game ends with
Thekia's words:

> *"Thank you, for all you have done. None of this would have been possible
> without you. But there is work to be done. We have just started."*
> *"Let us go, my king."*

followed by *"Congratulations on completing the game!"* and credits.

---

## 5. Locations (Geography)

See `WORLD_MAP.md` for the full connection graph. Summary:

### Oceandale (starting city, ruined) — hub
NORTH → graveyard / upper town · EAST → ruined trading post · WEST → magehouse ·
SOUTH → beach.
- **Beach (south):** *"Distant ships sit along the horizon, fishing."* Stretch/
  yoga flavor; fishing if you carry the rod. The escorted Old Mage reminisces
  here.
- **Trading post (east):** burned. A grieving merchant: *"Trading post is
  closed, mage… The damn Agromanians burned my beloved store to the ground!
  …My wife, they took my wife!"*
- **Magehouse (west):** home of the Old Mage; the quest hub. Locks after the
  first visit until the player returns to begin the escort.

### Upper Oceandale / Graveyard
NORTH → northern gate (to Splitpath) · EAST → graveyard · WEST → church ·
SOUTH → back to Oceandale.
- **Church (west):** burned *"rustic church… dedicated to the matron God of the
  Ocean."* Flavor only.
- **Graveyard (east):** *"6-feet tall endless stack of bodies."* A soldier's
  corpse holds the **Long Sword**.

### Splitpath (central overworld hub)
NORTH → forest (Silvarium) · EAST → mountains (bridge) · WEST → Western Road ·
SOUTH → upper Oceandale. During the escort, only WEST (to Nacastrum) is valid.

### Mountain Region (east of Splitpath)
- **Bridge:** a chasm with a broken bridge — *"The bridge is impassable."*
  Crossing requires **Levitate** (jumping/swimming = death).
- **Mountain hub:** NORTH → cave entrance · EAST → Dentros · WEST → West
  Mountain · SOUTH → back across bridge.
- **West Mountain → Druidpath / Cataracta gate:** *"a huge stone gate, enriched
  with blue crystal shards."* Six druid hunters; the player must prove they are
  a mage (flash ears, Levitate, or Stonebend) to avoid the wolf. Chief
  **Cellious** turns them away — Cataracta itself is never entered.

### The Cave (inside the mountain)
- **Cave entrance:** pitch dark; needs the **lantern**. A flooded passage; swim
  through a hole to reach the main cavern. (Levitate here = death by stalactites.)
- **Main cave (mcave):** *"Enormous pink crystals illuminate the room."* Branches
  N, NE, NW, E, W, S(exit):
  - **N (ncave):** ancient archway with a 3-button rune gate; press symbol "%'"
    / "1" to open the way to the fireball room.
  - **Fireball room:** cracked pedestal; a **dead mage burnt to ash** in the
    corner. Solve the 4-symbol order (shuffled per game) to earn **Inflame**.
    Wrong 3 times = burned alive.
  - **E cave:** gives the **4th** symbol clue.
  - **W cave / fork:** dripping blood, gashed/bitten corpses; left dead-end gives
    the **1st** symbol clue.
  - **NW cave:** a murdered miner amid translucent shards; optional pickaxe
    (mining = death by spear). Gives the **2nd** symbol clue.
  - **NE cave:** hanging cages with a skeleton; Levitate up to read parchment for
    the **3rd** symbol clue.

### The Forest / Silvarium (north of Splitpath)
- **Forest entrance:** overgrown grass; cut with the **sword** (and you also need
  Levitate on the canonical path) to pass.
- **Forest trap (ftrap):** a net trap sprung by a **Sylvian marksman** (Kaefden
  ally) who frees the player and guides them in.
- **Silvarium (mforest):** *"an enormous tree, much larger than all the others"*
  with suspended houses and bridges. The Sylvians are forest-druid Kaefden who
  received a spell-gift from the mages, sealed by their Elders.
- **The Great Tree (4 floors):**
  - **Floor 1:** game-drop-off tables; the boy **Marlux**.
  - **Floor 2:** LEFT **butcher** (gives **Suformin's Dagger** in a chest); RIGHT
    **armory** (a guard bars entry — Sylvian-only).
  - **Floor 3:** LEFT **Church of Suformin** (priestess, shrine); RIGHT
    **library** (the librarian in a fox coat).
  - **Floor 4:** the **blood seal** — crossed daggers in a target symbol. Cut
    yourself with **Suformin's Dagger** (the sword does nothing; cutting your
    neck = death) to open the hidden chamber and learn **Stonebend**.

### Western Road (west of Splitpath → to Nacastrum)
NORTH → road to Nacastrum (danger) · WEST → Shoreside · EAST → back to Splitpath.
- **Shoreside:** a quiet beach with an **abandoned beach hut** containing the
  **Fishing Rod**; shore for fishing/yoga. Fishing (here and at the Oceandale
  beach) has random outcomes (golden fish, crab monster, sea-serpent death after
  repeatedly catching the useless "orange fish").
- **Road to Nacastrum:** the sequential gauntlet — Agromanian ambush → stone
  spires → memory bridge → **Teleporter platform (Ring of Malkos)** beneath
  floating Nacastrum.

### Nacastrum (the floating city — endgame)
*"Nacastrum, Floating city of the Mage."* Silver streets, towering mage towers,
ransacked houses. The **King's Castle** holds the throne room and a courtyard
Ring of Malkos where the father's corpse is found.

### Aylova (capital of Kaefden — final scene)
*"We are in the capital of Kaefden, Aylova. Many of the mages that were banished
came here for safety."* Bigger than Nacastrum, with a central Ring of Malkos.
Where Thekia rallies the exiled mages.

---

## 6. Characters / NPCs

- **The Old Mage / Thekia** — elderly brunette mage, fluent and sharp. The
  quest-giver and mentor. Gives Levitate, later the Staff. Reveals at the end she
  was a member of the **High Mage's Council** that Vashirr disbanded and
  banished. Her dream: *"Before I die, I want to see the Nacastrum I remember
  from my childhood."* Final line: *"Let us go, my king."*

- **Vashirr** — King of the Mages; the antagonist. Disbanded the High Mage's
  Council, secretly **allied with the Agroman**, banished/scattered the mages,
  **murdered the player's father with magic**, and abducted the player's mother.
  *"Vashirr is a powerful mage and a formidable foe, but I know we can stop him."*

- **Dentros** — Druid **scout from Cataracta**; first appears as a red fox, then
  transforms into a man with cherry-red hair. *"My name is Dentros. I am a scout
  from Cataracta… I am a Druid."* Gives the player the **lantern** and tips them
  off about the secret of the Old Mages in the mountains.

- **Cellious** — chief of a Cataracta druid hunting pack at the blue gate.
  Apologizes after the wolf scare: *"Dreadfully sorry about that, Mage."*
  Explains druid class structure but refuses entry: *"I'm afraid I can't let you
  into the city. Our king is extremely paranoid of spies."*

- **The trading-post merchant** — grieving Oceandale survivor whose wife was
  abducted by Agromanians.

- **The Sylvian marksman** — Kaefden forest-druid hunter who frees the player
  from the net and guides them into Silvarium. *"I recognize a mage when I see
  it… Kaefden to Kaefden, you must reestablish Nacastrum… A few of us decided to
  stay. This is our homeland, and if war is coming, we will stand and fight or we
  will die."*

- **Marlux** — frightened young Sylvian boy on Floor 1. *"My name is Marlux. My
  dad is apart of the hunting squad. I stay here to learn."*

- **The butcher (bearded, bear-skin)** — head of the Floor-2 butchery. Resentful
  of the Elders' deal with the mages: *"The Sylvians were fine before we made
  that deal with those mage!"* Gives the player a chest containing **Suformin's
  Dagger**.

- **The armory guard** — bars the Floor-2 armory: *"This area is restricted to
  Sylvian hunters only… By those pointed ears and the robes you're wearing I can
  see that you are Kaefden."*

- **The Church priestess of Suformin** — elk-headed cleric on Floor 3. *"All are
  welcome in the Church of Suformin, God of the Hunt."* Recognizes the dagger:
  *"Suformin would not entrust a mortal with her dagger lightly, especially a
  mage… I suspect great things to come from you."* (Easter egg: the meaning of
  life is *"42."*)

- **The librarian (fox coat)** — vain keeper of the Floor-3 library. *"I pride
  myself as the number one hoarder of knowledge in this city… Should I find you
  mistreating any of the books here, I will have you fed to angry, starving
  wolves."* Confirms the seal is *"the same one used by the mages of old"* and
  that even the Elders couldn't reopen it: *"their blood isn't worthy!"*

- **The player's parents** — appear in the memory reveal. The **mother** is
  abducted through Vashirr's portal; the **father** is killed by Vashirr trying
  to save her (his corpse and pendant are found in Nacastrum's courtyard).

---

## 7. Key Story Moments / Set Pieces

- **The opening on the beach** — amnesiac wake-up; the dying-town lore dump by
  the old guard at the broken gate.
- **The magehouse meeting** — the door slams shut by unseen magic; the Old Mage
  tests the player (*"what faction do the mages represent?"* → Kaefden), reveals
  the conspiracy about Vashirr, and gives Levitate.
- **Dentros' transformation** — fox-to-man reveal introducing the druids and
  shapeshifting.
- **The druid wolf confrontation** — a hunter becomes a black wolf; the player
  must non-violently prove their identity.
- **The Silvarium net trap and the loyal-Kaefden marksman** — a moment of
  cross-race solidarity.
- **The burnt mage in the fireball room** — *"It seems you are not alone on your
  quest"* — foreshadowing other doomed seekers; the cave is littered with
  corpses.
- **The blood-seal ritual** — self-sacrifice with Suformin's Dagger to open the
  Stonebend chamber.
- **The Agromanian ambush** — the only fully lethal combat set piece; survival
  demands Inflame.
- **The memory-bridge illusion** — surreal dream sequence; jumping into the
  "water" reveals the floating city of Nacastrum.
- **THE MEMORY RESTORATION (central reveal)** — stepping through the Ring of
  Malkos, the player's full life floods back:
  - Taken from his parents at age 8 to join the Academy (mother weeping: *"It's
    time for you to go… Please, son, don't forget us."*).
  - Vashirr crowned when he was 13; graduates the Academy; becomes a teacher of
    young mages.
  - At age 33, woken by a blinding light; dragged by guards to Vashirr's
    courtyard among hundreds of mages. Vashirr stands beside **an Agromanian**,
    a portal taking women and children. The player's **mother** is being dragged
    in; his **father breaks free, runs to her, and is blasted dead by Vashirr's
    magic.** Vashirr then scatters the remaining mages — the player's last memory
    before the beach.
  - The player collapses screaming; Thekia comforts him: *"Take as long as you
    need. We will move on when you are ready."*
- **Thekia's identity reveal** — *"I am Thekia. I once was part of the High
  Mage's Council,"* explaining how Vashirr consolidated power.
- **The father's corpse and pendant** — in the King's Castle courtyard the player
  finds his father's body, vows revenge, and dons the **silver pendant with a
  blue gemstone** (echoing the staff's blue gem and the dagger's blue metal — a
  recurring "true mage / Malkos" motif).
- **The rally at Aylova & the homecoming** — Thekia's speech denouncing Vashirr's
  alliance with the Agroman; mages (and non-mages) stream back through the portal
  to repopulate Nacastrum; the player is crowned in spirit: *"Let us go, my
  king."* — the game's victory.

---

## 8. Recurring Motifs (for art & writing direction)

- **Blue crystal / blue gemstone** — the mark of true mage power and the Rings of
  Malkos: the Cataracta gate's crystal shards, the dagger's blue metal, the
  staff's blue gem, the father's pendant. Use this as the remake's signature
  visual accent.
- **Shapeshifting & disguise** — druids reveal themselves (fox→man, man→wolf);
  themes of hidden identity culminate in the player's own forgotten self.
- **"Kaefden to Kaefden"** — the bond of loyalty among the scattered people; said
  by the Old Mage, the marksman, and others.
- **Worthy blood** — the blood seal, the "their blood isn't worthy" line, and the
  player's heritage tie magic to lineage and sacrifice.
