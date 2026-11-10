> **Wiki section:** UI & Experience · **Status:** design intent — evolving with reviewed prototype views

# UI & Experience

This section records the intended user experience and visual design of Galaxy Game's interface. It is part of the main `galaxyGame` repository because the interface is a product feature of Galaxy Game, even when a separate repository is used to prototype its implementation.

The wiki is the design authority. The `galaxy-game-ui` repository is an implementation/prototype workspace; its current appearance does not independently establish approved product design. Work orders in `agent-tasks` should reference these pages rather than restating design discussions.

## Current scope

| Page | Purpose |
|------|---------|
| [Branding and entry experience](01_branding_and_entry_experience.md) | Shared branding, landing page, and sign-in experience |
| [Player view architecture](02_player_view_architecture.md) | Five player-facing views (Planetary, Surface, Settlement, Space, Galaxy), navigation model, and scope boundaries |

## Working lifecycle

1. Discuss the experience and alternatives.
2. Record approved intent, current direction, open questions, and relevant visual references here.
3. Create a narrow implementation task that references the wiki page.
4. Review the rendered prototype with the owner before moving to the next view.
5. Update this page with the actual reviewed result and any decisions that changed.

A proposed mockup or prototype screenshot is not automatically an approved design. Keep the distinction between **ESTABLISHED INTENT**, **DIRECTION**, and **OPEN** visible.

## UI Data Sourcing Rule

**All numeric values displayed in the runtime UI/HUD must be sourced from either:**
- Live code (`app/` models, services, controllers)
- The `operational_data` JSON configuration system

**Placeholder tables and estimates in this wiki are NOT valid data sources for live UI display.** Wiki tables, mass balances, and power budgets serve as design documentation and architectural reference only. Any wiki table marked `[PROPOSED / PLACEHOLDER]` must be replaced with code-grounded or `operational_data`-sourced values before being rendered to players.

## Change History

- **2026-11-04** — Created the UI & Experience section as the home for Galaxy Game interface design intent.
