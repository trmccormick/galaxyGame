# Proposal: Bus-Topology Migration & Legacy Coexistence Strategy

## 1. The Challenge (Architectural Drift)
Our current simulation engine (`TaskExecutionEngineV2`) is failing to execute the `luna_mission.rake` test suite due to "Schema Drift." Legacy blueprint files (e.g., `inflatable_cryo_tank_bp.json`) contain hard-coded port counts that conflict with our operational data requirements. We need to evolve to a `v1.9` Bus-Topology while maintaining the ability to run missions using legacy assets.

## 2. The Solution: "Minimalist Bridge" Pattern
We are not refactoring the entire library of legacy files. Instead, we are implementing a **coexistence layer** that allows the engine to handle both formats simultaneously.

### Key Components:
* **The `LegacyInterfaceAdapter`:** A runtime translation layer in the `UniversalDockingService`. It detects if a unit is `v1.9` compliant; if not, it intercepts the legacy port data, calculates the virtual throughput, and injects it into the engine's memory.
* **Diagnostic Flagging:** To manage technical debt, any legacy unit processed by the adapter must trigger a `[DIAGNOSTIC - LEGACY CONVERSION]` log and append the ID to `migration_needed.log`.
* **ADR-001 Implementation:** We are formalizing this bridge in `ADR-001-Bridge-Bus-Topology.md` to ensure architectural consistency.

## 3. Goals for Claude's Review
1. **Verify the Adapter Logic:** Confirm that the `LegacyInterfaceAdapter` pattern correctly isolates legacy blueprint debt from modern simulation logic.
2. **Review Deployment Path:** Validate that our "Shim-First" coexistence model provides a sustainable path for phased refactoring rather than an immediate global overhaul.
3. **Approve Specification:** Validate the `PORT_CONNECTION_SYSTEM.md` (v1.9) as the target schema for all new asset development.