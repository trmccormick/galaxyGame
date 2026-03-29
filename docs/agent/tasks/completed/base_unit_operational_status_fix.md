# [COMPLETED] BaseUnit operational? fix

- Updated Units::BaseUnit#operational? to read from operational_data['operational_properties']['status'].
- Added/updated specs to verify correct behavior for 'active', 'offline', 'disabled', and legacy (no status) cases.
- All tests pass, confirming correct operational state logic.
- No direct status/active/operational columns are used; operational_data is the single source of truth.
- Task completed and committed on 2026-03-29.
