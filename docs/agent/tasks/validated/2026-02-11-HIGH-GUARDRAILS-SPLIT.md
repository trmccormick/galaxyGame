# Guardrails Split (0x Task)

**Target**: docs/agent/GUARDRAILS.md

**Issue**: Monolithic guardrails documentation needs to be split into modular, actionable sections for maintainability and clarity.

**Diagnostic**:
```bash
ls docs/agent/ | grep -i 'guardrails'
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Propose modular split (sections: input, output, error, escalation, etc.)
3. Implement split into separate files
4. Commit: "docs: split guardrails into modular sections"

Priority: HIGH | 45min
