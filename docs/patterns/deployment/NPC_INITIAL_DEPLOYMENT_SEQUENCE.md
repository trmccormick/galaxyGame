# NPC Initial Deployment Sequence
**Last Updated**: 2026-05-02
**Status**: Active — applies to all NPC precursor deployments (Luna reference implementation)

---

## Overview

This document defines the gate-locked deployment pattern all NPC precursor missions
follow. Luna is the reference implementation. The AI Manager executes this sequence
autonomously before players arrive.

**HLT (Heavy Lift Transport) is never retired.** It permanently holds the Earth→LEO
role. All other roles are progressively handed off to purpose-built craft as the
L1 Shipyard comes online. Do not assume HLT is replaced — it is supplemented.

---

## Phase 1: Orbital Station — LEO Depot

**Deploy**: Station Node A (LEO Depot) via HLT  
**Achieve IOC**: Telemetry, refueling, and emergency extraction systems online

### Precedence Gate (Hard-Lock)
**No surface assets (Habs, ISRU units, Foundries) may be de-orbited until the
Orbital Station provides telemetry, refueling, and emergency extraction coverage.**

### VariantManager restriction
- Only Station-Building and Scout-Probe configurations permitted
- Surface-Descent variants locked until Phase 2

---

## Phase 2: Surface Deployment

**Prerequisite**: Station Node A IOC Status = True  
**Unlock**: Surface-Descent variants in VariantManager.rb  
**Deploy**: Surface assets (Habs, ISRU units, Foundries) via HLT

### Luna-specific surface prerequisites
Before L1 construction can begin, Luna must have ALL of the following operational:
1. Regolith ISRU — TEU and PVE units producing O2, H2, He3, metals
2. 3D printer — outputting mk1 I-beams and panels from regolith-derived materials
3. Mass launcher — operational and calibrated, throwing components to L1 position
4. HLT craft available — for positioning components in final assembly

---

## Phase 3: L1 Depot (first L1 station)

**Prerequisite**: All Luna Phase 2 surface prerequisites operational (gate above)  
**Construct**: L1 Depot shell from Luna-manufactured I-beams and panels  
**Assemble**: HLT positions components, construction shuttles assemble  
**Pressurize**: Via atmosphere concern (same code pattern as lava tube habitat)  
**Achieve IOC**: Refueling capability operational — LOX from Luna regolith PVE

### Gate at L1 Depot IOC
- HLT skimmers now dock at L1 Depot instead of landing on Luna surface
- Custom tankers begin Luna→L1 material runs
- Cycler route established: LEO Depot → L1 Depot

---

## Phase 4: L1 Shipyard (second L1 station)

**Prerequisite**: L1 Depot fully operational and stable  
**Construct**: Shipyard using same I-beam/panel method as Depot  
**Build here**: Purpose-built craft replace HLT on all non-Earth routes:
  - Custom tankers — replace HLT on Luna→L1 material runs
  - Custom Venus skimmers — dedicated CO2/LOX separator configuration
  - Custom Titan skimmers — dedicated CH4/N2 collection configuration
  - Construction shuttles — local Depot↔Shipyard operations only

### HLT role after Shipyard IOC
| Route | Before Shipyard | After Shipyard |
|---|---|---|
| Earth → LEO | HLT (permanent) | HLT (permanent — never replaced) |
| LEO → Luna (early game) | HLT | HLT (until Cycler route stable) |
| Venus/Titan skimmer | HLT fitted | Purpose-built skimmer |
| Luna → L1 material runs | HLT | Custom tanker |
| L1 local ops | HLT | Construction shuttle |

---

## Summary Phase List

| Phase | Gate | Unlocks |
|---|---|---|
| 1: LEO Depot | None (first action) | Surface-Descent variants |
| 2: Surface deployment | LEO Depot IOC | Luna ISRU operations |
| 3: L1 Depot | All Luna prerequisites met | L1 docking, Cycler route |
| 4: L1 Shipyard | L1 Depot IOC | Purpose-built craft, full supply chain |

---

## References
- Luna resource hierarchy and ISRU details: `docs/mission_profiles/LUNA_BASE_ESTABLISHMENT.md`
- Mission profile JSON: `data/json-data/missions/luna_base_establishment/` (Task 3 — pending)
- Data conventions: `docs/reference/CELESTIAL_BODY_DATA_CONVENTIONS.md`
