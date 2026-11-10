# Skimmers & Mixed Volatiles
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-07  
> *Audit Summary:* Design intent specification (page status DIRECTION). Not audited against code; implementation pending or unverified as of audit baseline.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-05  
**Related**: [atmospheric_harvesting.md](../infrastructure/atmospheric_harvesting.md), [terraforming_options.md](../infrastructure/terraforming_options.md), [isru_fabrication_chain.md](../technical/isru_fabrication_chain.md), Luna operations / TEU material

This page records how atmospheric skimmers (especially Venus) process and deliver volatiles, and how **mixed volatiles** are tracked in inventory. It aligns with existing code patterns (TEU → `mixed_volatiles` → gas separator; tanks as capacity units; Item inventory as ledger).

---

## Design Intent

A skimmer is **not** a dumb cargo truck that dumps raw atmosphere at the depot. It is an active industrial craft: scoop → optional in-flight chemistry → deliver processed and residual mixed gases into the destination inventory chain.

Luna already produces lumped `mixed_volatiles` from TEU (thermal extraction of regolith). Venus skimmer output should feed the same style of intake so Luna (or other hubs) can run the existing separator path.

---

## Venus Skimmer Loop (DIRECTION)

1. **Intake** — Scoop raw Venusian atmosphere (primarily CO₂ + N₂ and minor constituents) from the upper, operable layers.
2. **In-flight processing** — Crack a portion of CO₂ into **LOX (O₂)** and **CO**.
3. **LOX routing** — LOX fills dedicated header / propellant-style tanks (Starship-analog layout: dedicated LOX and methane-capable tanks alongside main bays).
4. **CO handling (decision node)**  
   - **Vent** — return CO to Venus atmosphere if no market and no spare capacity (saves mass/volume).  
   - **Dedicated tank** — if a CO-capable tank unit is fitted, store pure CO.  
   - **Remix** — blend CO back into the main mixed-volatile payload.  
   Default preference when capacity exists: **store**, do not vent.
5. **Arrival state (e.g. at Luna)**  
   - Dedicated LOX tank(s) full (or at process yield).  
   - Main tanks hold **modified mixed volatiles** (depleted in some CO₂ relative to raw Venus air; may contain retained CO).  
   - Inventory receives the exact tracked masses; tanks only enforce capacity/mode limits.

Methane tanks on the craft follow the same dual-tank idea when the craft is configured for methalox loops (Luna PSR H₂ + Venus CO₂ Sabatier pathways remain documented under atmospheric harvesting / propellant logistics).

---

## Capacity vs Inventory (ESTABLISHED DIRECTION from architecture)

| Concern | Owner | Role |
|---------|--------|------|
| Tank / storage unit | `Units::BaseUnit` (craft `has_many`) | Capacity, mode (gas/liquid), temperature/pressure compatibility, power/maintenance of the vessel |
| Contents | Inventory / `Item` model | What is actually stored, amounts, and composition metadata |

Tanks answer: “Can this mass/mode fit?”  
Inventory answers: “What chemicals, how much, from where?”

Do not put composition ledgers on the tank unit itself as the source of truth.

---

## Mixed Volatiles Tracking (DIRECTION)

### Code-aligned pattern (already present for TEU)

- TEU produces a lumped inventory item **`mixed_volatiles`** (constants and production loops already in repo).
- Gas separator blueprint consumes `mixed_volatiles` and yields individual compounds (O₂, H₂O, CO₂, H₂, CH₄, N₂, etc.).
- `MaterialProcessingService` distributes lumped mixed volatiles into individual compound items using crust/composition data.

### Composition rule

- **Mass is primary** (same as planetary `Gas` model: mass stored, percentage derived for display).
- Prefer `Item.metadata['composition']` with per-compound `mass_kg` (and `total_mass_kg` consistent with `Item.amount`) over inventing a parallel mixture table.
- Different source batches (Venus-processed vs TEU vs other worlds) should remain distinguishable so they are not blindly merged if composition differs.

Example shape (illustrative, not locked numbers):

```text
metadata: {
  source: "venus_skimmer" | "thermal_extraction_unit" | ...,
  composition: {
    CO2: { mass_kg: ... },
    N2:  { mass_kg: ... },
    CO:  { mass_kg: ... },
    ...
  },
  total_mass_kg: ...,
  processed_at: ...
}
```

Percentages, if needed, are computed: `mass_i / total_mass_kg`.

### Advanced selective extraction

Because planetary atmospheres are stored as individual gas mass rows, later specialized skimmers can target a single species without changing the core model. Early skimmers take proportional bulk mix; advanced units may filter.

---

## Luna Parallel (TEU)

TEU heating of regolith releases a small mixed-volatile fraction into the same lumped inventory concept, then into buffer / gas separator. Venus skimmer delivery should be compatible with that downstream path so Luna does not need a second separator architecture for “Venus mix” vs “regolith mix.”

---

## Open Questions

- Exact CO₂→LOX/CO conversion efficiency and energy cost on the skimmer.
- Whether venting is ever automatic under full tanks or always a market/AI decision.
- Formal JSON schema for `metadata['composition']` and validation helpers (`can_store?`, merge rules for identical composition).
- When mixed-volatiles batches with different compositions may be blended at a depot vs kept separate.
- Methane tank fill path on the same craft when Sabatier products are involved.

Implementation detail belongs in services and specs; this page owns the **design intent** so skimmer behavior is not re-simplified to “unload N₂/CO₂ bags.”
