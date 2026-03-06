# Fix ModuleLookupService Spec Path

## CRITICAL CONTEXT — DOCKER VOLUME MOUNT
**ALL AGENTS MUST READ:**
Host path:      ./data/json-data/
Container path: /home/galaxy_game/app/data/
These are the SAME directory via Docker volume mount.
NEVER hardcode either path in Ruby files or specs.
ALWAYS use GalaxyGame::Paths constants instead.
The constants exist specifically to handle this abstraction.

## Issue
1 failure: spec/services/lookup/module_lookup_service_spec.rb:49

## Fix
File to edit: spec/services/lookup/module_lookup_service_spec.rb

Change:

```ruby
# FROM:
expected_path = File.join(Rails.root, "data", "json-data", "operational_data", "modules")
# TO:
expected_path = GalaxyGame::Paths::MODULES_PATH.to_s
```

## Tasks
1. Edit spec/services/lookup/module_lookup_service_spec.rb line 49
2. Replace hardcoded path with GalaxyGame::Paths::MODULES_PATH.to_s
3. Run: rspec spec/services/lookup/module_lookup_service_spec.rb
4. Verify 1/1 green
5. Commit: Fix ModuleLookupService spec — use GalaxyGame::Paths::MODULES_PATH constant

## Success Criteria
- Spec passes 1/1
- No hardcoded paths remain
- Uses GalaxyGame::Paths constant

## Priority
MEDIUM — part of LookupService cluster fixes

## Time Estimate
10 minutes

## Agent Assignment
GPT-4.1 (simple spec file edit)