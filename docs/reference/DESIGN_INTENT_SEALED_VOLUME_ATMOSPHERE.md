# Design Intent — Sealed Volume Atmosphere & Planetary Terraforming
**Status**: Design intent only — NOT an implementation spec. Captured 2026-06-25 for a
future dedicated design session (likely Gemini, following the same pattern as the Option C
port-schema design pass).
**Do not implement against this document as-is** — it documents direction and known
constraints, not finalized mechanics, field names, or formulas.

---

## Why This Document Exists

While resolving the LegacyPortAdapter/gas-separator port-capacity work (2026-06-24), it
became clear that "what happens to gas that doesn't fit in tank capacity" has a third
answer beyond "stays at the source" or "is lost": **once a structure is sealed, venting into
it becomes a deliberate, recoverable choice, not pure waste.** Pulling on that thread
surfaced that this isn't a lava-tube-specific mechanic — it's a general property of any
sealed volume, and it connects to a second, larger, related goal: Mars-scale planetary
terraforming. Both deserve to be documented together, clearly distinguished, before either
gets designed in detail.

---

## Part 1 — Sealed Volume Atmosphere Model (small/bounded structures)

### What qualifies as a "sealed volume"
Any bounded, enclosed structure capable of retaining an atmosphere. Confirmed examples
already in scope or under discussion elsewhere in the project:
- Lava tube habitat (Phase 6+, after worldhouse/sealing construction)
- Worldhouse domes generally (not lava-tube-specific — any worldhouse structure)
- Habitat modules and craft (HLT, cyclers, stations — already pressurized/sealed by design)
- The Valles Marineris megastructure on Mars (see Part 3 — bridges to planetary terraforming)

This should be modeled as a **shared capability**, not reinvented per structure type — the
same way `Enclosable`/`Coverable` are already shared concerns for Phase 6+ worldhouse
architecture. Working name for this capability: `SealedVolume` or `AtmosphericEnclosure`
(name not finalized — first thing for a real design session to settle).

### Core mechanics (direction, not finalized)
- **Continuous leak rate, not event-based.** Airlocks and seals are imperfect by design —
  they leak. This means atmosphere inside a sealed volume isn't "filled once and done"; it
  needs some kind of periodic/tick-based recalculation, closer to how
  geosphere/atmosphere/hydrosphere state is already tracked elsewhere, not a one-time
  capacity check like the cryo-tank port work.
- **Loss rate is explicitly NOT being pinned down right now.** Treat it as a real but
  deferred parameter — probably volume-to-leak-rate dependent (bigger sealed volume = lower
  proportional loss for the same leak), but the actual formula is future work, not something
  to guess at here.
- **Venting as partial recovery, not pure waste.** When excess gas (from processing units
  exceeding tank capacity, or deliberate habitat venting) is released into a sealed volume
  instead of vented to vacuum/space, some fraction is retained and contributes to the
  volume's accumulated atmosphere over time, rather than being entirely lost. The recovery
  fraction is also not pinned down — likely a function of vent volume vs. total sealed
  volume, but this needs real design work, not an assumption baked in now.
- **Breathable mix as a long-term, derived, size-dependent outcome.** Not a flag to set —
  a state that emerges if/when the accumulated composition (right gases, right ratios,
  right pressure) crosses some threshold, which is far more achievable in a large sealed
  volume than a small one. "Maybe one day, depending on the size of the tube" — this is
  explicitly a long-horizon aspirational mechanic, not something the first version needs to
  fully solve.

### Known real constraint to anchor early design/testing against
**Luna**: O2 is comparatively easy (ISRU extraction from regolith/volatiles is already a
core part of the Luna precursor design). **N2 is hard** — no good local source on Luna,
likely import-dependent or requires a substitute inert gas strategy. This asymmetry should
be a first concrete test case for the sealed-volume model once it's designed — a Luna lava
tube habitat trying to build a breathable mix will hit the N2 bottleneck specifically, which
is a real, already-understood constraint rather than a hypothetical one.

---

## Part 2 — Planetary-Scale Atmospheric Terraforming (Mars)

This is a **different problem from Part 1**, despite sharing the end goal of "breathable
atmosphere." Do not try to model both with the same mechanic.

- Mars already has an atmosphere — thin, mostly CO2. The terraforming goal is **processing
  the existing planetary atmosphere** toward breathability, not containing gas inside a
  bounded structure.
- This is planet-scale: different volume, different time horizon, different mechanism
  (atmospheric processors operating against an entire planetary atmosphere, not a sealed
  room).
- Already loosely placed in the phase roadmap: Phase 13+ covers "Mars terraforming
  initiation" with "Venus/Titan gas export pipelines supporting terraforming" — meaning
  imported gas from other bodies may feed into this process, not just local Martian
  processing. This document doesn't resolve how that works, just confirms it's the right
  general territory.
- **Mars is easier than Luna in this one specific sense**: there's already a planetary
  atmosphere to work with/modify, rather than needing to build one from nothing. This is
  the inverse of Luna's situation (no atmosphere at all, building up a sealed-volume
  atmosphere from scratch via ISRU).

---

## Part 3 — The Bridge: Valles Marineris Megastructure

The planned Mars megastructure in Valles Marineris is the connective tissue between Parts 1
and 2, not a competing approach to either:

- It's a **sealed-volume structure** (Part 1's mechanic applies to it directly — same
  leak-rate/recovery/breathable-mix model as a worldhouse or lava tube, just at a much
  larger scale).
- Its purpose is most likely to give colonists a breathable space **now**, independent of
  whether full planetary terraforming (Part 2) ever completes — terraforming an entire
  planet is a much longer-horizon goal than sealing one large structure.
- A future design session should treat the megastructure as the first major test of Part 1's
  model at large scale, and should explicitly decide whether/how it eventually interacts
  with Part 2's planetary terraforming progress (e.g., does the megastructure eventually
  open up or become redundant once the wider Mars atmosphere becomes breathable? Or does it
  remain a permanently sealed habitat regardless? Not decided — flag as an open question for
  that session.)

---

## What This Document Is NOT

- Not a schema, not field names, not a formula for leak rate or recovery percentage
- Not an implementation task — no agent should build against this document directly
- Not a claim that Part 1 and Part 2 share a mechanic — they explicitly do not

## Suggested Next Step

Treat this the same way the Option C port-schema question was handled: bring this document
to a dedicated Gemini design session (not folded into an in-flight implementation task),
work out the actual mechanics for Part 1 first (it's needed sooner — Phase 6+ lava tube vs.
Phase 13+ Mars terraforming), and revisit Part 2/Part 3 once Part 1's model is solid enough
to extend.
