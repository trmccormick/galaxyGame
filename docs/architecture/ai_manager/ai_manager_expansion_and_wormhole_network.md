# AI Manager Expansion & Wormhole Network: Design & Requirements

## 1. AI Manager Role in Expansion
- The AI Manager (via DC corporations) is solely responsible for providing basic infrastructure and system footholds in new/existing star systems.
- It autonomously decides when and where to create artificial wormhole stations, which systems to target, and whether a connection is temporary or permanent.
- Expansion is data-driven, using mission/system JSONs and backend state—no hardcoded targets or flows.
- Players interact only via the market and their own corporations; all DC and wormhole network management is AI-driven.

## 2. Wormhole Network & Operation
- **Natural Wormholes:**
  - Appear via narrative/event triggers, not AI control.
  - Used for scouting/exploration; provide EM (Exotic Matter) for artificial wormhole creation/maintenance.
  - Collapse releases residual EM, which can be harvested.
- **Artificial Wormholes:**
  - Require EM, ideally harvested from natural wormholes (especially at closed natural wormhole sites).
  - Cold Starts (no local EM) are expensive, requiring EM import and higher maintenance.
  - AI Manager prioritizes sites with residual EM for cost efficiency.
  - Stabilization satellites use EM to maintain both natural and artificial wormholes.
  - System-specific gravitational factors (e.g., gas giant counterbalance) affect stability and must be considered.
- **Stabilization & Logistics:**
  - AI Manager deploys stabilization satellites and manages EM logistics.
  - Asset retrieval protocols ensure drones/satellites are not orphaned during wormhole shifts.
- **Economic Logic:**
  - Links are maintained only if resource extraction exceeds maintenance tax (5x for intergalactic links).
  - Strategic discard/mass dump is used if system yield is low.

## 3. Implementation Notes (from Wormhole Contract v1.2)
- SystemArchitect must reference environment classification for deployment priority.
- In Cold Start systems, AI must prioritize EM storage and local fuel production.
- Real-world planetary data is immutable; procedural systems are tagged for market bidding.

---

This document summarizes the AI Manager's expansion logic, wormhole network operation, and key requirements for robust, data-driven, and testable gameplay.