# ADR-001: Bridge Implementation for Bus-Topology Migration

## Status
Active (Implementation Phase)

## Context
Legacy blueprints (e.g., `inflatable_cryo_tank`) show drift in port-definition formats between static blueprints and operational data, causing `luna_mission.rake` failures. We must support these files while transitioning to a `v1.9` bus-based connectivity.

## Decision: Adapter-Shim Pattern
We implement a `LegacyInterfaceAdapter` middleware within the `UniversalDockingService`. 

### Logic Requirements:
1. **Detection:** Service checks for `v1.9` `connection_schema`. 
   - If present: Use native connectivity.
   - If absent: Invoke `LegacyInterfaceAdapter`.
2. **Virtual Port Injection:** The Adapter dynamically maps legacy JSON fields (`ports`, `internal`, `external`, `connections`) to the `v1.9` `connection_schema` structure in memory.
3. **Lifecycle Flagging:** The Adapter MUST log all legacy conversions to `migration_needed.log`.

## Migration Workflow
1. Run `rake` mission task.
2. Review `migration_needed.log` for unit IDs.
3. Update specific JSON blueprints to `v1.9` standard.
4. Verify the log entry clears upon re-run.