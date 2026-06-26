# Design Intent — Art Bible & Blueprint Visualization System

**Status**: Design intent captured — NOT implemented, scheduling TBD (see Open Questions).
**Source**: ChatGPT design dialogue, 2026-06-26. Reviewed and converged by Claude (Planning/Review) same date.
**Relationship to other docs**: This is the **Art Bible** leg of the proposed three-bible structure (Engineering Bible / Art Bible / Manufacturing Bible). It is deliberately separate from economic/gameplay design (e.g. the EscalationHandler "Defensive Undercut" work) — those belong to the Engineering/Manufacturing side, not here.

---

## Why This Exists

Goal: generate consistent catalog art for every unit, driven by the JSON blueprint itself, so players can browse a coherent visual catalog without hand-designing art direction per unit. The blueprint becomes the single source of truth for both gameplay data and the prompt that renders its catalog image.

The original dialogue iterated through three framings before converging:
1. ~~Earth-style vs. Luna-style~~ (discarded — too binary, doesn't scale past two bodies)
2. ~~`manufacturing_origin` (earth/mars/colony) determines look~~ (discarded — unrealistic; a colony with the right tech can build Earth-quality hardware)
3. **Technology Level determines look, origin is irrelevant** (converged model — documented below)

Only the converged model is documented here. The earlier framings are dead ends and should not be re-derived later — appearance is driven by *what you can build with*, not *where you are*.

---

## Core Model — Three Independent Axes

1. **Blueprint (the engineering spec)** — dimensions, ports, interfaces, materials, tolerances, function. Fixed. Does not change based on who builds it or where.
2. **Technology Level** — the settlement/civilization's manufacturing *capability*. Gates which Manufacturing Methods are available and sets the baseline visual maturity language.
3. **Blueprint Generation (MK1 / MK2 / MK3...)** — engineering design evolution. Independent of Tech Level. A Tech-3 factory can still be stamping out a MK1-design unit if that's the only blueprint it has acquired; it will be beautifully built but based on an older design.

Two supporting style inputs (derived, not independent axes):
- **Manufacturing Method** (precision factory / large-scale additive / cast construction / modular assembly / heavy industrial fabrication) — gated by Tech Level, drives the actual visual style.
- **Material Source** (aerospace aluminum alloy, lunar regolith composite, Martian basalt composite, carbon composite...) — drives texture/color only.

### Technology Level Ladder (illustrative, not final)

| Tier | Capabilities | Visual language |
|---|---|---|
| 1 — Bootstrap | Large-scale additive, simple machining, basic casting, repair-focused | thick members, exposed structure, visible layering, oversized components |
| 2 — Developing | Better machining/additive, standardized parts, improved alloys | cleaner prints, refined shapes, lighter structures |
| 3 — Mature Precision | Precision machining, high-performance alloys, composites, automated factories | clean aerospace hardware, integrated systems (this is where HLT/TEU/PVE sit today) |
| 4+ — Advanced | Molecular manufacturing, exotic materials, ultra-light structures | not yet designed |

---

## Proposed Blueprint Schema Addition

An **additive, optional** block — does not require migrating existing blueprints to a new template version:

```json
{
  "metadata": {
    "name": "Thermal Electric Unit",
    "blueprint_template_version": "1.3",
    "design_generation": "mk1"
  },
  "visualization": {
    "catalog_style": "product_two_view",
    "manufacturing_method": "precision_factory",
    "technology_level": 3,
    "component_class": "processing_unit",
    "visual_characteristics": [
      "clean aerospace hardware",
      "precision fabricated",
      "large regolith hopper",
      "thermal processing chamber",
      "gas collection manifolds",
      "rear discharge chute"
    ]
  }
}
```

> Note the deliberately disambiguated version fields — see Risk #1 below. `connection_schema_version` (bus-topology, currently bare `"1.9"`) is a third, separate field elsewhere in the port-system blueprints and must never collide with either of these.

### Port-Derived Visual Cues (cosmetic only, no engine impact)

| Port type | Visual cue |
|---|---|
| Gas ports | standardized pipe couplings |
| Power ports | armored electrical connectors |
| Material ports | industrial feed hoppers |
| Data ports | small sealed service panels |

This is documentation/flavor only — it must never be read by `TaskExecutionEngineV2` or any capacity-check logic. Purely a prompt-builder concern.

---

## Catalog Render Template (reusable base prompt)

```
Clean product catalog render of a [UNIT NAME].

Show exactly two views:
- front 3/4 view on the left
- rear 3/4 view on the right

White background. Subtle shadows. No text, labels, logos, or infographic elements. No environment.

[MANUFACTURING METHOD STYLE BLOCK — driven by technology_level + manufacturing_method]

[FUNCTIONAL DESCRIPTION — from visual_characteristics]

[DESIGN GENERATION MODIFIER — driven by design_generation: mk1/mk2/mk3...]
```

Only the bracketed fields change per unit; the structure stays constant, giving a consistent catalog "shelf."

---

## Review Notes (Claude, Planning/Review — 2026-06-26)

### Strengths
- Decoupling appearance from manufacturing *origin* and tying it to manufacturing *capability* is more realistic and fits the existing "knowledge travels more easily than infrastructure" economic framing.
- Tech Level vs. Blueprint Generation as independent axes is the strongest idea in the source dialogue — explains visual + gameplay progression without conflating "how good is the design" with "how well can this settlement build it."
- Port-derived visual cues reinforce universe consistency for free, with zero engine risk.

### Risks / Open Questions — resolve before this becomes an implementation task

1. **"version" field name collision.** The codebase already has two distinct meanings for "version" (`unit_blueprint_v1.3` template compliance; bare `"1.9"` connection_schema). This proposal introduces a third (MK generation). Resolved above by using three explicit field names (`blueprint_template_version`, `connection_schema_version`, `design_generation`) — never reuse bare `version` for a new concept. **Confirm this naming before any field is added to a real blueprint file.**
2. **Schema placement.** Confirmed here as an additive optional block, not a new required template version — avoids forcing a migration pass across all existing units the way the port-schema work did for real engine reasons. Worth an explicit sign-off that this is the intended placement.
3. **Does Technology Level need new backing data, or does it already exist?** This doc assumes Tech Level is new scope (a settlement/civilization capability gate). Unconfirmed whether any research-tree or manufacturing-capability concept already exists in the domain model. **Needs a direct check before scoping further** — do not assume either way.
4. **No engine-logic risk, confirmed.** This is cosmetic/documentation-only. Should not touch `TaskExecutionEngineV2`, the port/connection-schema system, or any capacity-check logic. Flagging explicitly so a future executor doesn't quietly expand scope into gameplay-affecting territory.
5. **Cross-reference against the corporate roster once scheduled** — LDC/MDC/VDC/TDC/SDC, AstroLift, Vector Hauling, Zenith Orbital, Wormhole Transit Consortium/Station, Terragen. Tech-Level-as-capability gives a natural way for different corporate actors to sit at different tiers; worth confirming alignment with existing corporate logo/style docs before art generation work starts.

### Explicitly Out of Scope for This Doc
The economic principle that settlements should prioritize local production and reserve imports for what local tech level can't produce belongs to the Manufacturing/Engineering Bible side (the EscalationHandler "Defensive Undercut" task), not here. Kept separate per the source proposal's own three-bible structure.

---

## Recommended Next Steps
- Confirm whether Technology-Level-as-capability already exists in the domain model before any further scoping.
- Sign off on additive (non-migrating) schema placement and the three disambiguated version field names.
- Hold actual image-generation/implementation work until explicitly scheduled — captured as intent only as of this doc.
