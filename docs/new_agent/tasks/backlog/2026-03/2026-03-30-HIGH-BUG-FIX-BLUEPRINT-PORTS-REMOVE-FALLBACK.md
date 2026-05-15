# 2026-03-30-HIGH-BUG-FIX-BLUEPRINT-PORTS-REMOVE-FALLBACK

**Agent Assignment**: 0.33x (documentation/bugfix tasks)  
**Estimated Time**: 2-4 hours  
**Priority**: HIGH  
**Status**: BACKLOG  

## Context
HasBlueprintPorts concern provides port definitions to craft models by looking up the craft's blueprint. Port counts are physical constraints — a basic shuttle cannot have more ports than its blueprint defines. The current implementation has two critical bugs that violate the blueprint-driven design philosophy:
1. A hardcoded fallback to 'generic_satellite' blueprint for all craft types
2. A default port fallback returning 5 ports of each type when no blueprint found

These bugs mean misconfigured or missing blueprints silently give crafts more ports than intended, breaking game balance and economic differentiation.

**Relevant Architecture Docs** — read before starting:
- `docs/agent/README.md` — key architectural decisions
- `docs/GUARDRAILS.md` — architectural constraints

## Problem
`has_blueprint_ports.rb` contains two bugs:

**Bug 1 — Hardcoded blueprint ID:**
```ruby
blueprint_id = 'generic_satellite'  # ← every craft looks up satellite blueprint first
blueprint_data = blueprint_service.find_blueprint(blueprint_id, 'satellite')
```

**Bug 2 — Silent fallback hiding misconfigured blueprints:**
```ruby
# Return default ports if no blueprint data found
{
  'internal_module_ports' => 5,
  'external_module_ports' => 5,
  'internal_rig_ports' => 5,
  'external_rig_ports' => 5
}
```

**Current behavior**: Every craft falls through to generic_satellite lookup, then to 5-port fallback if blueprint missing  
**Expected behavior**: Each craft looks up its own blueprint only. If no ports defined, return nil and raise a clear error — never silently grant ports.

## Files
### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|------|---------|-------------------|
| `app/models/concerns/has_blueprint_ports.rb` | Port lookup concern | `#get_ports_data` |

### Reference Files — read but do not edit
| File | Why You Need It |
|------|----------------|
| `app/models/craft/base_craft.rb` | How craft implements `default_blueprint_id` and `blueprint_category` |
| `app/models/craft/satellite/base_satellite.rb` | Satellite-specific blueprint implementation |
| `spec/services/fitting_service_spec.rb` | Stubs get_ports_data — verify still passes after fix |

## Steps
1. **Audit default_blueprint_id implementations**
   ```bash
   grep -rn "def default_blueprint_id\|def blueprint_category" app/models/craft/
   ```
   Confirm every craft model implements both methods before removing fallback.

2. **Remove hardcoded generic_satellite lookup**
   Remove lines 9-13 from `has_blueprint_ports.rb`:
   ```ruby
   # REMOVE THIS BLOCK:
   blueprint_id = 'generic_satellite'
   blueprint_data = blueprint_service.find_blueprint(blueprint_id, 'satellite')
   if blueprint_data&.dig('ports')
     return blueprint_data['ports']
   end
   ```

3. **Remove silent fallback, add clear error**
   Replace the fallback block with:
   ```ruby
   Rails.logger.error "No ports data found for #{self.class.name} " \
                      "(blueprint_id: #{blueprint_id}, category: #{blueprint_category})"
   nil
   ```

4. **Update callers to handle nil**
   Verify `available_module_ports` and `available_rig_ports` in concerns handle nil gracefully:
   ```ruby
   def available_module_ports
     ports_data = get_ports_data
     return nil unless ports_data
     (ports_data['internal_module_ports'] || 0) + 
     (ports_data['external_module_ports'] || 0)
   end
   ```

5. **Verify**
   ```bash
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/fitting_service_spec.rb'
   ```
   ```bash
   docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/craft/'
   ```

## Acceptance Criteria
- [ ] No hardcoded `generic_satellite` reference in `has_blueprint_ports.rb`
- [ ] No silent fallback returning default port counts
- [ ] Missing blueprint logs a clear error and returns nil
- [ ] All craft specs still pass
- [ ] `fitting_service_spec` still passes (uses stub, unaffected)
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs

## Stop Condition
Escalate to user immediately if:
- Any craft model does not implement `default_blueprint_id` or `blueprint_category`
- Removing fallback causes cascade failures across many specs
- Settlement models are found to depend on this concern
- Blueprint files missing from container for any craft type

## Commit Message
`fix: remove hardcoded blueprint fallback in HasBlueprintPorts concern

- Remove generic_satellite hardcoded lookup
- Remove silent 5-port fallback, add error logging
- Ensure blueprint-driven port constraints work correctly
- Prevent silent granting of extra ports to misconfigured crafts`