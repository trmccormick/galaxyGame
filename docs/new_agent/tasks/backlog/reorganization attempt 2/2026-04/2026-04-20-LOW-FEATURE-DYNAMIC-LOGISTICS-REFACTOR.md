# 2026-04-20-LOW-FEATURE-DYNAMIC LOGISTICS REFACTOR

**Agent:** GPT-4.1 (0.25x)
**Priority:** LOW
**Type:** FEATURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# TASK: Refactor StationConstructionStrategy for Physics-Based Logistics

## 1. Objective
Refactor `app/services/ai_manager/station_construction_strategy.rb` and `station_cost_benefit_analyzer.rb` to ...

---

## Original Content

# TASK: Refactor StationConstructionStrategy for Physics-Based Logistics

## 1. Objective
Refactor `app/services/ai_manager/station_construction_strategy.rb` and `station_cost_benefit_analyzer.rb` to align with the `asteroid_conversion_physics.md` spec.

## 2. Implementation Requirements

### 2.1 Schema & Model Updates
- [ ] Add `composition` (enum), `density` (float), and `is_hollow` (boolean) to the `Asteroid` model.
- [ ] Implement `structural_integrity` logic based on composition and density.

### 2.2 Logic Refactor
- [ ] **Qualification Service:** Create a service to filter asteroids. Reject "Rubble Piles" and "Unshielded Icy" bodies from the strategy selection.
- [ ] **Dynamic Implementation Plan:**
    - Replace `total_duration: 9.months` with a calculated `towing_duration` using distance and mass.
    - Inject an `Internal Bracing` step if `is_hollow: true`.
- [ ] **Strategy Weighting:**
    - Force-select `:asteroid_conversion` if system status is `orphaned`.
    - Increase `capability_score` (+20) for braced hollow asteroids (easier internal component housing).

## 3. Success Criteria
- The AI Manager correctly rejects "cheap" but unviable rubble piles in favor of "expensive" but solid metallic rocks.
- The construction timeline shifts dynamically based on Tug count and asteroid mass.
