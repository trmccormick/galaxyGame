# TASK: Review game_data_generator_spec.rb:19 - Ollama dependency evaluation
**Status**: BACKLOG **Priority**: LOW **Type**: bug-fix **Created**: 2026-04-08

## Agent Assignment
**Assigned To**: Planning Agent  
**Why**: Architectural decision required before fix
**Supervision Level**: 🟡 Standard

## Context
GameDataGenerator spec:19 failing but feature is experimental and tied to Ollama (not running). Need to determine if this code path remains in scope.

## Problem Statement
- Line 19: Generators::GameDataGenerator generates and saves valid JSON item
- **Dependency**: Requires Ollama service (currently not running)  
- **Status**: Experimental feature - future needed?

## Decision Required
1. **Keep**: Fix spec + ensure Ollama integration works
2. **Remove**: Delete generator code + spec (if feature abandoned)  
3. **Replace**: Swap Ollama → simpler JSON generation

## Steps
1. Review: `app/services/generators/game_data_generator.rb` usage in app
2. Check: `grep -r "GameDataGenerator" app/ spec/`
3. **DECISION**: Keep/fix OR delete/replace
4. Update specs + code accordingly

## Dependencies
**Blocked by**: Human architectural decision on Ollama integration

## Notes
- Only proceed after confirming feature viability
- If keeping: ensure Ollama container + data pipeline works
- If removing: clean factory + all references