# Migrate Surface & Monitor Views to JSON Tileset System

**Date:** 2026-02-28
**Priority:** HIGH
**Agent Role:** Implementation

## Context
Map rendering, frontend

## Issue
Legacy FreeCiv/Civ4 tilespec parsing is deprecated

## Root Cause
Performance, maintainability, and extensibility issues with legacy asset pipeline

## Tasks
- Replace all tilespec parsing logic with JSON-based loader (`simple_tileset_loader.js`)
- Update surface and monitor views to use new rendering logic (`surface_view_optimized.js`)
- Remove legacy asset references and document migration

## References
- [README.md](../../README.md)
- [galaxy_game_tileset.json](../../../galaxy_game_tileset.json)
- [simple_tileset_loader.js](../../../simple_tileset_loader.js)
- [surface_view_optimized.js](../../../surface_view_optimized.js)
