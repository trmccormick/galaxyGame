# ImportOrder & Cycler Transport Models

> **Wiki section:** Logistics · **Status:** target design intent — canonical architecture spec for transport models, cycler routing, and infrastructure mechanics; no runtime enforcement currently exists.

> **Cross-link:** For EAP pricing ceilings, AI Manager escalation ladders, and economic engine integration, see **[Earth Anchor Price & AI Manager Escalation](./eap_and_ai_manager_escalation.md)**.

> **Cross-link:** For how terraforming demand is financed through GCC budgets, Seed vs. Brute-Force contracts, and player earning multipliers, see **[Terraforming Economic Integration](./terraforming_economic_integration.md)**.

---

## Scope

This document defines the transport infrastructure models underlying all logistics in Galaxy Game: the **three-tier transport hierarchy**, the future Phase 3 data models for cycler routing and rendezvous mechanics, the L1 Depot's role as the Venus-Titan-Luna logistics triangle hub, and the Precursor supply tether that governs early-game Earth dependency.

**Authority:** This document promulgates requirements from `docs/architecture/logistics/logistics_architecture.md` and `docs/architecture/logistics/l1_depot_processing_intent.md`.

---

## 1. Three-Tier Transport Model

All resource movement in the game flows through three distinct transport tiers. Each tier has specific scope, operators, cargo profiles, and key mechanics.

### Tier 1 — Local / Small Craft

| Property | Value |
|----------|-------|
| **Scope** | Sub-planetary, cis-lunar, same-world base-to-base, orbital transfers |
| **Examples** | Earth ↔ Luna, Luna ↔ L1 station, base ↔ base on same world |
| **Operators** | Players (primary), AstroLift feeder runs (NPC) |
| **Cargo** | Small, frequent, player-scale |
| **Key mechanic** | Can rendezvous with cyclers at meetup points to transfer cargo or dock and ride along |

### Tier 2 — Cycler Rendezvous

| Property | Value |
|----------|-------|
| **Scope** | Handoff point between local craft and the interplanetary cycler network |
| **What it is** | A time-windowed meetup point in space where small craft intercept a passing cycler |
| **Window** | Opens and closes on a schedule — miss it, wait for next pass |

**Player options at rendezvous:**

| Action | Outcome |
|--------|---------|
| Fly own craft to meetup point | Transfer cargo to cycler manually |
| Dock own craft to cycler | Ride along to destination |
| Book cargo space on cycler (no flight) | AstroLift handles transfer |
| Sell cargo to AstroLift at origin | Immediate GCC, AstroLift takes the margin |
| Hire another player | Player proxies the meetup |

**Key mechanic:** Timing skill and route knowledge create player skill expression. A player who consistently hits meetup windows operates a more profitable logistics business than one who always books AstroLift directly.

### Tier 3 — Cycler Network (Interplanetary)

| Property | Value |
|----------|-------|
| **Scope** | Major world to major world only. Does not stop at moons, L-points, or stations. |
| **Examples** | Inner system: Earth → Mars → Venus; Outer system: Mars → Titan; Cross-system: wormhole network routes |
| **Operator** | AstroLift (owns and operates all cyclers) |
| **Cargo** | High volume, scheduled, manifest-driven |
| **Key mechanic** | AI Manager adjusts manifests per world needs. Players book cargo space or transfer at rendezvous points. |

---

## 2. CyclerRoute Model (Future — Phase 3)

Not implemented for Luna-first. Captured here for design continuity.

```ruby
CyclerRoute
  id                     # primary key
  name                   # 'Inner System Loop', 'Outer System Express'
  operator_id            # AstroLift corporation by default
  stops                  # ordered list of world nodes (JSON/array)
  schedule_days          # cycle time in days — when route repeats
  cargo_capacity_kg      # total payload capacity per departure
  active                 # boolean — routes activate as worlds open or cycler availability allows
```

**Routing rules:**
- Routes are flexible — AI Manager proposes new routes as new worlds open.
- Wormhole network expansion adds new cross-system route possibilities.
- `active` gates prevent routes from appearing in the market before their prerequisite worlds or infrastructure exist.
- Players can eventually own and operate competing cycler routes (designated future capability).

---

## 3. CyclerRendezvous Model (Future — Phase 3)

Not implemented for Luna-first. Captured here for design continuity.

```ruby
CyclerRendezvous
  id                     # primary key
  cycler_route_id        # references the CyclerRoute this rendezvous belongs to
  meetup_location        # orbital coordinates or L-point reference (string/JSON)
  window_opens_at        # datetime — before this, rendezvous is not accessible
  window_closes_at       # datetime — after this, rendezvous closes until next cycle
  cargo_capacity_remaining # integer — space remaining on the cycler for new bookings
```

