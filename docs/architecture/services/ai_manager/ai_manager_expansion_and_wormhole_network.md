# AI Manager Expansion & Wormhole Network: Design & Requirements
## docs/architecture/ai_manager/ai_manager_expansion_and_wormhole_network.md
## Status: Authoritative — updated March 15, 2026


## 1. AI Manager Role in Expansion

  basic infrastructure and system footholds in new/existing star systems.
  stations, which systems to target, and whether a connection is temporary
  or permanent.
  no hardcoded targets or flows.
  and wormhole network management is AI-driven.

### DC Expansion Financial Model

Expansion decisions are governed by the DC financial model. The AI Manager
only initiates expansion when:

1. Tier 1 and Tier 2 priorities are clear (no life support or debt issues)
2. Capital reserve is sufficient for the expansion cost
3. Projected resource extraction exceeds maintenance tax (see Section 2)

LDC is the genesis DC and primary expansion sponsor. New system DCs receive
initial virtual ledger allocation from LDC, repaid from operating surplus.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
Section 4 (Inter-DC Sponsorship Model) for the full sponsorship chain and
Section 6 for expansion priority logic.


## 2. Wormhole Network & Operation

### Natural Wormholes

### Artificial Wormholes
  closed natural wormhole sites)
  maintenance. AI Manager prioritizes sites with residual EM for cost
  efficiency.
  wormholes
  affect stability and must be considered

### Stabilization & Logistics
  during wormhole shifts

### Economic Logic

Links are maintained only if resource extraction exceeds maintenance tax:
  drain for longer distances)

**Connection to DC economics:** Wormhole maintenance is an operating expense
for the DC managing that link. A link that costs more than it generates
degrades the DC's financial health, potentially triggering `debt_repayment`
priority and suspending expansion. The AI Manager continuously evaluates
link ROI.

See `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
Section 3 (Construction Cost Model) for the profitability evaluation formula.


## 3. System Completion on Wormhole Opening

When a natural or artificial wormhole opens to a new system, the AI Manager
triggers system completion based on available data:

### Known Systems (e.g., Alpha Centauri)
  - Habitable zone body identification
  - Atmospheric composition (if known)
  - Local resource availability
  - Radiation/magnetic field threats
  - Gravity and surface conditions

### Procedural Systems
  (planned — see backlog)
- Settlement viability score computed for each candidate body

### Data Philosophy
The game reflects reality: many properties of distant bodies are unknown.
Fields that cannot be scientifically inferred are left nil — not fabricated.
See `docs/architecture/ai_manager/geosphere_initializer_procedural_architecture.md`

---

## 4. Implementation Notes (from Wormhole Contract v1.2)

- `SystemArchitect` must reference environment classification for deployment
  priority
- In Cold Start systems, AI must prioritize EM storage and local fuel
  production
- Real-world planetary data is immutable; procedural systems are tagged
  for market bidding

---

## Related Documents
- `docs/architecture/ai_manager/AI_MANAGER_CONSTRUCTION_ECONOMICS.md`
  — DC financial model, inter-DC sponsorship, expansion priority logic
- `docs/architecture/ai_manager/AI_PRIORITY_SYSTEM.md`
  — Priority tiers including expansion triggers
- `docs/architecture/PRICE_DISCOVERY_LIFECYCLE.md`
  — EAP, transport costs, wormhole transit fees
- `docs/architecture/ai_manager/CYCLER_SYSTEM_ARCHITECTURE.md`
  — Cycler deployment for new system access
- `docs/architecture/ai_manager/geosphere_initializer_procedural_architecture.md`
  — Procedural body generation for new systems
