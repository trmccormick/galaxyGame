# 2026-04-02-HIGH-ARCHITECTURE-LOGISTICS PROVIDER CAPABILITIES SERIALIZATION FIX

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Logistics Provider Capabilities Serialization Fix

## Context
The `Logistics::Provider#capabilities` field is sometimes stored as an array, sometimes as a JSON string, and sometimes as a plain strin...

---

## Original Content

# Logistics Provider Capabilities Serialization Fix

## Context
The `Logistics::Provider#capabilities` field is sometimes stored as an array, sometimes as a JSON string, and sometimes as a plain string. This causes serialization/deserialization issues in `find_provider` and related logic.

## Problem
- `find_provider` must robustly handle all three cases (array, JSON string, plain string)
- Current implementation is brittle and can fail if the format is not as expected

## Required Fix
- Refactor `find_provider` and any code that reads/writes `capabilities` to always handle all three formats
- Add tests to ensure all cases are covered

## Priority
- Medium (not blocking, but can cause subtle bugs)

## Reference
- See docs/architecture/LOGISTICS_PROVIDER_INTENT.md for provider/capabilities intent
- See contract_service_provider_fix.md for context

