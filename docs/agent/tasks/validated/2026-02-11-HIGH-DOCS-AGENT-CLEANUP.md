# Docs Agent Cleanup (0x Task)

**Target**: docs/agent/

**Issue**: Legacy documentation files, outdated agent instructions, and duplicate/obsolete content present in docs/agent/.

**Diagnostic**:
```bash
ls docs/agent/ | grep -i 'old\|backup\|obsolete\|duplicate'
```

**Tasks**:
1. Synthesis Report (current state analysis) → STOP
2. Identify and list all legacy/obsolete files
3. Remove or archive non-essential files
4. Commit: "chore: cleanup legacy agent docs and obsolete files"

Priority: HIGH | 30min
