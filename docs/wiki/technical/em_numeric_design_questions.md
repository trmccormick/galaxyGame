# EM Numeric Design Questions

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Updated:* 2026-11-11  
> *Audit Summary:* Design intent specification (page status OPEN). Collects numeric design questions from related pages; no values invented.

**Status**: OPEN  
**Last Updated**: 2026-11-11  
**Related**: [Natural wormholes & EM](natural_wormholes_and_em.md), [Portals & AWS](portals_and_aws.md)

---

## Scope Note

**EM on this page = Exotic Matter**, not electromagnetic. This page collects the **numeric** design questions that are currently scattered as long open lists across:

- [Natural wormholes & EM](natural_wormholes_and_em.md)
- [Portals & AWS](portals_and_aws.md)

Non-numeric design (physics, lore, institutional context) stays on those pages. Only questions that require a number, unit, or formula are listed here. **No values are invented on this page.** Every item is tagged with its source page.

---

## 1. EM Yield Curves / Units

| # | Question | Source |
|---|----------|--------|
| 1.1 | What units is EM measured in? (e.g., mass-equivalent, energy-equivalent, abstract "units") | natural_wormholes_and_em.md |
| 1.2 | What is the EM yield curve: how does EM release rate change as a function of aperture instability / degradation state? | natural_wormholes_and_em.md |
| 1.3 | Does a stable wormhole produce any baseline EM, or only during ejection events? | natural_wormholes_and_em.md |
| 1.4 | How much total EM does a controlled Snap release? | natural_wormholes_and_em.md |

---

## 2. Stockpile and Saturation Limit

| # | Question | Source |
|---|----------|--------|
| 2.1 | What is the total stockpile cap (how much EM can exist in circulation at once)? | natural_wormholes_and_em.md |
| 2.2 | What is the Saturation Limit per station? | natural_wormholes_and_em.md |
| 2.3 | What is the Saturation Limit per satellite? | natural_wormholes_and_em.md |
| 2.4 | How does the stockpile refill from harvest windows? Is it rate-limited or event-driven? | natural_wormholes_and_em.md |

---

## 3. Portal Ignition Cost and Residual Rate

| # | Question | Source |
|---|----------|--------|
| 3.1 | How much EM does a portal consume as an **ignition burst** to open the aperture? | portals_and_aws.md |
| 3.2 | How much EM is consumed for **stabilization and mass-limit reset** per opening? | portals_and_aws.md |
| 3.3 | Is there any **residual EM rate while the portal is held open**? (Intent: minimal — fusion power handles day-to-day upkeep.) | portals_and_aws.md |
| 3.4 | What happens to an in-transit payload or link state if the EM supply is cut mid-open? | portals_and_aws.md |

---

## 4. AWS Draw

| # | Question | Source |
|---|----------|--------|
| 4.1 | How does an AWS draw EM: per opening, per hour held open, per mass transited, or a mix of these? | natural_wormholes_and_em.md, portals_and_aws.md |
| 4.2 | What is the EM cost to **establish** a new inter-system AWS pair (one-time)? | portals_and_aws.md |
| 4.3 | What is the ongoing EM draw for an active AWS pair? | portals_and_aws.md |

---

## 5. Controlled-Snap / Harvest-Window Yields

| # | Question | Source |
|---|----------|--------|
| 5.1 | How much EM does a **degrading aperture** eject per time unit as instability increases? | natural_wormholes_and_em.md |
| 5.2 | What is the total EM yield of a **controlled Snap** event? | natural_wormholes_and_em.md |
| 5.3 | What is the duration of the harvest window before a Snap (how long can players harvest before closure)? | natural_wormholes_and_em.md |
| 5.4 | Is there a maximum EM yield cap per wormhole mouth, or does it scale indefinitely with degradation? | natural_wormholes_and_em.md |

---

## 6. Other Numeric EM Questions

| # | Question | Source |
|---|----------|--------|
| 6.1 | What are the **mass-threshold units** and time windows for a natural wormhole mouth? | natural_wormholes_and_em.md |
| 6.2 | What is the **triggering mass** required for a controlled Snap, and how does it relate to the mass threshold? | natural_wormholes_and_em.md |
| 6.3 | What are the **stabilization-satellite feed-back rates** (EM per unit time fed back into the throat)? | natural_wormholes_and_em.md |
|6.4 | How many portal pairs can a settlement or hub host? (No hard cap is set.) | portals_and_aws.md |
| 6.5 | What are the **Mark capacity tiers** and numeric mass filters for portal payloads? | portals_and_aws.md |
| 6.6 | What is the **fusion power draw by variant** (habitat-rated, industrial, vacuum-rated)? | portals_and_aws.md |
| 6.7 | How much EM does a **containment loss / surge hazard** consume or waste? | natural_wormholes_and_em.md |

---

## Summary of Missing Numeric Categories

| Category | Count of Open Questions | Priority |
|----------|------------------------|----------|
| EM Yield curves / units | 4 | High — needed for AI Manager harvest-site ranking |
| Stockpile & Saturation Limit | 4 | High — needed for all consumers to function |
| Portal ignition & residual cost | 4 | High — main portal number to design |
| AWS draw mechanics | 3 | High — inter-system logistics backbone |
| Controlled-Snap / harvest yields | 4 | Medium — event-driven, not continuous |
| Other numeric gaps | 7 | Medium — fills remaining implementation gaps |

**Total: 26 open numeric questions.** All values remain **OPEN**. No numbers are invented or proposed on this page.

---

## Migration Log

| Date | Action | Details |
|------|--------|---------|
| 2026-11-11 | Created | Harvested numeric OPEN questions from `natural_wormholes_and_em.md` and `portals_and_aws.md`; no values invented. |
