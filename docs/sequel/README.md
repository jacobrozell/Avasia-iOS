# Avasia: Blade of Courage — Design Docs

Design documentation for **Avasia: Blade of Courage** (*Avasia #2*). The Python
prototype lives in [`Avasia-SoC/`](../../Avasia-SoC/) — **original source only**,
no content invented in this repo beyond docs and iOS wiring.

**iOS:** separate chapter on the saga home screen; engine in `Sources/AvasiaSoCEngine/`.

Saga vision: [`../SAGA.md`](../SAGA.md) · Developer onboarding: [`../DEVELOPERS.md`](../DEVELOPERS.md)

## Documents

| Doc | Purpose |
|---|---|
| [`STORY.md`](STORY.md) | Story bible — lore, timeline, NPCs (source + design intent). |
| [`ENGINE_SPEC.md`](ENGINE_SPEC.md) | Python prototype + iOS target architecture. |
| [`WORLD_MAP.md`](WORLD_MAP.md) | Room graph from the **original** prototype. |
| [`CONTENT_MANIFEST.md`](CONTENT_MANIFEST.md) | Python room IDs → Swift `SoCRoomID` map. |
| [`ROADMAP.md`](ROADMAP.md) | Port plan — fidelity first, then new writing. |
| [`GAME3_OPENING.md`](GAME3_OPENING.md) | **Future** — Commodity Era opening town sketch (Splitpath Station). |
| [`SET_PIECES.md`](SET_PIECES.md) | Scene notes for **source** set pieces only. |
| [`STATUS.md`](STATUS.md) | **Living checklist** — port status, gaps, next steps. |
| [`rooms/`](rooms/) | **Per-room specs** — story, NPCs, options, items, flags, port status. |

## Prototype status (source fidelity)

| Area | Original Python | iOS |
|---|---|---|
| Cataracta linking rooms | ✅ | ✅ |
| Hunter path / barracks | ✅ | ✅ |
| Cataracta logic scenes (shops, fish, garden) | ✅ | ✅ |
| Courtyard massacre | ✅ | ✅ |
| Nacastrum portal + library | ✅ | ✅ |
| Throne room **stub** | ✅ | ✅ (stub) |

## App integration

- Saga picker → **King of Nacastrum** or **Blade of Courage**
- Saves: `AvasiaKoN/` vs `AvasiaSoC/` (Application Support)
- Achievements: KoN only (for now)
