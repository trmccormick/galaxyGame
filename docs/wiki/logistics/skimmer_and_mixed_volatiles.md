# Skimmers & Mixed Volatiles
> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-07  
> *Audit Summary:* Design intent specification (page status DIRECTION). Not audited against code; implementation pending or unverified as of audit baseline.

**Status**: DIRECTION / OPEN  
**Last Updated**: 2026-11-10  
**Related**: [atmospheric_harvesting.md](../infrastructure/atmospheric_harvesting.md), [terraforming_options.md](../infrastructure/terraforming_options.md), [isru_fabrication_chain.md](../technical/isru_fabrication_chain.md), Luna operations / TEU material

This page records how atmospheric skimmers (especially Venus) process and deliver volatiles, and how **mixed volatiles** are tracked in inventory. It aligns with existing code patterns (TEU → `mixed_volatiles` → gas separator; tanks as capacity units; Item inventory as ledger).

---

## Design Intent

A skimmer is **not** a dumb cargo truck that dumps raw atmosphere at the depot. It is an active industrial craft: scoop → optional in-flight chemistry → deliver processed and residual mixed gases into the destination inventory chain.

Luna already produces lumped `mixed_volatiles` from TEU (thermal extraction of regolith). Venus skimmer output should feed the same style of intake so Luna (or other hubs) can run the existing separator path.

---

## Venus HLT Harvesting and Mission Cycle (DIRECTION)

The Venus HLT takes in **bulk Venusian atmosphere**. It does not selectively scoop only CO₂ and N₂, nor does it assume that every intake batch has one permanent, exact composition. The intake contains the atmospheric mixture present at the craft's operating location and altitude, including major constituents and trace gases. Separation and processing happen after capture.

Atmospheric composition values are estimates, not a fixed recipe. The mix encountered can vary with altitude, operating location, atmospheric conditions, and the changing local composition as harvesting continues. The simulation should be able to represent gradual changes rather than forcing every batch to match one constant Venus profile. Early estimates can use a representative Venusian composition with uncertainty; actual batch measurements and accumulated harvesting results can refine subsequent estimates.

### Bulk intake and onboard handling

1. **Intake** — Capture the complete atmospheric mixture entering the harvester. Do not model the intake as a target-gas-only filter.
2. **Separation and inventory** — Track the captured mixture by constituent mass, including trace gases where estimated or detected. Recoverable gases can be separated and stored; handling depends on processing capability, tank fit, and mission priorities.
3. **Limited CO₂ processing** — The HLT's CO₂ splitter converts only the amount of captured CO₂ needed to support the craft's LOX requirements. This is not a full-time conversion of all captured CO₂.
4. **Conversion products** — CO₂ splitting produces O₂ and CO. The O₂ is liquefied/stored as LOX. The craft does **not** have methane-production capability; CO₂ processing must not be described as producing methane.
5. **CO handling** — During outbound harvesting/operations, CO may initially be vented. On the return leg, additional CO₂ is processed and the resulting CO is retained in the mixed-volatiles tank unless a dedicated CO tank is fitted.
6. **Return-leg LOX replenishment** — Continue processing captured CO₂ during the return leg so the HLT targets landing on Luna with a full LOX tank. Actual processing is bounded by available CO₂, equipment/energy, LOX capacity, and mission requirements.

### Methane is provisioned for the whole mission

The HLT must carry enough methane for the **entire mission**, including outbound travel, Venus operations, and the return to Luna. The Venus HLT configuration does not manufacture methane. If the main methane tank does not hold the full mission requirement, additional methane may be carried in mixed-volatiles storage and transferred into the main methane tank before the relevant harvesting/departure operation. The AI Manager must calculate methane and LOX requirements separately.

### Return to Luna and turnaround

The expected return state is a full LOX tank, subject to actual mission and equipment conditions, plus the recovered atmospheric mixture and processing byproducts that fit within available storage and payload capacity. The return manifest is the actual mass of each constituent remaining aboard after separation, processing, venting, fuel use, and storage allocation—not a fixed assumed delivery percentage or a per-day production figure.

At Luna, the owner may transfer LOX into base storage, unload recovered mixed volatiles, and use the base as a shared storage and servicing facility. The craft can be inspected, repaired, maintained, and prepared for its next launch window. Fuel transfers between craft and base are inventory transfers, not forced market sales and repurchases. If the HLT lands with a full LOX tank and retains or reloads the required methane, it can depart the next mission with a full LOX tank; only a genuine shortfall needs topping off.

### AI Manager estimates and choices

The AI Manager should estimate the expected intake mixture and returned manifest from the best available atmospheric composition data, sampling history, harvesting location/altitude, capture mass, processing efficiency, tank capacities, venting choices, mission fuel consumption, and payload limits. It should track uncertainty and revise estimates as batches are collected; trace-gas estimates may be especially uncertain.

It then compares the projected or actual return inventory with Luna's needs: habitat inflation and life support, industrial feedstock, base reserves, and the next mission's fuel and storage requirements. If returned nitrogen or other required gases are insufficient, the AI Manager can consider another harvesting run, Earth imports, or other available supply options. The required outcome is adequate supply; no single supply route or fixed mission script is mandatory.

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

### Bulk intake, changing composition, and later processing options

The Venus HLT's intake is bulk atmospheric capture: it takes in the mixture present at its operating location rather than targeting selected gases at the scoop. The captured batch is then separated, processed, stored, or vented according to the craft's installed equipment and mission plan. A later craft may add selective separation or recovery capabilities, but that is a processing/configuration option and does not redefine the initial bulk-intake behavior.

Composition is not assumed to remain constant. The simulation may begin with estimated major-gas and trace-gas profiles, then allow the sampled mixture to change gradually with altitude, operating location, atmospheric conditions, and harvesting activity. Each batch should retain its own measured or estimated composition and uncertainty so the AI Manager can update forecasts from accumulated results.

---

## Luna Parallel (TEU)

TEU heating of regolith releases a small mixed-volatile fraction into the same lumped inventory concept, then into buffer / gas separator. Venus skimmer delivery should be compatible with that downstream path so Luna does not need a second separator architecture for “Venus mix” vs “regolith mix.”

---

## Open Questions

- Exact CO₂→LOX/CO conversion efficiency and energy cost on the skimmer.
- Whether venting is ever automatic under full tanks or always a market/AI decision.
- Formal JSON schema for `metadata['composition']` and validation helpers (`can_store?`, merge rules for identical composition).
- When mixed-volatiles batches with different compositions may be blended at a depot vs kept separate.
- Exact atmospheric composition by operating altitude/location and how sampling updates the estimated profile.
- Detailed trace-gas recovery priorities, separation efficiency, and storage suitability for the Venus HLT.
- Exact CO₂ splitter conversion efficiency, energy demand, and LOX fill calculation for a mission.
- Formal schema for representing composition estimates, uncertainty, observations, and batch-to-batch changes.
- Exact methane/LOX tank capacities, mixed-volatiles storage allocation, and turnaround transfer rules.

Implementation detail belongs in services and specs; this page owns the **design intent** so skimmer behavior is not re-simplified to “unload N₂/CO₂ bags.”
