# Deposit Plausibility Rules

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-19  
> *Audit Summary:* Principles harvested from owner + domain design session. Detailed probability matrices and JSON schema remain OPEN pending implementation review.

**Status**: DIRECTION  
**Last Updated**: 2026-11-19  
**Related**: [TerraSim](terrasim.md), [StarSim and Protection Classes](../design/starsim_and_protection_classes.md), survey / system-property calibration notes in [status-and-gaps.md](../status-and-gaps.md)

This page records the intended rules for when and where mineral, ice, and volatile deposits can appear. Deposits are evaluated lazily when a survey action is performed; they are never pre-seeded across an entire body.

---

## Core Principles (DIRECTION)

1. **Lazy spawn on survey** — Deposits are generated when a survey is triggered, not at world creation.
2. **Science-grounded, not artificial scarcity** — Rules reflect real planetary science. Game-balance tuning is handled separately.
3. **`stored_volatiles` is the scientific budget** — Individual deposits draw mass from the body's stored_volatiles ledger. They do not invent mass outside that budget.
4. **Equipment tier gates visibility, not existence** — Higher-tier equipment can reveal deeper or more subtle deposits; the deposits themselves exist according to the geological rules regardless of equipment.
5. **Probability-based** — Each geological feature is evaluated against rules and returns a spawn probability (0.0–1.0), mass range, and required equipment tier.
6. **Luna is the MVP validation case** — Most permanently shadowed region (PSR) craters should have a high probability of water ice because that matches current science.

---

## Deposit Types in Scope

Water ice (including PSR / clathrate forms), bulk regolith, rare metals / ores, silicates / basalt, volatiles (N₂, CO₂, CH₄, etc.), helium-3, geothermal, and carbon compounds.

Detailed probability matrices, temperature/atmosphere/latitude constraints, preferred geological features, clustering behavior, and equipment-tier mappings are maintained as configuration data (JSON or equivalent). They are not duplicated here.

---

## Implementation Notes

- Output per evaluated feature: `spawn_probability`, `mass_range`, `equipment_tier_required`.
- Rules must be body-type aware (rocky, icy moon, terrestrial, volcanic, etc.).
- Scientific uncertainty should be flagged in the config where real data is contested.
- Exact numerical ranges remain OPEN for balance tuning after the geological constraints are locked.

All numerical values and the full rule schema remain **OPEN** until reviewed against code and owner confirmation.
