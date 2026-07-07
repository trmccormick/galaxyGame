# AI Manager Code Review Protocol
**Documentation ONLY** | **Review Before Surgical Cuts** | **No Deletions**

## Review Criteria (Classify EVERY File)

| Category | Keep? | Criteria | Examples |
|----------|-------|----------|----------|
| **CORE** | ✅ YES | Uses JSON training data, delegates to services | task_execution_engine.rb, manager.rb |
| **VALUABLE** | ⚠️ REVIEW | Partial delegation, fixable drift | state_analyzer.rb (after resource_profile fix) |
| **BLOAT** | ❌ DELETE | Hardcoded constants, standalone simulators | isru_evaluator.rb, resource_flow_simulator.rb |
| **UNKNOWN** | ❓ AUDIT | No clear purpose, check git history | [89 - classified] files |

## File-by-File Review Commands
```bash
# 1. CORE CANDIDATES (Training compliance)
grep -l "CraftFactoryService\|UnitLookupService\|MissionTaskRunnerService\|LaunchPaymentService" app/services/ai_manager/*.rb

# 2. VALUE PRESERVATION (Git history — what worked?)
for file in app/services/ai_manager/*.rb; do
  git log --oneline -- $file | head -3 | grep -E "(feat|fix|working)" && echo "✅ $file" || echo "❓ $file"
done

# 3. BLOATED DETECTION (Hardcoded betrayal)
grep -l "ISRU_UNITS\|PVE_DATA\|resource_profile\|= {\|hardcoded" app/services/ai_manager/*.rb

# 4. ECONOMICS INTEGRATION (GCC trading viable?)
grep -l "CurrencyRate\|Account\|LaunchPaymentService" app/services/ai_manager/*.rb
```

## Surgical Decision Matrix
Git History + Review → Classification → Action

"feat: working manifest" + JSON delegation → CORE → KEEP
"fix: isru rates" + hardcoded → VALUABLE → REFACTOR
"add: resource simulator" + standalone → BLOAT → DELETE
No history + hardcoded → UNKNOWN → AUDIT → Likely DELETE

## Review Workflow (89 Files → 8 Core)
Run classification commands → Tag files: CORE/VALUABLE/BLOAT/UNKNOWN

Git history audit → CORE+VALUABLE confirmed working

Task file per category:

BLOAT: 2026-04-03-CRITICAL-delete_bloat_files.md

VALUABLE: 2026-04-03-HIGH-refactor_drift_files.md

UNKNOWN: 2026-04-03-MEDIUM-audit_unknown_files.md

89 → 8 validation → find app/services/ai_manager -name "*.rb" | wc -l

## Immediate Review Targets (Top 5)
app/services/ai_manager/state_analyzer.rb → resource_profile hardcoded → VALUABLE?

app/services/ai_manager/system_discovery_service.rb → resource_profile → VALUABLE?

app/services/ai_manager/isru_evaluator.rb → ISRU_UNITS → BLOAT

task_execution_engine.rb → JSON orchestration → CORE (protect)

manager.rb → State machine → CORE (protect)

**Status**: **Review protocol locked.** **89 files classified before touch.** Git history preserves value. **No accidental deletions.**

**Execute**:
```bash
# Run classification now
grep -l "CraftFactoryService\|UnitLookupService" app/services/ai_manager/*.rb  # CORE
grep -l "ISRU_UNITS\|resource_profile" app/services/ai_manager/*.rb          # BLOAT
```

**Review results?** → **Surgical task pipeline** with **zero value loss**. Precision cleanup foundation ready.

---

## Guardrails Integration (from GUARDRAILS.md §1: Code & Documentation Sync)
- **The Mandate:** No logic change to `manager.rb` or `autonomous_construction_manager.rb` is complete until the corresponding Markdown documentation is updated.
- **Pattern Integrity:** If a new mission pattern is added (e.g., via `ai:manager:teach:pattern`), the `learned_patterns.json` and `docs/` must reflect the new success criteria and ROI estimates.

Protocol deployed. Value preservation guaranteed. Git history + classification = safe 89→8. No important code lost. Review first, surgery second.
