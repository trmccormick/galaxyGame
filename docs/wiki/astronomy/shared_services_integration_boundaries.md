# Astronomy Shared Services — Integration Boundaries

> **Code Alignment Status:** `DESIGN INTENT`  
> *Last Audited:* 2026-11-27  
> *Audit Summary:* Design intent specification. Code implementation pending or unverified as of audit baseline.

> **Wiki section:** Development · **Status:** current  
> **Created:** 2026-11-26  
> **Precedence:** This doc supplements `system_blueprints.md`. Owner-confirmed sections in that file take precedence.

## 1. Service Inventory

### Implemented

| Service | Class / File | Status |
|---|---|---|
| Base TAP client | `Astronomy::BaseTapClient` (`galaxy_game/app/services/astronomy/base_tap_client.rb`) | Implemented — shared HTTP base for all TAP providers. Returns `Astronomy::Result`. |
| Result value object | `Astronomy::Result` (`galaxy_game/app/services/astronomy/result.rb`) | Implemented — structured success/failure outcome with `error_kind` classification. |

### Planned (will use the shared base client)

| Service | Planned class / file | Status |
|---|---|---|
| SIMBAD TAP client | `Astronomy::SimbadTapClient` (to be created) | Planned — will use `BaseTapClient`; no file yet. |
| NASA Exoplanet Archive TAP client | `Astronomy::NasaEaTapClient` (to be created) | Planned — will use `BaseTapClient`; no file yet. |

### Intended consumers

| Consumer | Entry point | Role |
|---|---|---|
| StarSim | `galaxy_game/app/services/star_sim/system_generator_service.rb` | System generation and seed completion |
| Mapping / Galaxy View | `galaxy_game/app/services/lookup/star_system_lookup_service.rb` | Astronomical identity and position lookup |

## 2. Safe Now vs Must Wait

### Safe now (optional enrichment, full failure tolerance)

- The shared `BaseTapClient` already classifies transport failures (`:timeout`, `:unavailable`, `:unsuccessful`) and never raises for network errors — it returns a failed `Result`.
- Consumers may safely call the base client today as an optional enrichment layer: on timeout or unavailable, generation continues; an empty result set from a provider means unknown, not absence.
- No provenance schema, cache design, or matching thresholds are required to begin using the base client for targeted lookups.

### Must wait (OPEN decisions)

| Item | Why it must wait |
|---|---|
| Provenance schema | Not yet designed; observed vs generated tagging requires a stable schema. |
| Matching thresholds | Confidence thresholds and candidate-selection criteria remain OPEN. |
| Persistent cache / mirror / refresh policy | Cache storage design, mirror/fallback policy, and refresh cadence are OPEN. |
| Normalization schema | Cross-provider field normalization is not yet defined. |

## 3. Failure Semantics

| Scenario | Behavior |
|---|---|
| Timeout (open/read timeout) | `Result.failure(error_kind: :timeout)`; generation continues. |
| Unavailable (connection refused, DNS, TLS, socket errors, HTTP 5xx) | `Result.failure(error_kind: :unavailable)`; generation continues. |
| Unsuccessful (3xx, 4xx including 429) | `Result.failure(error_kind: :unsuccessful)` with status preserved; generation continues. |
| Empty result set from a provider means unknown, not absence | Consumers must treat an empty body or no-match response as "no data found," not "the object does not exist." |
| Programmer errors (bad base_url, bad path) | `ArgumentError` raised — these are developer bugs, not runtime failures. |

## 4. Observed vs Generated Separation

- **Observed values** come from SIMBAD or NASA Exoplanet Archive via the shared TAP client and carry source identifiers, provenance, and measurement context.
- **Generated values** come from StarSim's procedural generation path (`system_generator_service.rb`) and represent simulated content.
- Observed values stay distinguishable from generated ones; precedence between them is OPEN. Consumers must not conflate the two categories or silently overwrite one with the other.

## 5. Non-goals

The following are explicitly out of scope for this doc and for any integration work that follows:

- Bulk ingestion pipelines (targeted lookups only)
- Per-consumer provider clients (all providers share `BaseTapClient`)
- Coupling to StarSim SPEC drafts
- Provenance schema design
- Cache / mirror / refresh policy design
- Matching threshold configuration
- Rewriting owner-confirmed sections of `system_blueprints.md`

## 6. Pointers to OPEN Items in system_blueprints.md

| OPEN item | Location in system_blueprints.md |
|---|---|
| Seed completion versus generation from scratch; real-star matching | Section "Seed completion versus generation from scratch; real-star matching" (line ~60) — covers matching criteria and confidence thresholds. |
| Service endpoints, mirror/fallback policy, query set, refresh cadence, cache/storage design, normalization schema | Section "Main-game astronomical data integrations: SIMBAD and NASA Exoplanet Archive" (line ~97) — covers provider integration scope and remaining OPEN details. |
| When new systems are generated; active vs archived system population | Sections "Active-system lifecycle, archival, and reactivation" (line ~146) and "On-demand frontier generation and a bounded active universe" (line ~157). |
| Current data organization separating observed from generated | Section "Current data organization — observed, not finalized" (line ~195). |
| Galaxy-wide playable scale and system count | Section "Galaxy-wide playable scale and system count" (line ~209). |

---

*See also: [System Blueprints](./system_blueprints.md)*
