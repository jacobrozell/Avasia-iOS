# Avasia — Fiction Specs

> Author's working bible for the **Avasia** saga as a series of interconnected
> short stories. These docs sit beside the game bibles ([`../STORY.md`](../STORY.md),
> [`../sequel/STORY.md`](../sequel/STORY.md), [`../SAGA.md`](../SAGA.md)) and
> translate canon into **narrative craft**: POV, theme, scene beats, and
> character voice — the material you'd hand an editor or co-author.
>
> **Do not contradict** [`../SAGA.md`](../SAGA.md) **§0 (sacred pillars)** —
> anchor law, Commodity Era, survivor's legend, flesh cult stack, duology argument.

---

## What lives here

| Doc | Purpose |
|---|---|
| [`CHARACTERS.md`](CHARACTERS.md) | Key cast — wants, wounds, voice, relationships, story hooks |
| [`SHORT_STORY_SERIES.md`](SHORT_STORY_SERIES.md) | Full saga as a numbered anthology: one spec per story |
| [`STORY_BRAINSTORM.md`](STORY_BRAINSTORM.md) | **Index** to all supplemental specs (codes I-M01 … III-M09, W-01–W-12) |
| [`specs/`](specs/README.md) | **36 margin story specs** — synopsis, beats, dialogue by volume |
| [`WORLD_BUILDING.md`](WORLD_BUILDING.md) | Institutions, cultures, economy, geography stories W-01–W-12 |
| [`OFKELOS.md`](OFKELOS.md) | Neutral city bible — districts, Blade clause, observer corps |
| [`THEKIA_GROUND_HOUSE.md`](THEKIA_GROUND_HOUSE.md) | **Thekia bible** — Stories 2b, 4b, 9b + prose draft |
| [`STORY_ZERO_SCOUT_PATROL.md`](STORY_ZERO_SCOUT_PATROL.md) | **Story #0** — alignment fork, Vashirr first contact (future anthology) |
| [`ASH_VAULT/`](ASH_VAULT/README.md) | **Ash Vault prequel** — prose + cross-promo to dungeon crawler app (AV-01–03) |

---

## How to read these specs

Each short story entry includes:

- **Working title** — may differ from in-game chapter names
- **Canon anchor** — which game, act, or room script grounds the piece
- **POV & tense** — default is second person present (matching the games); some historical pieces use third
- **Synopsis** — one paragraph, spoiler-inclusive (this is internal author material)
- **Scene beats** — the spine of the story
- **Theme & tone** — what the piece is *about*, and where earnest vs. meta humor lands

Stories are ordered **chronologically in-world**, not by publication order. A reader
could follow the anthology front-to-back and experience the Age era from the
schism through the war's end.

---

## Relationship to the games

| Fiction layer | Game layer |
|---|---|
| Short story spec | Playable act, region, or set piece |
| Character profile | NPC dialogue + player-facing lore |
| Theme note | Motif in [`../STORY.md`](../STORY.md) §8 |

Nothing here overrides the game bibles. When prose is quoted in-game, the game
text wins.

---

## Scope

**Age era only** — *King of Nacastrum* and *Blade of Courage*, plus **Ash Vault**
prequel fiction (~70 yr before KoN). Game 3 (first 2D title, post–Age era) is noted
in the series index as **Volume III — TBD**.

---

## GitHub Pages (fiction site)

HTML pages for sharing are generated from the markdown sources in this folder.

| URL (after Pages is enabled) | Content |
|---|---|
| `/fiction/story-brief.html` | Collaborator overview |
| `/fiction/index.html` | Full catalog — spine, margin, world stories |
| `/fiction/spine/` | Stories 1–20 (+ 2b, 4b, 9b) |
| `/fiction/margin-i/` · `margin-ii/` · `bridge/` · `commodity/` · `world/` | Supplemental specs |

**Build:** from repo root, `python3 scripts/build-fiction-site.py` (requires `pip install markdown`).

**Enable Pages:** GitHub repo → Settings → Pages → Source: **Deploy from branch** → branch `main` (or your default) → folder **`/docs`**. The site root is `docs/index.html`; fiction lives under `docs/fiction/`.
