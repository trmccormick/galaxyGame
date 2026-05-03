# TASK: Surgical Guardrails Audit & Migration
**Status**: READY (For Wednesday)  
**Priority**: 🔥 CRITICAL  
**Type**: Architecture — Documentation  
**Created**: 2026-03-23  

---

## Agent Assignment
**Assigned To**: Claude-3-Sonnet-1x  
**Reason**: High-reasoning required to extract 681 lines of mixed logic into specialized docs without losing "Market vs. Build" or "Wormhole Law" nuances.

---

## Instructions
1. **Analyze `GUARDRAILS.md`**: Locate the "Wormhole Anchor Law" and "Economic Overheads."
2. **Verify against Glossary**: Ensure the 0.5% SCC, 0.3% Broker, and 3.37% Sales Tax match the updated `GLOSSARY_SYSTEM_MECHANICS.md`.
3. **Execute Split**: Move Game Design logic to `docs/architecture/` and Mission logic to `docs/mission_profiles/`.
4. **Clean Root**: Leave only Agent Operating Rules (Git, Docker, Atomic Commits) in `GUARDRAILS.md`.

---

## Acceptance Criteria
- [ ] `GUARDRAILS.md` is < 150 lines and contains strictly technical agent protocols.
- [ ] No game design logic remains in the root Guardrails.