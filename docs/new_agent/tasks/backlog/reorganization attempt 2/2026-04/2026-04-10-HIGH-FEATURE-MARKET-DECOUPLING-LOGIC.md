# 2026-04-10-HIGH-FEATURE-MARKET DECOUPLING LOGIC

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** FEATURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# TASK: Implement Market Decoupling for Orphaned Systems

## 1. Objective
Modify the `Market::PriceCalculator` to detect `orphaned` system status and shift to a localized supply/demand curve.

---

## Original Content

# TASK: Implement Market Decoupling for Orphaned Systems

## 1. Objective
Modify the `Market::PriceCalculator` to detect `orphaned` system status and shift to a localized supply/demand curve.

## 2. Requirements
- [ ] **Decoupling Hook:** Add a check to `MarketService`. If `system.connected? == false`, bypass the GCC global price feed.
- [ ] **Scarcity Multiplier:** Implement a multiplier for "High-Tech" tags when local stock is < 10% of the AWS construction requirement.
- [ ] **Inventory Locking:** Create a `reserved_for_construction` flag on `StationMaterial` records to prevent the AI from selling off AWS Anchor components to players.

## 3. Success Criteria
- Prices in Eden fluctuate independently of Sol until the Handshake Token is consumed.
- The AI Manager prioritizes building local forges over waiting for trade that cannot arrive.
