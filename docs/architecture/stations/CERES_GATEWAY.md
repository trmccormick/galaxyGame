# CERES GATEWAY — Belt-to-Mars Forward Operating Base

**Phase 3.5 Infrastructure — Prerequisite for Mars Phase 4 & Venus Phase 6**

---

## 1. Mission & Role
Ceres Gateway is the primary refueling, resource-funneling, and processing hub for the Belt-to-Mars industrial pipeline. It acts as the Forward Operating Base (FOB) for all deep-belt operations, enabling Mars-Direct logistics and supporting Asteroid Relocation Tug missions.

---

## 2. Standard Tier 1 Equipment Setup
- **Mining Drones:** 20
- **Drone Bays:** 8
- **Bulk Haulers:** 12
- **Refinery Modules:** 4 (minimum, scalable)
- **Water-Ice Harvesters:** 6
- **Tug Docking Ports:** 4
- **Survey Rovers:** 5

*Source: ceres_settlement mission manifest*

---

## 3. The Pivot — Refueling Protocol
- **Fuel Storage:**
  - Water-Ice: 10,000 m³ (raw)
  - Hydrogen: 2,000 m³ (refined)
  - Oxygen: 2,000 m³ (refined)
- **Tug Refueling:**
  - Each Tug turnaround: 500 m³ H₂ + 500 m³ O₂ (standard cycle)
  - Simultaneous refueling: Up to 4 Tugs
- **Hauler Refueling:**
  - 100 m³ H₂ + 100 m³ O₂ per hauler
- **Protocol:**
  - All Tugs and Haulers must refuel at Ceres before Mars transfer; Luna-return is not permitted in the default flow.

---

## 4. The Sieve — Processing & Waste Management
- **Ore Intake:** 100 units (raw Belt ore)
- **Refined Output:** 35 units (export-grade)
- **Waste Mass:** 65 units (slag, volatiles, tailings)
- **Waste-to-Refined Ratio:** 65:35
- **Processing:**
  - Low-G sieving and plasma refining
  - Waste is stored or ejected; only refined mass is sent to Mars

---

## 5. Logistics Flow — Mars-Direct Default
- **Resource Funnel:**
  - Belt → Ceres (processing, refueling) → Mars (no Luna detour)
- **Phase Gating:**
  - Ceres Gateway must be operational to unlock:
    - Mars Phase 4 (Small Moon Conversion, Shipyard Construction)
    - Venus Phase 6 (Artificial Moon Positioning, Resource Export)
- **Expanse-Style Gateway:**
  - Ceres is the only approved FOB for Belt-to-Mars direct flow
  - All mission planners and AI routines must default to Ceres for Belt resource routing

---

## 6. Verification & Integration
- **Manifest Alignment:**
  - Equipment and fuel volumes match ceres_settlement mission manifest
- **Deployment Sequence:**
  - NPC_INITIAL_DEPLOYMENT_SEQUENCE.md must reflect Ceres as the Phase 3.5 gateway, enforcing Mars-Direct flow
- **Orphaned Logic:**
  - All drone counts, rover roles, and refueling logic are now formalized here

---

## 7. Future Expansion
- **Spin-Gravity Module:** Planned for crew health (not yet standard)
- **Hollowed-Rock Conversion:** Under review for Tier 2 upgrades
- **Automated Waste Export:** Next-gen haulers to remove slag to outer belt

---

*This document supersedes all prior chat and JSON-only Ceres Gateway logic. All Belt-to-Mars logistics must reference this protocol as canonical.*
