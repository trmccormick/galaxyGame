# 2026-04-13-MEDIUM-FEATURE-COURIER HANDSHAKE INTEGRATION

**Agent:** GPT-4.1 (0.25x)
**Priority:** MEDIUM
**Type:** FEATURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# TASK: Implement AWS Handshake & Injection Logic

## 1. Objective
Refactor the `Wormhole` creation process to require a `HandshakeToken` for non-natural (Artificial) wormholes.

---

## Original Content

# TASK: Implement AWS Handshake & Injection Logic

## 1. Objective
Refactor the `Wormhole` creation process to require a `HandshakeToken` for non-natural (Artificial) wormholes.

## 2. Requirements
- [ ] **Item Class:** Create `Items::HandshakeToken < Items::PhysicalDataVault`.
- [ ] **Validation Hook:** Add a `before_create` validation to `Wormhole`. 
    - If `type == :artificial`, verify a valid `HandshakeToken` is present at the originating `SpatialLocation`.
- [ ] **Coordinate Override:** Update `Wormhole#generate_endpoints` to extract the `target_coords` from the token's metadata instead of using `rand`.
- [ ] **Consumption Logic:** Once the wormhole is successfully opened, the `HandshakeToken` is marked as `consumed` or `archived`.

## 3. Success Criteria
- An AWS cannot be "fired" blindly; it requires a player (or AI scout) to have successfully traveled from the target system with the data vault.
- The resulting wormhole exits exactly at the coordinates of the converted Asteroid Anchor.