**Rendezvous rules:**
- Small craft dock or transfer cargo only within the open window.
- `cargo_capacity_remaining` decreases as bookings are made; when it reaches zero, no more cargo can be added to that departure.
- Missing a rendezvous window requires waiting for the next cycle (determined by `CyclerRoute.schedule_days`).

---

## 4. L1 Depot: Venus-Titan-Luna Logistics Triangle Hub

### Core Identity

The **L1 Depot** is a **Hybrid Structure**: a high-volume storage depot combined with a heavy-duty atmospheric refinery. It serves as the primary node for the Venus-Titan-Luna logistics triangle.

### Feedstock Loop

| Input | Process | Output |
|-------|---------|--------|
| Venusian CO₂ | Sabatier/Electrolysis conversion | LOX (Liquid Oxygen) |
| Titan CH₄ | Cryogenic storage | Primary fuel half of methalox mix |

### Skimmer Docking Priority & Redundancy

| Priority | Docking Location | Condition |
|----------|-----------------|-----------|
| **Primary** | L1 Depot | Normal operations; immediate gas transfer and automated refueling |
| **Secondary (contingency)** | Luna Settlement | L1 at capacity or offline |

### The "Efficiency Gap"

Luna processing capacity is **significantly lower** than L1. Landing at Luna as a contingency results in:
- Slower turnaround times for skimmer crews
- Higher fuel overhead per delivery
- Reduced throughput on the Venus-Titan-Lana logistics triangle

### Resource Distribution

| Direction | Mechanism | Notes |
|-----------|-----------|-------|
| Refined surplus → Luna Settlement | Downward transfer of excess O₂, N₂, noble gases | Held for Earth-bound resupply missions |
| Construction materials from Luna | Bulk structures (I-Beams, Panels) sourced from Luna | High-complexity Avionics/Electronics remain Tier 3 Earth imports |

---

## 5. Precursor Supply Tether Mechanics (Earth-to-Luna)

### The Earth-Launch Constraint

During the **Precursor Mission** and early Phase 1 (Work Camp), the settlement is **100% dependent on Earth-side manufacturing** for high-complexity components.

### Component Tier Hierarchy

| Tier | Source | Examples | Logic |
|------|--------|----------|-------|
| **Tier 1** | Local (ISRU) | Regolith, O₂, H₂O, I-Beams | Produced by `BaseRig` using Rake tasks |
| **Tier 2** | Regional (Sol) | Refined Alloys, Glass | Future orbital trade via L1/Depot |
| **Tier 3** | Earth (Launch) | `ruggedized_electronics`, `high_strength_actuators` | Hard-coded import requirement |

### Economic Multipliers

| Parameter | Value | Detail |
|-----------|-------|--------|
| Transport cost multiplier | 5.0× Earth baseline | As defined in `lunar-precursor-ai_profile_v1.json` |
| Settlement currency | USD (not GCC) | All Earth-sourced parts transactions use USD |

### Maintenance Manifest Requirement

Every `CAR-300` deployment must include a **Maintenance Crate** containing:
- **Minimum:** 250 kg of Tier 3 spares
- **Purpose:** Survive the transition to Phase 2 before local ISRU can produce replacements

### Strategic Goal: Tether Severance

The AI Manager's primary objective is to **decrease the "USD Import Ratio"** by transitioning as many Tier 2/3 requirements to local Tier 1 production before the initial Earth-funded maintenance crate is exhausted. Complete severance means zero USD imports — full self-sufficiency via ISRU and in-system trade.

---

## 6. Integration with EAP and Escalation Ladder

| Model | Depends on EAP? | Uses Escalation Ladder? |
|-------|-----------------|------------------------|
| ImportOrder | Yes — `eap_at_order_time` field captures the ceiling at order creation | Yes — ImportOrders are Step 6 of the escalation ladder |
| CyclerRoute | Indirectly — EAP sets the price floor AstroLift can sell at on any route | No — routes are infrastructure, not a procurement strategy |
| L1 Depot processing | Yes — skimmer delivery decisions factor in EAP vs. Luna processing costs | No — refinery operations are production, not acquisition |
| Precursor tether | N/A (USD-denominated) | Indirectly — the tether *is* an import dependency; severance eliminates it via earlier ladder steps |

---

*Last verified against: `docs/architecture/logistics/logistics_architecture.md`, `docs/architecture/logistics/l1_depot_processing_intent.md` — canonical architecture spec. No runtime enforcement currently exists.*
