# 2026-04-02-HIGH-ARCHITECTURE-REFACTOR WORMHOLE GENERATION JOB FOR STARSIM RULES

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Refactor wormhole_generation_job.rb to use StarSim Generation Rules

## Task

Refactor `wormhole_generation_job.rb` so that it pulls all procedural constraints from `docs/architecture/STARSIM_GENERA...

---

## Original Content

# Refactor wormhole_generation_job.rb to use StarSim Generation Rules

## Task

Refactor `wormhole_generation_job.rb` so that it pulls all procedural constraints from `docs/architecture/STARSIM_GENERATION_RULES.md` instead of using pure random() logic.

- Enforce Anchor Priority: Prefer Saturn-mass ($> 95\ M_{\oplus}$) planets for endpoints.
- Enforce the 5 AU Buffer: Do not generate natural wormholes within the habitable zone of G-type stars.
- Enforce Connectivity Cap: Respect `MAX_WORMHOLES_PER_SYSTEM` to prevent hub congestion.

---

**Priority:** High (network stability, realism)
**Owner:** StarSim/Procedural Generation
**Status:** Backlog

