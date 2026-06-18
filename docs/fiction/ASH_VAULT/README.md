# Ash Vault — Fiction & Cross-Promo

> Short stories and specs for **Avasia: Ash Vault** (standalone dungeon crawler).
> Timeline: **~70 years before** *King of Nacastrum* — the NW penitentiary
> catastrophe and seal.
>
> **Game spec:** AshVault repo [`ios/docs/avasia-integration-spec.md`](../../../../AshVault/ios/docs/avasia-integration-spec.md)
> (sibling path on Desktop: `personal/AshVault`).
>
> **Sacred pillars:** [`../../SAGA.md`](../../SAGA.md) §0 — no Vashirr redemption,
> anchor law intact, Kaefden IV not born yet.

---

## Purpose

| Layer | Where it ships | Audience |
|-------|----------------|----------|
| **Short stories** (this folder) | Avasia-iOS anthology / fiction site | Readers who want the prequel in prose |
| **Dungeon crawler** | Ash Vault app | Players who want to *survive* the descent |
| **Cross-promo** | [`MARKETING_CROSSPROMO.md`](MARKETING_CROSSPROMO.md) | Store pages, end cards, hub blurbs |

**Marketing loop:** Read *Delver Seven* or *The Clerk's COPY* in the text app → end card
points to Ash Vault → play the rings. Beat the Sinter → codex points back to *Bera*.

---

## Story index

| ID | File | POV | Length | Playable future |
|----|------|-----|--------|-----------------|
| **AV-01** | [`STORY_AV-01_DELVER_SEVEN.md`](STORY_AV-01_DELVER_SEVEN.md) | 2nd present | ~2,200 words | Anthology hub vignette or Ash Vault intro scroll |
| **AV-02** | [`STORY_AV-02_BERA_COPY.md`](STORY_AV-02_BERA_COPY.md) | 3rd limited | ~1,800 words | Cave Record epilogue seed / neutral path |
| **AV-03** | [`STORY_AV-03_LAST_OIL.md`](STORY_AV-03_LAST_OIL.md) | 2nd present | ~900 words | KoN Dentros lineage; optional KoN LOOK source |
| — | [`MALVEK_SERMONS.md`](MALVEK_SERMONS.md) | In-world docs | Fragments | Carved in Ash Vault rings 5–7; KoN optional HISTORY |
| — | [`I-M11_REVISION_NOTE.md`](I-M11_REVISION_NOTE.md) | Author note | — | Layers Sinter under Venn's worthy lie |

---

## Chronicle placement

```text
W-07 Chains Below the Forge
        │
        ▼
AV-01 Delver Seven ──► AV-02 Bera's COPY (same week, different POV)
        │
        ▼
[~40 years] I-M11 Old Mages in the Mountain (Venn)
        │
        ▼
Story 7 Ash in the Pink Cave (KoN era)
        │
        ▼
Anthology Cave Record (parallel scout)
        │
        ▼
AV-03 Last Oil (decades later — Dentros habit)
```

---

## Tone

Match KoN register ([`../STORY.md`](../../STORY.md) §1):

- **Earnest:** prison, binding, suppression, ash that holds a shape.
- **Meta:** spare — wrong command jokes belong to KoN; Ash Vault prose stays colder.

---

## Adding to the text app

1. **Anthology engine:** new story IDs `ashVaultDelverSeven`, `ashVaultBeraCopy` (future) — or fiction-only in hub as **Read** entries until scripted.
2. **Hub card:** "From the mountain — read before you delve" → opens markdown / room script.
3. **End card CTA:** See [`MARKETING_CROSSPROMO.md`](MARKETING_CROSSPROMO.md).

Update [`../README.md`](../README.md) fiction index when first story ships in-app.
