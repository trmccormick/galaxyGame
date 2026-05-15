# 2026-04-08-LOW-BUG-FIX-GAME-DATA-GENERATOR-SPEC-19-OLLAMA-REVIEW

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Bug fix review for game data generator spec Ollama dependency
**Supervision Level**: 🔴 Watched carefully

## Context
GameDataGenerator spec:19 failing due to Ollama service dependency (not running). Feature is experimental and tied to external service. Need architectural decision on whether to keep, remove, or replace the Ollama integration.

## Problem Statement
Line 19 in game_data_generator_spec.rb failing: "Generators::GameDataGenerator generates and saves valid JSON item" requires Ollama service which is not running.

**Decision required**:
1. Keep: Fix spec + ensure Ollama integration works
2. Remove: Delete generator code + spec (if feature abandoned)
3. Replace: Swap Ollama → simpler JSON generation

## Files Involved
### Primary Files — you will edit
| File | Purpose |
|---|---|
| `app/services/generators/game_data_generator.rb` | Game data generator with Ollama dependency |
| `spec/services/generators/game_data_generator_spec.rb` | Failing spec at line 19 |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| All files referencing GameDataGenerator | Determine usage scope |

## Implementation Steps
1. **Review usage**: Check how GameDataGenerator is used in the application
2. **Architectural decision**: Determine if Ollama integration should be kept, removed, or replaced
3. **Implement decision**: 
   - If keeping: Fix Ollama integration and spec
   - If removing: Delete generator code and spec
   - If replacing: Implement simpler JSON generation
4. **Verify**: Ensure spec passes or is removed

## Acceptance Criteria
- [ ] Clear architectural decision made on Ollama integration
- [ ] Spec either passes (if kept) or is removed (if abandoned)
- [ ] No broken references if feature removed
- [ ] Ollama container and data pipeline working if kept

## Stop Conditions
- Feature viability unclear without human architectural decision
- Multiple dependencies on Ollama integration found
- Replacement implementation more complex than expected

## Commit Instructions
```bash
git add app/services/generators/game_data_generator.rb
git add spec/services/generators/game_data_generator_spec.rb
git commit -m "fix: game_data_generator_spec — resolve Ollama dependency based on architectural decision"
```