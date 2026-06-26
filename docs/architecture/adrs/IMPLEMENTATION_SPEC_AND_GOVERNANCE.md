# Technical Specification & Governance

## Part A: The Target Schema (v1.9 Bus-Topology)
All new assets must implement the `connection_schema` (replacing legacy `ports` and `connections`):
* **Mounting Slots (Structural):** Unique `id`, `type`, `location`, `max_mass_kg`.
* **Utility Ports (Logical):** Unique `id`, `type` (power/fluid/data), `bus_id`, `throughput_limit`.

## Part B: Operational Rules (Guardrails)
1. **Engine Restriction:** The simulation engine MUST NOT read legacy `ports` or `connections` arrays directly. Access must be routed through the `LegacyInterfaceAdapter`.
2. **Logging Requirement:** Every legacy conversion must be recorded in `migration_needed.log` during test runs.
3. **Migration Workflow:**
   - Run `rake` tasks.
   - Audit `migration_needed.log`.
   - Update identified JSON blueprints to `v1.9` standard.
   - Verify log entries disappear upon successful re-run.

## Part C: Architectural Decision (ADR-001)
* **Status:** Active (Implementation Phase).
* **Strategy:** Virtual Port Injection via Adapter Shim.
* **Consequences:** Preservation of legacy data integrity; temporary complexity in docking services; clear audit trail of technical debt.