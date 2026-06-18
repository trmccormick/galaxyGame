# Galaxy Game Planning Goals

## Purpose

This document defines the current planning direction for Galaxy Game. It exists to keep task triage, simulation tuning, and wiki planning aligned with the actual project goals.

## Current Focus

The current focus is Luna.

Luna is the foundation of the player experience, the first meaningful settlement loop, and the place where the AI Manager must prove it can create a living simulation rather than a blank universe.

## Project Direction

Galaxy Game is being built as a living universe with active markets, visible settlement growth, and meaningful player activity.

The goal is not to rush expansion features. The goal is to make the current simulation stable, believable, and testable so later systems can build on a sound foundation.

## Why the Buildout Is Slow

The buildout is intentionally slow so we can:
- test the simulation thoroughly,
- tune AI Manager decisions,
- keep the market and activity loop alive,
- and catch issues before expansion creates more surface area.

This is why the current phase emphasizes refactor, cleanup, and simulation tuning instead of broad feature growth.

## Planning Principles

1. Luna comes first.
2. Features should be aligned to when they are needed.
3. Stable simulation matters more than rapid expansion.
4. RSpec reliability is a strength, not a reason to widen scope.
5. Refactor should remove noise and reduce drift.
6. Future systems should only be planned in detail when they become dependencies.

## Current Technical Reality

The codebase is already in a strong state:
- nearly 4,000 RSpec tests are passing,
- only a small number of tests are flaky,
- and the remaining work is focused on Luna simulation quality and AI Manager behavior.

That means planning should prioritize correctness, clarity, and maintainability rather than speculative expansion.

## Near-Term Objectives

- Stabilize Luna simulation behavior.
- Improve AI Manager decision quality.
- Keep market activity and settlement activity visible.
- Reduce any remaining flaky behavior.
- Align task files with the correct phase and dependency timing.

## Out of Scope For Now

The following are not the current planning focus unless they directly support Luna:
- broad expansion systems,
- late-game station design,
- cycler and tug buildout,
- wormhole or multi-system work,
- cosmetic or lore-only elaboration without simulation value.

## Review Rule

If a planned feature does not help Luna function as a living simulation now, it should wait.

If it directly supports the Luna foundation, it belongs in active planning.