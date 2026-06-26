# GUARDRAILS: Galaxy Game Development

## Versioning & Compatibility Policy
- **Coexistence Strategy:** Legacy formats (JSON blueprints/operational data) remain the source of truth for existing assets.
- **Adapter Pattern:** New simulation logic must interact with data via the `LegacyInterfaceAdapter`. 
  - The engine must NEVER read legacy `ports` or `connections` arrays directly.
  - All unit connections must be resolved through the `LegacyInterfaceAdapter` (or `connection_schema` for v1.9 assets).
- **Flagging Requirements:** Any system triggering a legacy-to-bus conversion must emit a diagnostic log (`[DIAGNOSTIC - LEGACY CONVERSION]`) and append the unit ID to `migration_needed.log`.

## Development Workflow
- **Test Cycles:** When running `rake` tests, developers must review `migration_needed.log` post-execution.
- **Migration Path:** Manual refactoring of JSON blueprints to `v1.9` Bus-Topology is required once a unit's `migration_needed.log` entry is identified and the test sequence is stable.