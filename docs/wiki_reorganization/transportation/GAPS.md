# Transportation Documentation Gaps — Tracking File

**Status**: Active  
**Created**: 2026-09-15  
**Last Updated**: 2026-09-15  
**Purpose**: Track discrepancies between Transportation documentation, implementation, and backlog coverage

---

## Gap A: GCC Mining Issuance-Routing Alignment — UNRESOLVED

**Description**: GCC's canonical policy is LDC-controlled simulated-compute issuance with newly issued GCC intended for the existing LDC GCC account. Inspected mining source paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard.

**Evidence**:
- `transportation/02-gcc-mining-satellite.md` verified evidence: "Current mining source paths show inconsistent recipient routing and lack a demonstrated LDC authorization guard."
- Economy doc `economy/02-currencies-and-accounts.md` Section 9: GCC policy states newly issued GCC is intended for the existing LDC GCC account.
- No source-level audit confirmed an LDC authorization guard exists in any mining path.

**Impact**: Documentation cannot claim that LDC-only GCC recipient routing is currently enforced at runtime. Any future implementation must add and verify an authorization guard before canonical adoption.

**Backlog Coverage**: None — no active or backlog task addresses the authorization guard implementation or verification.

---

## Gap B: Mining Cadence and Rate Semantics — UNRESOLVED

**Description**: Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values exist in operational data but no verified active consumer is shown. Tick, scheduled-job, and mission mining triggers coexist; their timing and settlement semantics remain under alignment.

**Evidence**:
- `transportation/02-gcc-mining-satellite.md` verified evidence: "Satellite-level `*_per_hour` mining-rate fields and configured cap/halving/difficulty/block-reward values must not be represented as active runtime controls without verified source evidence."
- Economy doc `economy/02-currencies-and-accounts.md`: References 1,000 GCC/hour per satellite and 6-hour cycle intervals but no active consumer of these fields was identified.
- No service-level verification confirms any mining rate field is consumed at runtime.

**Impact**: Numeric mining rates, caps, halving schedules, and difficulty values cannot be documented as active runtime controls. Any future documentation must await verified source evidence before representing these as operational parameters.

**Backlog Coverage**: None — no active or backlog task addresses mining cadence unification or rate-field consumer verification.

---

## Gap C: Craft Lifecycle Coverage — UNRESOLVED

**Description**: Maintenance, repair, and lifecycle decommissioning are not established as implemented craft behavior by the current evidence. A craft undergoing construction, repair, upgrade, or refit is not in normal operations, but this constraint is not currently runtime-enforced.

**Evidence**:
- `transportation/01-craft-taxonomy.md` explicit exclusions: "Maintenance, repair, and lifecycle decommissioning are not established as implemented craft behavior by the current evidence."
- `transportation/02-gcc-mining-satellite.md` what cannot be claimed yet: "Maintenance, repair, and lifecycle decommissioning" is listed as unestablished.
- No source-level audit confirmed craft lifecycle enforcement in any service or model.

**Impact**: Craft lifecycle behavior (maintenance, repair, decommissioning) cannot be documented as implemented gameplay. Any future documentation must await source evidence before representing these as operational systems.

**Backlog Coverage**: None — no active or backlog task addresses craft lifecycle implementation or verification.
