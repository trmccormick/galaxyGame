---
title: Continue Gem Workflow Audit
date: 2026-05-18
maintained_by: Session Strategist (Claude via GitHub Copilot)
status: DRAFT - Under Testing
---

# Continue Gem Integration & Workflow Audit

**Last Updated**: 2026-05-18  
**Status**: DRAFT — Continue is new, models still being tested  
**Purpose**: Document the emerging local-agent workflow and Qwen3.5 task rewriting results

---

## What is Continue?

Continue is a VS Code extension that provides a local-first AI interface to ollama models running on your network cluster. It:
- Runs directly in VS Code editor
- Accesses files on the host filesystem via file tools
- Connects to local ollama nodes via HTTP APIs
- Cannot execute terminal commands, Docker, RSpec, or git
- Can read and edit files provided via Continue's file interface

**Key constraint**: Local models only know what they can read from files. They cannot verify commands succeeded or see test output without it being pasted into the chat.

---

## Current Qwen3.5 Model Lineup (Continue)

### Windows Ryzen 7 (10.6.186.50)
- **Qwen3.5 9B** — Reasoning, analysis, decision-making support (chat only)

### M4 Mac (10.6.186.161)
- **Qwen3.5 9B** — Marked as "Auditor" in config.yaml — checking markdown formatting, structural gaps, evaluating implementation plans
- **Qwen3.5 27B** — Marked as "Heavy Auditor" — complex multi-file reasoning, architectural gap checking

**Testing Summary**:
- Both models show capability for reading and understanding complex Rails/RSpec patterns
- Both can generate structural analysis of task files
- Can verify template conformance and suggest improvements
- Showing strong performance on local-only tasks (no execution needed)

---

## Audit Results: 2026-02 Task Rewriting

### Files Audited
Eight task files from `docs/new_agent/tasks/backlog/2026-02/` were selected for Qwen3.5 review and rewriting:

1. `2026-02-11-CRITICAL-MONITOR-FIX-MONITOR-LOADING.md` (169 lines)
2. `2026-02-11-HIGH-AI_MANAGER-SITE-SELECTION-ALGORITHM.md` (87 → expanded)
3. `2026-02-11-HIGH-BUGFIX-ESCALATION-WATER-ESCALATION-ISRU-CHAIN.md` (614 lines — heavily expanded)
4. `2026-02-11-HIGH-FEATURE-AI-MANAGER-ESCALATION-DEPENDENCIES.md` (67 lines)
5. `2026-02-11-HIGH-FEATURE-AI-MANAGER-RESOURCE-ALLOCATION-ENGINE.md` (147 lines)
6. `2026-02-11-HIGH-FEATURE-AI-MANAGER-SERVICE-INTEGRATION.md` (57 lines)
7. `2026-02-11-MEDIUM-TASK-AI-MANAGER-SERVICE-INTEGRATION.md` (97 lines)
8. `2026-02-15-HIGH-FEATURE-IMPLEMENT-SETTLEMENT-PATTERN-LOGIC.md` (159 lines)

### Conformance Check: TASK_TEMPLATE.md Alignment

| File | Template PASS | Frontmatter | Triage Report | Agent Assignment | Steps | Acceptance | Status |
|------|---|---|---|---|---|---|---|
| Monitor Loading | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | READY |
| Site Selection | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | READY |
| Water Escalation | ✅ | ✅ | ✅ | ✅ | ✅✅ | ✅ | EXPANDED |
| Escalation Deps | ✅ | ✅ | ✅ | ✅ | ⚠️ | ✅ | NEEDS WORK |
| Resource Allocation | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | READY |
| Service Integration | ✅ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | NEEDS WORK |
| Settlement Pattern | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | READY |

**Legend**: ✅ = Solid, ⚠️ = Needs Review, ❌ = Missing

---

## Quality Assessment

### Strengths

1. **Template Conformance**: All 8 files properly use frontmatter, status, priority, type fields
2. **Triage Reports**: Qwen3.5 added the "Local Worker Triage Report" section correctly:
   - Template Conformance: PASS
   - Docker Wrapper Check: PASS/FAIL evaluated correctly
   - MVP Alignment: Correctly assessed as VALID or STALE
   - Action Line: Proper routing (READY FOR CLOUD HANDOFF vs NEEDS REVIEW)
3. **Architectural Reasoning**: Added context from DECISIONS.md and GUARDRAILS.md appropriately
4. **Code Examples**: Generated realistic PORO pattern code for water escalation task
5. **Implementation Clarity**: Steps are sequential and specific (Step 1, 2, 3...)
6. **Agent Routing**: Correctly assigned to GPT-4.1 0x, Haiku 0.33x, or Claude 1x based on complexity

### Areas for Improvement

1. **Escalation Dependencies task**: Steps are listed but lack concrete code examples
   - Recommendation: Should include Rails service patterns for dependency resolution
   
2. **Service Integration (both files)**: Implementation steps are abstract, need more specificity
   - Recommendation: Should provide model signatures, DB queries, factory examples
   
