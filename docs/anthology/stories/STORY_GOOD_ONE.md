# Good #1 — The Oceandale Warning (spec)

> **Requires:** Story #0 `alignment == loyalist` · **Cost:** 500 FP · **1.0.0:** ✅
> **Status:** ✅ Playable in `GoodOneRooms.swift`
> **Canon note:** Parallel to KoN beach arrival — does not replace amnesia opening.

---

## Logline

The loyalist scout reaches Silvarium elders with ridge intelligence, then is
dispatched to **Oceandale** before Agroman ships land. Warn the fishing colony;
save who you can.

## Cast

| Name | Role |
|---|---|
| PC (scout) | Messenger — REPORT path from Story #0 |
| Elder Venna | Silvarium — echoes SoC elder name, same era |
| Mira (absent/present) | Partner — debrief varies by Story #0 flags |
| Oceandale fishers | Evacuation beat — shore colony before KoN burn |

## Beats

1. **Silvarium debrief** — elders believe partial truth; debrief branches on `ridgeOutcome`, `miraStatus`, `parleyHeardFullSermon`, `scoutSignalSent`.
2. **Hard march** — splitpath → coastal road; smoke on horizon (nets burning, not campfires).
3. **Oceandale front** — parallel to SoC `oceandale_front` lore, scout POV; fishers don't read sermons.
4. **Choice:** EVACUATE pier vs HOLD church — affects survivor count (`goodOneEvacuatedPier`).
5. **Close:** PC survives; Kaefden's war still distant; sets up Good #2 (Nascastrum courier).

## Player verbs

| Room | Commands |
|---|---|
| Elders' hall | CONTINUE · TALK to Venna |
| Coastal road | CONTINUE · LOOK at horizon |
| Oceandale front | CONTINUE · TALK to fishers |
| Pier | EVACUATE · HOLD |

## Story #0 callbacks

| Flag | Effect |
|---|---|
| `miraStatus == brokeAway` | Venna asks where Mira is |
| `ridgeOutcome == withdrew` | Signal / orders-kept debrief |
| `parleyHeardFullSermon` | Venna challenges sermon vs eyes |
| `scoutSignalSent` | Green smoke acknowledged |

## Rooms

| ID | Type | Status |
|---|---|---|
| `goodOneSilvarium` | logic | ✅ |
| `goodOneSplitpath` | link | ✅ |
| `goodOneOceandale` | logic | ✅ |
| `goodOnePier` | logic (branch) | ✅ |
| `goodOneEpilogue` | logic | ✅ |

## Links

[Oceandale front (SoC)](../sequel/rooms/oceandale-front.md) · [STORY.md §2.2](../STORY.md) · [Story #0 fiction](../../fiction/STORY_ZERO_SCOUT_PATROL.md)
