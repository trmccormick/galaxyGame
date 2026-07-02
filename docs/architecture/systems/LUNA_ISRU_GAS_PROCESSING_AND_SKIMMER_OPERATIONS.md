# Luna ISRU Gas Processing & Skimmer Operations
**Created**: 2026-07-01
**Status**: Design Reference — Authoritative
**Location**: `docs/new_agent/projects/galaxy_game/summaries/`

---

## Overview

This document captures the authoritative design for Luna's ISRU gas processing
chain, Planetary Umbilical Hub bus architecture, skimmer docking operations,
and the progression from Earth-dependent imports to full resource self-sufficiency.

---

## 1. Planetary Umbilical Hub — Bus Architecture

The Planetary Umbilical Hub is a ground-deployed network unit that acts as a
bus/switch for all surface infrastructure. It has one umbilical connection to
the HLT craft and routes power, gases, and data between all connected units.

**Key principle**: Units do not connect directly to each other. All connections
route through the hub. This is the `register_to_bus` model — each unit registers
its ports with the hub, and the hub handles routing.

```
HLT Craft (landed)
    ├── [external rig port] Solar Rig (supplements HLT onboard power)
    ↕ umbilical (power out, LOX back-feed in)
Planetary Umbilical Hub  ← the bus
    ├── Regolith Harvester
    ├── TEU (Terrain Extraction Unit)
    ├── PVE (Processing/Venting Equipment)
    ├── Inflatable Pressure Tank (raw gas buffer)
    ├── Gas Separator
    ├── Inflatable Cryo Tanks (H2, O2, He3)
    └── Shell Printer
```

---

## 2. Precursor Automated Build Sequence

### Phase 1 — Power Establishment
- HLT lands, connects umbilical to Planetary Umbilical Hub
- Solar Rig (mounted on HLT external rig port) supplements HLT onboard power
- All ground units receive power via hub

### Phase 2 — Regolith Processing Begins
- Regolith Harvester delivers regolith to TEU
- TEU processes regolith:
  - Raw gas output (mostly O2, trace H2/He3) → Inflatable Pressure Tank
  - Depleted regolith → Shell Printer
- PVE also feeds raw gas → Inflatable Pressure Tank

### Phase 3 — Cryo Tank Inflation & Shell Printing
- Small amount of raw gas pumped into Inflatable Cryo Tanks
- Minimal pressurization — just enough to inflate tanks
- Shell Printer immediately prints protective regolith shells
  around partially inflated tanks
- Shells protect tanks for long-term surface operations
- Tanks then hold minimal pressure, waiting for skimmer deliveries

### Phase 4 — Gas Separation & LOX Production
- Inflatable Pressure Tank (raw gas buffer) feeds Gas Separator
- Gas Separator processes raw gas:
  - O2 (majority output) → LOX processing → back-fed to HLT tank
  - H2 (trace) → Inflatable Cryo Tank if worth capturing
  - He3 (trace) → Inflatable Cryo Tank if worth capturing
- LOX back-feed to HLT is the primary precursor phase output
- LDC's first revenue stream: LOX sold at 90% EAP

### Phase 5 — Self-Sustaining Operations
- LOX stockpile accumulates in HLT and ground cryo tanks
- LDC is operationally self-sustaining for return missions
- Landing pads ready to receive first skimmers

---

## 3. Gas Processing Economics

### LOX — Luna's First Mastered Resource
- Produced via regolith electrolysis (TEU/PVE → separator)
- Luna should achieve LOX self-sufficiency before first human arrival
- LDC prices LOX at 90% of EAP (Earth price + AstroLift transport)
- This undercuts Earth imports and captures the local market
- Earth LOX imports exist as emergency backstop only:
  - Early precursor phase before separator fully operational
  - Unexpected equipment failure
  - Surge demand from multiple simultaneous skimmer dockings
- **Goal**: Never pay EAP for LOX in normal operations

### CH4 — Luna's Key Dependency (Early Game)
- Luna cannot produce CH4 natively in early game
- Entirely dependent on Titan skimmer deliveries initially
- If Titan skimmer delayed or lost → Earth tanker at full EAP cost
- This is the most vulnerable supply chain dependency in early game

### CH4 Production Paths (Mid/Late Game)

**Path 1 — Sabatier Reaction (CO2 import)**:
- Import CO2 from Venus atmospheric processing or Earth
- Combine with H2 from water electrolysis or regolith processing
- Sabatier reaction: CO2 + 4H2 → CH4 + 2H2O
- Water byproduct feeds back into electrolysis loop
- Enables partial CH4 self-sufficiency if CO2 supply reliable

