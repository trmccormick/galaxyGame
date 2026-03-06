# NPCColony Obsolete Cleanup
**Task ID**: NPCColony_Obsolete_Cleanup
**Priority**: HIGH
**Status**: PENDING
**Created**: March 5, 2026

## Description
Remove obsolete Settlement::NPCColony model + all related files and references
Superseded by BaseSettlement + AI Manager architecture

## Steps
1. SEARCH: grep -r "NPCColony" app/ spec/ lib/ db/ --exclude-dir=log
2. DELETE app/models/settlement/n_p_c_colony.rb
3. DELETE spec/models/settlement/n_p_c_colony_spec.rb
4. DELETE any factories: spec/factories/**/npc_colon*.rb
5. CHECK migrations: grep -r "npc_colon" db/migrate/ (remove if NPCColony-specific)
6. VERIFY: grep -r "NPCColony" app/ spec/ lib/ (should be clean)
7. COMMIT: "Remove obsolete NPCColony (BaseSettlement + AI Manager)"

## Dependencies
None

## Estimated Time
5 minutes

## RSpec Impact
254 failures → 254 failures (pending specs removed)

## Handoff Agent
GPT-4.1 (execution)