# Alpha Centauri Preparation Documentation

**Date:** 2026-01-15

## SOL-AC-01 Link Analysis

### Current Metrics
- **Maintenance Tax:** 752.5 EM/hour (Cold_Start environment)
- **Mass Limit:** 500,000 tons (Alpha Centauri system - full counterbalance effect)
- **Environment:** Cold_Start (high EM consumption)
- **Sabatier Offset:** Active (currently not implemented in ResourcePlanner)

### Cost Comparison
- **AOL-732356 Tax:** 33.3 EM/hour
- **AC-01 Tax:** 752.5 EM/hour
- **Ratio:** 22.6x more expensive than stabilized natural link

## Gap Analysis: Sabatier Offset Implementation

### Contract Configuration
```json
"logistics": {
  "fuel_bridge_active": true,
  "supply_origin": "SOL-CORE-01",
  "sabatier_offset_active": true
}
```

### Current Implementation Gap
- **WormholeMaintenanceJob:** Does not utilize `sabatier_offset_active` flag
- **ResourcePlanner:** No Sabatier process integration for fuel production
- **Result:** Offset logic exists in contract but not executed

### Required Implementation
1. **ResourcePlanner Enhancement:** Add Sabatier fuel production calculations
2. **Maintenance Job Update:** Apply fuel offset to reduce EM tax
3. **Fuel Bridge Integration:** Connect local fuel production to wormhole maintenance

## Mass-Ballast Requirements for Tax Reduction

### Current Anchor Configuration
- **Primary Anchor:** SOL system bodies (insufficient for AC-01 stabilization)
- **Ballast Strategy:** L3 Lagrange point counterbalance required

### Required Mass-Ballast Calculations
- **Minimum Anchor Mass:** 10^16 kg (Anchor Law requirement)
- **Current AC-01 Tax:** 752.5 EM/hour
- **Target Tax Reduction:** To 100 EM/hour (87% reduction)

### Ballast Addition Requirements
- **Additional Mass Needed:** 5.0 × 10^16 kg (5 × 10^16 kg total ballast)
- **Implementation:** Deploy 3 additional Phobos-class asteroids (1.67 × 10^16 kg each)
- **Tug Operations:** 3 relocation missions from asteroid belt
- **Estimated Tax Reduction:** 652.5 EM/hour savings (from 752.5 to 100 EM/hour)

### Phobos-Class Ballast Specifications
- **Mass Range:** 1.0 × 10^16 to 2.0 × 10^16 kg
- **Source:** Main asteroid belt between Mars and Jupiter
- **Relocation Method:** Asteroid Relocation Tug with slag propulsion
- **Stabilization Time:** 48 hours post-deployment
- **Fuel Cost:** 90% reduction via slag reaction mass

### Implementation Timeline
1. **Phase 1:** Survey and select 3 candidate asteroids
2. **Phase 2:** Tug deployment and hollowing operations
3. **Phase 3:** L3 positioning and stabilization
4. **Phase 4:** Tax reduction verification (48 hours post-stabilization)

### Economic Impact
- **Pre-Ballast Burn Rate:** 752.5 EM/hour from expansion budget
- **Post-Ballast Burn Rate:** 100 EM/hour
- **Annual Savings:** 5,832,000 EM units
- **Budget Relief:** Enables 3 additional wormhole links

### Risk Mitigation
- **Slag Propulsion Economy:** 90% fuel cost reduction for relocations
- **Anchor Law Compliance:** All ballast meets 10^16 kg minimum threshold
- **STE Ratio Maintenance:** Target STE > 10,000 for stability</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/systems/alpha_centauri_prep.md