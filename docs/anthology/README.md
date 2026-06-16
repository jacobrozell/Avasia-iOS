# Avasia Anthology — Design Docs

> Short story adventures **beside** the Age-era duology (KoN + SoC). Parallel
> timelines, alignment forks, and neutral vignettes — see
> [`../ANTHOLOGY_ROADMAP.md`](../ANTHOLOGY_ROADMAP.md).

---

## Documents

| Doc | Purpose |
|---|---|
| [`ROOM_SPEC_STANDARD.md`](ROOM_SPEC_STANDARD.md) | Schema for anthology room specs |
| [`CONTENT_MANIFEST.md`](CONTENT_MANIFEST.md) | Swift IDs, flags, story index |
| [`rooms/README.md`](rooms/README.md) | Room spec index |
| [`stories/`](stories/) | Per-story arc specs (Story #0–#n) |

**Fiction layer:** [`../fiction/STORY_ZERO_SCOUT_PATROL.md`](../fiction/STORY_ZERO_SCOUT_PATROL.md) · [`../fiction/SHORT_STORY_SERIES.md`](../fiction/SHORT_STORY_SERIES.md)

**Engine:** `Sources/AvasiaAnthologyEngine/` · Product: `AvasiaProduct.stories`

---

## Story index

| ID | Spec | Rooms | Swift | Status |
|---|---|---|---|---|
| **#0 Scout Patrol** | [fiction spec](../fiction/STORY_ZERO_SCOUT_PATROL.md) | [rooms/](rooms/) | ✅ | Hub + playable |
| **Good #1** | [stories/STORY_GOOD_ONE.md](stories/STORY_GOOD_ONE.md) | [rooms/](rooms/) | ✅ | 500 FP · loyalist |
| **Good #2** | [stories/STORY_GOOD_TWO.md](stories/STORY_GOOD_TWO.md) | — | ✅ | 1,000 FP · after Good #1 |
| **Bad #1** | [stories/STORY_BAD_ONE.md](stories/STORY_BAD_ONE.md) | [rooms/](rooms/) | ✅ | 500 FP · agroman |
| **Bad #2** | [stories/STORY_BAD_TWO.md](stories/STORY_BAD_TWO.md) | — | ✅ | 1,000 FP · after Bad #1 |
| **Elk Feast** | [stories/STORY_ELK_FEAST.md](stories/STORY_ELK_FEAST.md) | [rooms/](rooms/) | ✅ | 250 FP · neutral |
| **Cave Record** | [stories/STORY_CAVE_RECORD.md](stories/STORY_CAVE_RECORD.md) | — | ✅ | 500 FP · after Elk |
| **Council Under Glass** | [stories/STORY_GOOD_THREE.md](stories/STORY_GOOD_THREE.md) | — | ✅ | 2,500 FP · after Good #2 |
| **Many Hands Oath** | [stories/STORY_BAD_THREE.md](stories/STORY_BAD_THREE.md) | — | ✅ | 2,500 FP · after Bad #2 |
| **Two Hands Market** | [stories/STORY_NEUTRAL_THREE.md](stories/STORY_NEUTRAL_THREE.md) | — | ✅ | 2,500 FP · after Cave Record |
| **Training Arena** | — | `arenaPit` | ✅ | Free · 75 gold / run |
| **Training Shop** | — | `trainingShop` | ✅ | Gear + ring passes (100g) |
