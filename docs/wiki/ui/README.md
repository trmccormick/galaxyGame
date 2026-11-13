> **Wiki section:** UI & Experience · **Status:** design intent — evolving with reviewed prototype views

# UI & Experience

This section records the intended user experience and visual design of Galaxy Game's interface. It is part of the main `galaxyGame` repository because the interface is a product feature of Galaxy Game, even when a separate repository is used to prototype its implementation.

The wiki is the design authority. The `galaxy-game-ui` repository is an implementation/prototype workspace; its current appearance does not independently establish approved product design. Work orders in `agent-tasks` should reference these pages rather than restating design discussions.

## Current scope

| Page | Purpose |
|------|---------|
| [Branding and entry experience](01_branding_and_entry_experience.md) | Shared branding, landing page, and sign-in experience |
| [Player view architecture](02_player_view_architecture.md) | Four player contexts, system/body navigation, and scope boundaries |
| [Admin and AI Manager interfaces](03_admin_and_ai_manager.md) | Three-interface model, Admin responsibilities, AI Manager oversight, Map Studio, and Digital Twin workflows |
| [Current UI state and known issues](04_current_ui_state_and_known_issues.md) | Dated observations of the running main UI, visual inconsistencies, working views, and known rendering issues |

The [Current UI State and Known Issues](04_current_ui_state_and_known_issues.md) page records observed behavior and defects separately from design intent. The review principle is to preserve, complete, and standardize useful existing application views—not discard unfinished work and start over. Planetary/Orbital, Surface, Map Studio, Monitor, resource, and infrastructure views are candidates for prototype review and porting.

The UI architecture has three distinct interfaces: **Player Dashboard** and **Admin Dashboard**. They share a visual language and domain context but serve different audiences and workflows. The Player interface has four contexts described in page 02: Space, Planetary, Surface, and Settlement. Galaxy/system catalogs and system workspaces are navigation and selection workspaces, not additional Player views.

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
- **2026-11-11** — Expanded the architecture to document dashboard responsibilities, system/body workspaces, Admin/AI Manager direction, dated current-state issues, and preservation/completion of existing views.
- **2026-11-13** — Corrected the Player architecture to four contexts and clarified that AI Manager and Map Studio are dedicated workspaces within the Admin Dashboard.
