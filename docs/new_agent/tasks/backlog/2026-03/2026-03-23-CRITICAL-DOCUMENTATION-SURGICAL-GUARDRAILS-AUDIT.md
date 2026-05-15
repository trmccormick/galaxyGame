# 2026-03-23-CRITICAL-DOCUMENTATION-SURGICAL-GUARDRAILS-AUDIT

**Agent:** GPT-4.1 (0.33x)
**Priority:** CRITICAL
**Type:** DOCUMENTATION
**Status:** BACKLOG

## Context
GUARDRAILS.md has grown to 681 lines containing mixed agent operating rules and game design decisions. This task performs a surgical audit to split the content properly.

## Problem
GUARDRAILS.md contains both agent operating rules and game design logic that should be separated into specialized documentation.

## Files
- docs/GUARDRAILS.md
- docs/architecture/
- docs/mission_profiles/
- docs/GLOSSARY_SYSTEM_MECHANICS.md

## Steps
1. Analyze GUARDRAILS.md to locate "Wormhole Anchor Law" and "Economic Overheads"
2. Verify against Glossary to ensure 0.5% SCC, 0.3% Broker, and 3.37% Sales Tax match updated GLOSSARY_SYSTEM_MECHANICS.md
3. Execute split: Move Game Design logic to docs/architecture/ and Mission logic to docs/mission_profiles/
4. Clean root: Leave only Agent Operating Rules (Git, Docker, Atomic Commits) in GUARDRAILS.md

## Acceptance Criteria
- GUARDRAILS.md is < 150 lines and contains strictly technical agent protocols
- No game design logic remains in the root Guardrails

## Stop Condition
- Game design logic found remaining in GUARDRAILS.md after migration

## Commit Instructions
```
git add docs/GUARDRAILS.md docs/architecture/ docs/mission_profiles/
git commit -m "docs: surgical guardrails audit — split game design from agent protocols"
```