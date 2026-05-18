# 2026-04-13-MEDIUM-FEATURE-SCOUTING RECOVERY INTEGRATION

**Agent:** GPT-4.1 (0.25x)
**Priority:** MEDIUM
**Type:** FEATURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# TASK: Integrate Recovery Logic into WormholeScoutingService

## 1. Objective
Refactor `WormholeScoutingService` to support the physical delivery of Handshake Tokens.

---

## Original Content

# TASK: Integrate Recovery Logic into WormholeScoutingService

## 1. Objective
Refactor `WormholeScoutingService` to support the physical delivery of Handshake Tokens.

## 2. Requirements
- [ ] **Scan Mode:** Add `:seismic_survey` to `ScoutShip` capabilities.
- [ ] **Data Payload:** Implement a `carry_vault` attribute for Scouts to hold the `HandshakeToken`.
- [ ] **Mission Success Condition:** For recovery missions, the mission is only "Successful" when the Scout returns to a Sol-side WTC with the Token intact.

## 3. Success Criteria
- The AI Manager can distinguish between a "Resource Scout" and a "Structural Verification Scout."
- Scouts successfully transport the physical coordinates of the Eden AWS back to Sol.