3. **Code Quality Consistency**: Water Escalation has extensive PORO patterns, but others lack equivalent depth
   - Recommendation: Standardize code example depth across all implementation tasks

4. **Local Worker Notes**: Some files assume cloud agent execution when local-only context would be clearer
   - Recommendation: Add "Local Worker Notes" subsection flagging local-unsafe assumptions

---

## Workflow Implications

### What This Means

The Qwen3.5 models via Continue can effectively:
- ✅ Read existing task files and understand their structure
- ✅ Verify template conformance against TASK_TEMPLATE.md
- ✅ Identify stale/obsolete tasks vs. active ones
- ✅ Add code examples and implementation detail
- ✅ Route tasks to appropriate cloud agents
- ✅ Flag issues without being asked

The models CANNOT effectively:
- ❌ Execute commands to verify code works
- ❌ Run RSpec or see test output
- ❌ Query the database to verify schema
- ❌ Execute git commands
- ❌ Know which specs are currently failing

### Recommended Workflow Integration

```
┌─────────────────────────────────────────────────────────────┐
│ Gemini (Web) — Planning Gate                                │
│ - Triages session handoff                                   │
│ - Produces priority stack                                   │
│ - Routes to Continue for detail work                        │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Qwen3.5 9B or 27B (Continue) — Triage & Detailing           │
│ - Read old/stale task files from backlog                    │
│ - Check template conformance                                │
│ - Expand with code examples & implementation detail         │
│ - Verify MVP alignment                                      │
│ - Route to correct cloud agent (0x, 0.33x, or 1x)          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Cloud Agent (GPT-4.1 / Haiku / Claude) — Execution          │
│ - Read the detailedtask prepared by Qwen3.5                 │
│ - Run implementation or investigation                       │
│ - Produce completion report                                 │
│ - Commit to git (human verifies)                            │
└─────────────────────────────────────────────────────────────┘
```

---

## Recommended Next Steps

### 1. Formalize Qwen3.5 Triage Role
- Update `docs/new_agent/README.md` with "Qwen3.5 Triage Phase"
- Document expected output format from Continue agents
- Add "Local Worker Triage Report" to TASK_TEMPLATE.md as standard section

### 2. Address Quality Gaps in Existing Tasks
- Escalation Dependencies: Add concrete service patterns
- Service Integration (both files): Flesh out with factory examples, model signatures
- All files: Add "Local Worker Notes" subsection

### 3. Create Continue-Specific Guardrails
- Document what Continue CAN and CANNOT do
- Add safety rules for local model limitations
- Document fabrication prevention (never invent command output)

### 4. Test Qwen3.5 on More Tasks
- Run on 2026-03 backlog (newer tasks, potentially fewer issues)
- Run on 2026-04 backlog (recent architectural decisions)
- Collect metrics on template conformance improvements

### 5. Update Agent Routing for Continue Phase
- Move Qwen3.5 task detail work BEFORE cloud agent handoff
- Update AGENT_ROUTING.md to show new flow:
  - Gemini → Plan
  - Qwen3.5 → Triage/Detail
  - Cloud Agent → Execute
  - Human → Commit/Verify

---

## Risk Assessment

**Low Risk**:
- Template verification (purely structural, local models good at this)
- MVP alignment audits (models can read DECISIONS.md and reason about applicability)
- Code example generation (models trained on Rails patterns)

**Medium Risk**:
- Architectural correctness of PORO code examples
  - Mitigation: Have cloud agent verify before implementation
- Routing decisions (which agent should execute)
  - Mitigation: Human reviews Qwen3.5 routing suggestions

**High Risk**:
- Fabricated test output or command results
  - Mitigation: MANDATORY rule in GUARDRAILS.md — never invent output
- Overconfidence in local model analysis without human review
  - Mitigation: Flag all local model work as "draft" until human approves

---

## Recommendations for new_agent Documentation

### Files to Update
1. **README.md** — Add "Continue Integration" section
2. **AGENT_ROUTING.md** — Add Qwen3.5 models to routing table
3. **GUARDRAILS.md** — Add "Local Model Output Rules" section
4. **TASK_TEMPLATE.md** — Add "Local Worker Triage Report" section
5. **agent_guides/** — Create or update `qwen3_5_auditor.md` with role documentation

### Key Messages
- Qwen3.5 is a **triage and detail agent**, not a primary executor
- All local model output should be reviewed by human or cloud agent before commitment
- Continue workflow reduces burden on cloud agents significantly
- This enables Gemini as planning gate + Continue as detail gate + Cloud agents as execution

---

## Conclusion

The Qwen3.5 models via Continue show **strong promise** for:
- Improving task file quality through consistent template enforcement
- Adding implementation detail without cloud agent cost
- Triaging stale vs. active work
- Preparing tasks for cloud agent handoff

**Recommendation**: Formalize the Continue workflow in new_agent documentation and expand Qwen3.5 triage work to cover 2026-03, 2026-04, and 2026-05 backlogs.

