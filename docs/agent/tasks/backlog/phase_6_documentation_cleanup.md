# Phase 6: Documentation & Guardrails - Material Naming Standards

## Problem Description
The codebase has inconsistent material naming conventions that lead to violations of the data-driven architecture. Documentation contains hardcoded resource lists and common names instead of chemical formulas, perpetuating anti-patterns.

## Root Cause Analysis
1. **Documentation Violations**: Files like `PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md` contain hardcoded location-specific resource lists
2. **Inconsistent Naming**: Mix of common names ('water', 'oxygen') and chemical formulas (H2O, O2) throughout codebase
3. **Missing Standards**: No codified material naming protocol for developers to follow

## Required Fixes

### Fix 1: Update PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md
**File**: `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md`
**Location**: Resource capability sections
**Change**: Replace hardcoded resource lists with data-driven query examples:
```markdown
# BEFORE (hardcoded):
Luna: oxygen, water, regolith

# AFTER (data-driven):
Luna: Query geosphere.crust_composition for available geological materials, atmosphere.gases for volatiles
```

### Fix 2: Create Material Naming Standards Document
**File**: `docs/developer/MATERIAL_NAMING_STANDARDS.md` (new file)
**Content**:
- Chemical Formula Protocol: ALWAYS use H2O, O2, CO2, CH4, not common names
- Regolith Procedural System: Never assume universal regolith, always query source_body
- Liquid Material Support: Hydrosphere supports any liquid (CH4, H2O, C2H6, NH3)
- Atmosphere Gases: Always chemical formulas, stored in atmosphere.gases table
- Material Lookup: MaterialLookupService.normalize_to_formula(common_name) → formula

### Fix 3: Enhance Code Review Checklist
**File**: `docs/developer/CODE_REVIEW_CHECKLIST.md`
**Location**: Add new sections
**Change**: Add architectural compliance and material naming validation sections

### Fix 4: Update GROK_TASK_PLAYBOOK.md
**File**: `docs/developer/GROK_TASK_PLAYBOOK.md`
**Location**: Add new section
**Change**: Add "Data-Driven Validation Protocol" pre-commit checklist

## Testing Requirements
- Cross-reference updated docs with existing architecture docs
- Verify consistency with hydrosphere_system.md and regolith.json
- Ensure no hardcoded material references remain in documentation

## Validation Steps
- [ ] PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md uses data-driven examples only
- [ ] MATERIAL_NAMING_STANDARDS.md created with comprehensive guidelines
- [ ] CODE_REVIEW_CHECKLIST.md includes material naming validation
- [ ] GROK_TASK_PLAYBOOK.md has data-driven validation protocol
- [ ] All documentation commits made on host machine (not Docker)

## Files to Modify
1. `docs/ai_manager/PRECURSOR_INFRASTRUCTURE_CAPABILITIES.md`
2. `docs/developer/MATERIAL_NAMING_STANDARDS.md` (new)
3. `docs/developer/CODE_REVIEW_CHECKLIST.md`
4. `docs/developer/GROK_TASK_PLAYBOOK.md`

## Commit Message
"docs: implement Phase 6 material naming standards and guardrails"</content>
<parameter name="filePath">/Users/tam0013/Documents/git/galaxyGame/docs/agent/tasks/backlog/phase_6_documentation_cleanup.md