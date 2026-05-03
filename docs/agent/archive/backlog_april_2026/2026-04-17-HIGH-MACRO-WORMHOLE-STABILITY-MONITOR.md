# Wormhole Stability Monitor (Template-Compliant Rewrite)

**Date:** 2026-04-17
**Priority:** HIGH
**Layer:** MACRO (Network/Physics)
**Status:** TODO
**Agent Assignment:** Claude (reviewed by Copilot)

---


## Context & Rationale

Each star system maintains its own data network. Stations and bases act as data nodes—relaying, processing, and storing information much like an interstellar internet. Information—including wormhole network health, emails, market data, GCC (the crypto system), and more—is updated between systems as craft travel between them. Data propagates outward as ships move, with manifests and ACKs relaying the latest state. Issues with data integrity, staleness, or spoofing can occur at these transfer points, making robust validation and taint propagation essential. The manifest/relay-based architecture (see [courier_network_plan.md](../../planning/courier_network_plan.md)) is the canonical method for monitoring and maintaining network health, and this task formalizes its implementation and integration.

**Key References:**
- [courier_network_plan.md](../../planning/courier_network_plan.md)
- [GEMINI-CHAT.md](../../planning/GEMINI-CHAT.md)
- [RESTORATION_AND_ENHANCEMENT_PLAN.md](../../planning/RESTORATION_AND_ENHANCEMENT_PLAN.md)

---

## Scope
- Implement manifest/relay-based wormhole stability monitoring as described in the Courier Network Plan.
- Integrate with station operational profiles (AWS/NWA) for health, tension, and counterbalance monitoring.
- Ensure taint propagation, spoofing detection, and ACK confirmation logic are enforced.
- Trigger stabilization protocols and mission generation on instability or taint events.

---

## Target Files
- app/models/manifest.rb
- app/models/ack_receipt.rb
- app/services/manifest_verifier.rb
- app/services/wormhole_stability_monitor.rb (integration point)
- app/models/aws_station.rb
- app/models/base_craft.rb
- spec/services/wormhole_stability_monitor_spec.rb
- spec/services/manifest_verifier_spec.rb

---

## Acceptance Criteria
- [ ] Manifest model implements hash-chained integrity, versioning, and taint propagation.
- [ ] Station relay logic (AWS/NWA) broadcasts manifests and validates ACKs.
- [ ] ManifestVerifier service validates chains, detects spoofing, and triggers taint propagation.
- [ ] Emergency stabilization protocols and mission triggers on instability/taint.
- [ ] RSpec coverage for all core logic and edge cases.

---

## Implementation Steps
1. **Manifest Model:** Implement/extend hash-chained manifest logic, versioning, and taint propagation fields.
2. **Station Relay:** Integrate broadcast and ACK logic into AWS/NWA operational profiles.
3. **ManifestVerifier:** Implement chain validation, spoofing detection, and taint propagation.
4. **Wormhole Stability Monitor:** Integrate manifest/relay health checks and stabilization triggers.
5. **Mission Generation:** Trigger auditor/stabilization missions on taint/instability events.
6. **RSpec:** Write/extend tests for all new/modified logic.
7. **Documentation:** Update/verify [courier_network_plan.md] and related docs for implementation details.

---

## Audit/Stop Conditions
- Confirm no duplicate or obsolete wormhole monitoring logic exists outside the manifest/relay system.
- All acceptance criteria met and verified by RSpec.
- Documentation updated and cross-referenced.
- Commit with message: `feat: implement manifest/relay-based wormhole stability monitoring`

---

## Notes
- This task supersedes all prior wormhole stability monitoring logic not based on the manifest/relay architecture.
- See [courier_network_plan.md](../../planning/courier_network_plan.md) for canonical requirements and edge cases.