**Path 2 — Luna Ice Mining (Late Game)**:
- Water ice confirmed in permanently shadowed craters
- Survey action required to lazy-spawn ice deposits (not yet implemented)
- Ice mining → electrolysis → H2 + O2
- H2 + CO2 via Sabatier → CH4
- Fully closed loop if ice deposits sufficient
- LOX byproduct expands existing stockpile — double benefit

### CH4 Self-Sufficiency Progression
1. **Early**: CH4 entirely from Titan skimmer or Earth tanker
2. **Mid**: CO2 imports enable partial Sabatier production
3. **Late**: Luna ice mining enables full CH4 self-sufficiency

---

## 4. Skimmer Docking Operations

### Titan Skimmer
- **Delivers**: Raw Titan atmospheric mix
  - Primary: N2 (~95%)
  - Secondary: CH4 (~5%)
  - Traces: H2, Ar
- **Takes on**: LOX (produced locally by LDC)
- **Contingency**: If LDC LOX stockpile insufficient →
  AstroLift tanker from Earth delivers LOX before launch window

### Venus Skimmer
- **Delivers**: Raw Venus atmospheric mix
  - Primary: CO2 (~96%)
  - Secondary: N2 (~3.5%)
  - Traces: SO2, Ar, H2O
- **Takes on**: CH4 (from Titan atmospheric processing at LDC)
- **Contingency**: If LDC CH4 stockpile insufficient →
  AstroLift tanker from Earth delivers CH4 before launch window

### Docking Window Operations
Skimmers are mobile processing platforms, not passive tankers.
When docked at LDC base:

1. Skimmer connects umbilical to Planetary Umbilical Hub
2. LDC pumps fuel to skimmer (LOX for Titan, CH4 for Venus) — **priority**
3. Skimmer offloads bulk atmospheric gas to LDC cryo tanks (as capacity allows)
4. Skimmer onboard processors run during docking (supplements LDC separator)
5. **Goal**: Raw gas tanks fully emptied before departure
6. Launch window arrives → skimmer departs regardless of offload completion

**Key constraint**: LDC cryo tank capacity directly determines how much
gas can be received per docking window. Undersized tanks = wasted skimmer
capacity and potential gas venting.

### Fuel Interdependency
- Titan brings CH4 feedstock → LDC processes → fuels Venus skimmer
- LDC produces LOX → fuels Titan skimmer
- Once both routes mature, Earth tankers become unnecessary for fuel
- Until then, AstroLift is emergency backstop at full EAP cost

---

## 5. Gas Separator — Design Notes

### Precursor Phase Role
- Primary purpose: LOX production for HLT refuel and stockpile
- Secondary: capture trace H2/He3 if cryo tank capacity available
- Feedstock: raw regolith gas from TEU/PVE via Pressure Tank buffer

### Skimmer Phase Role
- Processes bulk atmospheric dumps from Titan and Venus skimmers
- Must handle mixed atmospheric gases (not pure products)
- Separation priorities differ by source:
  - Titan dump: extract CH4 (fuel), capture N2 (future atmosphere)
  - Venus dump: extract CO2 (Sabatier feedstock), capture N2

### Configurable Per Source
Gas Separator processing priorities should be configurable
per incoming gas source — Titan vs Venus vs regolith require
different separation strategies.

---

## 6. Hub Bus Routing — Implementation Status

**Current state (2026-07-01)**:
- LegacyPortAdapter implemented (commit b3beff34) — handles legacy
  port schemas via adapter pattern
- `connect_units` engine action exists and works via adapter
- `register_to_bus` engine action does NOT exist yet
- `task_deploy_gas_separator.json` currently uses `connect_units`
  (architecturally incorrect but functionally works via adapter)

**Required future work**:
- Implement `register_to_bus` case in `TaskExecutionEngineV2#execute_effect`
- Implement `register_to_bus_from_effect` method
- Migrate `task_deploy_gas_separator.json` from `connect_units`
  to `register_to_bus`
- Planetary Umbilical Hub unit needs bus routing logic
- Task file needed: `HIGH-ARCHITECTURE-HUB-BUS-ROUTING.md`

---

## 7. Deposit System Note

Luna ice deposits are lazy-spawned on survey action only.
PlausibilityEngine/DepositSpawner designed but not yet implemented
(deprioritized below Luna MVP). Ice mining (CH4 Path 2) cannot
be activated until deposit system is implemented.

---

## 8. AI Manager Implications

The AI Manager's resource planning needs to track:
- LOX stockpile vs projected skimmer docking schedule
- CH4 stockpile vs Venus skimmer launch window
- Cryo tank capacity vs incoming skimmer gas volume
- Emergency tanker trigger threshold (when to call AstroLift)
- Sabatier reactor CO2/H2 balance (mid game)

`EscalationService.handle_resource_shortage` is the current
hook for triggering emergency imports when stockpiles are
insufficient before a launch window.
