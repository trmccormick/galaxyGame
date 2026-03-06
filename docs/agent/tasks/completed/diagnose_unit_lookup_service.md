# Diagnose UnitLookupService

## CRITICAL CONTEXT — DOCKER VOLUME MOUNT
**ALL AGENTS MUST READ:**
Host path:      ./data/json-data/
Container path: /home/galaxy_game/app/data/
These are the SAME directory via Docker volume mount.
NEVER hardcode either path in Ruby files or specs.
ALWAYS use GalaxyGame::Paths constants instead.
The constants exist specifically to handle this abstraction.

## Issue
16 failures: spec/services/lookup/unit_lookup_service_spec.rb

## Diagnosis Task
This is a DIAGNOSIS task first — do not attempt fixes without output

Run and paste back output:

```bash
docker exec -it web bundle exec rspec spec/services/lookup/unit_lookup_service_spec.rb --format documentation 2>&1 | tail -50
```

Report output to Claude for fix diagnosis before making any changes

## Tasks
1. Run the diagnosis command above
2. Capture the last 50 lines of output
3. Report the output back for Claude's analysis
4. Wait for Claude's guidance on fixes before proceeding

## Success Criteria
- Diagnosis output captured and reported
- No changes made to code yet
- Claude provides fix guidance

## Priority
MEDIUM — part of LookupService cluster fixes

## Time Estimate
5 minutes (diagnosis only)

## Agent Assignment
GPT-4.1 (diagnosis and reporting)