# Phase 3 Backlog Alignment Review

**Created**: 2026-07-16  
**Purpose**: Check if backlog tasks align with Luna-first MVP roadmap per canonical intent statements.  
**Canonical Intent Reference**: #9 (multiple interconnected gameplay loops), #12 (narrative progression ≠ implementation progression)

---

## Luna-First MVP Roadmap (per Phase 2 analysis)

The intended development sequence is:
1. Earth → Luna MVP
2. NPC autonomous expansion
3. Economic validation
4. Luna infrastructure
5. Orbital depots
6. Shipyards
7. Mars → Venus → Cycler logistics
8. AI validation
9. Natural wormhole → Eden → Snap
10. Player-era interstellar

---

## Backlog Alignment Analysis

### A. Tasks That ALIGN with Luna-First MVP

| Task | Current Priority | Alignment | Notes |
|------|-----------------|-----------|-------|
| Resolve Habitat.rb active version | P0 (Phase 2) | ✅ ALIGNED | Foundation model needed for Phase 1 habitation |
| Implement Cryosphere simulation service | P1 (Phase 2) | ⚠️ RECLASSIFY | Should be P3+ — not needed for Luna MVP. Ice giant simulation is late-game content. |
| Complete terraforming simulation pipeline | P1 (Phase 2) | ✅ ALIGNED | Core gameplay pillar, needed for planetary modification |
| Implement Civ4 shoreline regression filter | P1 (Phase 2) | ✅ ALIGNED | Critical terrain quality issue, blocks accurate biome rendering |
| Complete player contract system (all 4 types) | P1 (Phase 2) | ✅ ALIGNED | Core economy loop, needed for NPC autonomous expansion |
| Verify market stabilization integration | P1 (Phase 2) | ✅ ALIGNED | Needed for economic validation phase |
| Implement player-first contract priority enforcement | P1 (Phase 2) | ✅ ALIGNED | Core gameplay pillar — player agency |
| Complete construction job progress tracking | P1 (Phase 2) | ✅ ALIGNED | Phase 1 construction system |
| Update AI Manager architecture documentation | P1 (Phase 2) | ⚠️ RECLASSIFY | Should be P2 — important but not blocking MVP. Per canonical intent #8, AI Manager growth is expected. |
| Clean up legacy model files (.old, .new, .bak) | P1 (Phase 2) | ✅ ALIGNED | Code hygiene, low risk |
| Consolidate blueprint schema versions | P2 (Phase 2) | ✅ ALIGNED | Template housekeeping per canonical intent #6 |
| Resolve cycler model location mismatch | P2 (Phase 2) | ⚠️ RECLASSIFY | Should be P3 — cycler logistics is Phase 7 in MVP sequence |
| Implement exchange rate phase progression logic | P2 (Phase 2) | ✅ ALIGNED | Economic validation requires this |
| Verify seed file deduplication | P2 (Phase 2) | ✅ ALIGNED | Database hygiene, low risk |

### B. Tasks That MISALIGN with Luna-First MVP

| Task | Current Priority | Problem | Recommended Priority | Reason |
|------|-----------------|---------|---------------------|--------|
| Brown dwarf hub manager verification | P2 (Phase 2) | Phase 3+ content, not needed for Luna MVP | **P4** | Brown dwarfs are interstellar content, far beyond Luna scope |
| Digital Twin sandbox integration | P3 (Phase 2) | Admin feature, not core gameplay | **P4** | Not player-facing, not blocking any MVP phase |
| Precursor mission system (full implementation) | P3 (Phase 2) | Scope unclear, multiple docs with different scopes | **P2** | Actually needed for Phase 1 — precursor missions bootstrap lunar settlement |
| Multi-wormhole event system | P3 (Phase 2) | Phase 4+ content | **P5** | Interstellar content, far beyond MVP |
| EM power shield tier system | P3 (Phase 2) | Physics mechanic, implementation unclear | **P4** | Interesting but not required for core gameplay |
| Sub-brown dwarf support | Not in backlog | Model exists but purpose unclear | **P5** | Niche celestial body type, late-game content |
| Hycean planet system | Not in backlog | Water-world subtype | **P4** | TerraSim expansion, not Luna MVP |
| Sci-fi easter eggs | Not in backlog | Flavor content | **P5** | Non-critical content |

### C. Missing Tasks (Should Be Added to Backlog)

Based on canonical intent and code evidence, these tasks should exist but don't:

| Task | Recommended Priority | Reason |
|------|---------------------|--------|
| Verify Colony → Settlement validation in code | P1 | Canonical intent #1 defines this hierarchy; code implements it but no task verifies it works correctly |
| Document AI Manager service dependency map | P2 | 80+ services need integration documentation (canonical intent #8) |
| Add settlement architecture wiki page | P2 | Per canonical intents #1-3, Colony/Settlement/Structure hierarchy needs clear documentation |
| Verify TerraSim regression engine gap | P1 | Phase 2 identified this as HIGH impact; no explicit backlog task to implement it |
| Create template version consolidation plan | P2 | Canonical intent #6 says version drift is housekeeping; needs a concrete plan |
| Implement biosphere scoring system | P2 | Phase 2 listed this as P2 but it's not in the current backlog |

---

## Recommended Backlog Reclassification

### Keep as P0/P1 (Luna MVP Blockers)
- Resolve Habitat.rb active version
- Complete terraforming simulation pipeline
- Implement Civ4 shoreline regression filter
- Complete player contract system (all 4 types)
- Verify market stabilization integration
- Implement player-first contract priority enforcement
- Complete construction job progress tracking

### Demote to P2/P3 (Important but Not Blocking)
- Update AI Manager architecture documentation → **P2** (canonical intent #8)
- Consolidate blueprint schema versions → **P2** (canonical intent #6)
- Clean up legacy model files → **P2** (code hygiene)
- Verify seed file deduplication → **P3** (database hygiene)
- Resolve cycler model location mismatch → **P3** (Phase 7 MVP content)

### Demote to P4/P5 (Late Game / Nice-to-Have)
- Brown dwarf hub manager → **P4**
- Digital Twin sandbox → **P4**
- EM power shield tier system → **P4**
- Multi-wormhole event system → **P5**
- Sub-brown dwarf support → **P5**
- Sci-fi easter eggs → **P5**

### Promote to Higher Priority
- Precursor mission system (full implementation) → **P2** (needed for Phase 1 bootstrap)
- Biosphere scoring system → **P2** (TerraSim validation)

---

## Summary

| Category | Count | Action |
|----------|-------|--------|
| ALIGNED with MVP | 13 | Keep current priority |
| MISALIGN — Demote | 6 | Lower priority to match MVP sequence |
| MISALIGN — Promote | 2 | Raise priority to match MVP needs |
| MISSING from backlog | 6 | Add to backlog |

**Key Finding**: The Phase 2 backlog is mostly aligned with Luna-first MVP but has 6 items that are over-prioritized (late-game content at P2-P3) and 6 tasks that should exist but don't. The most impactful change is demoting brown dwarf/wormhole/interstellar content from P2-P3 to P4-P5, since those are Phase 7+ MVP items.
