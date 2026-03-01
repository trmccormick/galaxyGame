# Validate Layer Data Filtering for Monitor View

**Date:** 2026-02-28
**Priority:** HIGH
**Agent Role:** Implementation

## Context
Backend/frontend integration

## Issue
Layer data may be sent/rendered unnecessarily

## Root Cause
Old logic did not conditionally filter layers

## Tasks
- Ensure backend only sends relevant layers per world
- Update frontend to check for layer presence before rendering
- Add tests for layer filtering logic

## References
- [README.md](../../README.md)
- [monitor.js](../../../monitor.js)
- [surface_view_optimized.js](../../../surface_view_optimized.js)
