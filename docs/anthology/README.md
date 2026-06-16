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
| **#0 Scout Patrol** | [fiction spec](../fiction/STORY_ZERO_SCOUT_PATROL.md) | [rooms/](rooms/) | ✅ | **1.0.0** · hub + playable |
| **Good #1** | [stories/STORY_GOOD_ONE.md](stories/STORY_GOOD_ONE.md) | [rooms/](rooms/) | ✅ | **1.0.0** · 500 FP · loyalist |
| **Good #2** | [stories/STORY_GOOD_TWO.md](stories/STORY_GOOD_TWO.md) | — | ✅ | 1,000 FP · after Good #1 |
| **Bad #1** | [stories/STORY_BAD_ONE.md](stories/STORY_BAD_ONE.md) | [rooms/](rooms/) | ✅ | **1.0.0** · 500 FP · agroman |
| **Bad #2** | [stories/STORY_BAD_TWO.md](stories/STORY_BAD_TWO.md) | — | ✅ | 1,000 FP · after Bad #1 |
| **Elk Feast** | [stories/STORY_ELK_FEAST.md](stories/STORY_ELK_FEAST.md) | [rooms/](rooms/) | ✅ | **1.0.0** · 250 FP · neutral |
| **Cave Record** | [stories/STORY_CAVE_RECORD.md](stories/STORY_CAVE_RECORD.md) | — | ✅ | 500 FP · after Elk |
| **Council Under Glass** | [stories/STORY_GOOD_THREE.md](stories/STORY_GOOD_THREE.md) | — | ✅ | 2,500 FP · after Good #2 |
| **Many Hands Oath** | [stories/STORY_BAD_THREE.md](stories/STORY_BAD_THREE.md) | — | ✅ | 2,500 FP · after Bad #2 |
| **Two Hands Market** | [stories/STORY_NEUTRAL_THREE.md](stories/STORY_NEUTRAL_THREE.md) | — | ✅ | 2,500 FP · after Cave Record |
| **Restoration Mobilization** | [stories/STORY_GOOD_FOUR.md](stories/STORY_GOOD_FOUR.md) | — | ✅ | 5,000 FP · after Good #3 |
| **Cataracta Breach** | [stories/STORY_BAD_FOUR.md](stories/STORY_BAD_FOUR.md) | — | ✅ | 5,000 FP · after Bad #3 |
| **Cellious at the Gate** | [stories/STORY_NEUTRAL_FOUR.md](stories/STORY_NEUTRAL_FOUR.md) | — | ✅ | 5,000 FP · after Neutral #3 |
| **Witness Stone** | [stories/STORY_GOOD_FIVE.md](stories/STORY_GOOD_FIVE.md) | — | ✅ | 10,000 FP · loyalist capstone |
| **Western Command** | [stories/STORY_BAD_FIVE.md](stories/STORY_BAD_FIVE.md) | — | ✅ | 10,000 FP · agroman capstone |
| **The Unmarked Road** | [stories/STORY_NEUTRAL_FIVE.md](stories/STORY_NEUTRAL_FIVE.md) | — | ✅ | 10,000 FP · neutral capstone |
| **The Restoration Accord** | [stories/STORY_GOOD_SIX.md](stories/STORY_GOOD_SIX.md) | — | ✅ | 17,500 FP · loyalist finale |
| **Western Throne** | [stories/STORY_BAD_SIX.md](stories/STORY_BAD_SIX.md) | — | ✅ | 17,500 FP · agroman finale |
| **The Open Ledger** | [stories/STORY_NEUTRAL_SIX.md](stories/STORY_NEUTRAL_SIX.md) | — | ✅ | 17,500 FP · neutral finale |
| **Training Arena** | — | `arenaPit` | ✅ | Free · 75 gold / run |
| **Training Shop** | — | `trainingShop` | ✅ | Gear + ring passes (100g) |
