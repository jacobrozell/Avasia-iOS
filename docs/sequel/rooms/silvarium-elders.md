# Silvarium — Elders' Hall

> Act IV alliance beat — Sylvian elders commission the Blade quest (iOS authored).

## Metadata

| Field | Value |
|---|---|
| **Swift `SoCRoomID`** | `silvariumElders` |
| **Display name** | Silvarium — Elders' Hall |
| **Room type** | logic |
| **Act** | IV |
| **Region** | `tree` |
| **Critical path** | **yes** |
| **Source** | `SoCSilvariumEldersRoom.swift` |

## Story & purpose

Audience with Sylvian elders who hold sway over **Ofelos**. **Elder Venna** demands
**Kaefden's Blade of Courage** from **Varatro Falls** before they will speak for
the neutrals.

## Characters

| Name | Role |
|---|---|
| **Elder Venna** | Lead elder |
| Sylvian council | Terms and commission |

## State flags

| Flag | When |
|---|---|
| `silvariumEldersPhase` | `arrived` → `audience` → `commission` → `done` |
| `silvariumEldersComplete` | Quest accepted |

## Player options

| Input | Outcome |
|---|---|
| `CONTINUE` | Advance phased audience |
| `MARCH` / `VARATRO` | → `varatroFalls` when complete |

## Navigation

← `aylovaWarCamp` · → `varatroFalls` on **MARCH**

## Related

[`aylova-war-camp.md`](aylova-war-camp.md) · [`varatro-falls.md`](varatro-falls.md)
