# 2026-02-11-HIGH-GUARDRAILS-SPLIT.md

**Agent**: 0.33x
**Priority**: HIGH
**Type**: DOCS
**Name**: Guardrails Split

## Context
Monolithic guardrails documentation needs to be split into modular, actionable sections for maintainability and clarity. The current GUARDRAILS.md file contains multiple sections that should be separated for better organization.

## Problem
The GUARDRAILS.md file is a large monolithic document that covers multiple topics including:
- Agent role boundaries
- Universal docking & chassis integration
- Various other guardrails and rules

This makes it difficult to maintain and reference specific sections.

## Files
- Target: `docs/GUARDRAILS.md`
- Location: `docs/`

## Steps
1. Analyze current GUARDRAILS.md structure and identify logical sections
2. Create separate files for each major section:
   - `docs/guardrails/agent-roles.md` - Agent role boundaries and permissions
   - `docs/guardrails/docking-integration.md` - Universal docking and chassis rules
   - `docs/guardrails/environment-rules.md` - Host/container environment rules
   - `docs/guardrails/index.md` - Main guardrails index file
3. Update main GUARDRAILS.md to reference the new modular files
4. Ensure all cross-references are maintained

## Acceptance Criteria
- GUARDRAILS.md is split into logical, modular sections
- Each section is in its own file under `docs/guardrails/`
- Main GUARDRAILS.md serves as an index pointing to sections
- All existing content is preserved
- Cross-references between sections work correctly

## Stop Condition
- Modular guardrails structure is implemented
- All sections are properly linked
- No content is lost in the split

## Commit
`docs: split guardrails into modular sections`