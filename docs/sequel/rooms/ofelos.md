# Ofelos

> Act IV alliance — neutral city joins the coalition (iOS authored).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `ofelos` |
| **Display name** | Ofelos |
| **Room type** | logic |
| **Act** | IV |
| **Region** | `splitpath` |
| **Critical path** | **yes** |
| **Source** | `SoCOfelosRoom.swift` |

## Story & purpose

Present **Kaefden's Blade of Courage** before the neutral council. **Speaker Maelen**
and council weigh Silvarium's backing. **Ofelos** marches with the coalition.
`SoCStoryVoice` may echo throne choice (`honorDentros` vs `reportFacts`).

## Characters

| Name | Role |
|---|---|
| **Speaker Maelen** | Council voice |
| Neutral delegates | Audience |

## Rewards

- Trophy: `ofelosMarches`

## State flags

| Flag | When |
|---|---|
| `ofelosPhase` | `gates` → `council` → `presentation` → `alliance` → `done` |
| `ofelosAllianceComplete` | Neutrals pledged |

## Player options

| Input | Phase | Outcome |
|---|---|---|
| `CONTINUE` | each | Advance scene |
| `PRESENT` | `presentation` | Requires Blade in inventory |
| `MARCH NORTH` | done | → `northernMarch` |

## Navigation

← `varatroFalls` · → `northernMarch` on **MARCH NORTH**

## Related

[`silvarium-elders.md`](silvarium-elders.md) · [`northern-march.md`](northern-march.md)
