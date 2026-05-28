# Player Roles and Alignment

> **Scope:** Player-facing manual and frontend UI development guide. Documents how human actions alter standing within the game's faction ecosystem, how the Rails backend passes alignment state to the JavaScript frontend, and how the UI renders status indicators, faction badges, and reputation sliders.

---

## Component Map

| Component | Role |
|---|---|
| `FactionStandingEngine` | Calculates and persists alignment score changes from player actions |
| `AccountabilityService` | Validates actions against regional law definitions; issues penalties and flags |
| `PlayerDashboardController` | Rails controller that serializes and delivers alignment state vectors to the frontend |

---

## Design Philosophy

Player alignment in Galaxy Game is not a single moral axis — it is a **multi-dimensional standing vector**. A player can be trusted by corporate hauling syndicates while simultaneously flagged as hostile by a colonial regulatory authority. The `FactionStandingEngine` maintains an independent reputation score for each registered faction or regional entity, and the frontend must render these as distinct, individually meaningful indicators rather than collapsing them into a single "good/evil" rating.

---

## The Faction Standing Engine

### Standing Score Structure

Each player has a `faction_standings` record for every faction they have interacted with. A standing score is a float in the range `[-1000.0, 1000.0]`. The engine enforces hard clamps at both ends — scores cannot overflow or underflow this range under any circumstances. See the Overflow/Underflow Protection section below.

Faction standing categories and their default starting values:

| Faction Type | Starting Standing | Description |
|---|---|---|
| Colonial Authority | 0.0 (neutral) | Regional governance bodies — control mining licenses, sector access, taxation |
| Corporate Syndicate | 0.0 (neutral) | Logistics and trade guilds — control high-value hauling contracts and market access |
| Deep Space Independent | 100.0 (slight positive) | Unaffiliated operators; loosely cooperative by default |
| Black Market Network | -500.0 (hostile) | Unregistered trade networks; players start deeply distrusted |
| Security Contractor | 0.0 (neutral) | Automated and NPC defense contractors; respond to flagged traitor states |

### Standing Thresholds

The engine maps numeric standing scores to named status tiers used by both the backend and the frontend UI:

| Score Range | Tier Name | Gameplay Implications |
|---|---|---|
| 750 to 1000 | `allied` | Full market access, contract priority, reduced tariffs |
| 400 to 749 | `trusted` | Standard market access, eligible for high-security contracts |
| 50 to 399 | `neutral` | Default access, no bonuses or penalties |
| -249 to 49 | `suspect` | Increased inspection rates, tariff surcharges |
| -599 to -250 | `hostile` | Docking denied at faction stations, NPC intercept risk |
| -1000 to -600 | `kos` | Kill-on-sight flagged; security contractors will engage on detection |

---

## Penalty Mechanics

### Unauthorized Resource Extraction

Extracting resources from controlled sectors without a valid extraction license triggers `AccountabilityService#log_unlicensed_extraction`. The penalty is applied to the relevant Colonial Authority's standing score.

Penalty calculation:

```
standing_delta = -(base_extraction_penalty * resource_scarcity_multiplier * sector_control_weight)
```

Where:
- `base_extraction_penalty` = 15.0 points per incident
- `resource_scarcity_multiplier` = 1.0 to 5.0 (scales with how scarce the extracted resource is in that region's market)
- `sector_control_weight` = 1.0 to 3.0 (higher in heavily administered core sectors, lower in frontier zones)

A single unlicensed regolith extraction event in a tightly controlled core sector with a scarce mineral yield can produce a standing loss of up to 225.0 points in a single incident — enough to move a player from `trusted` to `hostile` in one action.

The `AccountabilityService` also checks whether the player holds any active extraction licenses before processing the penalty. If a license exists but has expired, the penalty is halved and a `license_expired` flag is attached to the audit log rather than a `criminal_extraction` flag. Expired license penalties do not affect `kos` tier progression.

### Black Market Sales

Selling cargo to an unregistered deep-space market — any entity not present in the `registered_market_nodes` table — triggers `AccountabilityService#log_black_market_transaction`. This applies a standing penalty to all Corporate Syndicate factions with active trade operations in the current region, and a moderate positive standing gain with the Black Market Network.

Penalty/gain calculation:

```
syndicate_standing_delta = -(cargo_value_gcc * 0.002)
black_market_standing_gain = cargo_value_gcc * 0.001
```

Example: A 50,000 GCC cargo sale to an unregistered market produces a 100-point loss with regional syndicates and a 50-point gain with the Black Market Network. Repeated transactions of this type will push the player toward `hostile` with syndicates while gradually opening Black Market Network contract access (which begins at -500.0 and requires sustained engagement to bring into `suspect` range).

### Penalty Application Flow

All penalties pass through the following chain before the standing score is committed:

1. `AccountabilityService` validates the action type and retrieves the relevant faction identifiers.
2. `AccountabilityService` calculates the raw delta and passes it to `FactionStandingEngine#apply_delta`.
3. `FactionStandingEngine#apply_delta` applies the overflow/underflow clamp (see below).
4. The updated standing score is persisted and the cached reputation record is invalidated.
5. An audit log entry is written with the action type, delta, resulting score, and timestamp.

---

## Overflow and Underflow Protection

Standing scores must never exceed `1000.0` or fall below `-1000.0`. The `FactionStandingEngine` enforces this with a clamp applied at every write:

```ruby
def apply_delta(player_id, faction_id, delta)
  current = fetch_standing(player_id, faction_id)
  raw_result = current + delta
  clamped = raw_result.clamp(-1000.0, 1000.0)
  persist_standing(player_id, faction_id, clamped)
  invalidate_reputation_cache(player_id, faction_id)
  clamped
end
```

The clamp is applied after every delta, including bulk batch updates. There is no pathway through `FactionStandingEngine` that writes an unclamped value. Any direct database writes to standing scores that bypass this method are a bug — they circumvent both the clamp and the cache invalidation.

---

## Reputation Caching

Reading reputation scores on every market tick would produce an untenable database load at scale. The `FactionStandingEngine` maintains a per-player, per-faction reputation cache with the following rules:

- Cache entries are written on every `apply_delta` call.
- Cache TTL: 60 seconds for players currently active in a market context; 300 seconds for idle players.
- Cache is invalidated immediately on any standing change (not TTL-expired — actively purged).
- `PlayerDashboardController` reads exclusively from cache for dashboard renders. It does not hit the database directly for standing scores.
- If a cache entry is missing (cold start, cache eviction), the controller fetches from the database and warms the cache before returning the response.

Cache key format: `reputation:player:{player_uuid}:faction:{faction_id}`

The market tick loop must never bypass the cache layer to read raw standing scores. If a market action requires a fresh standing check (e.g., verifying contract eligibility), it must call `FactionStandingEngine#current_standing`, which handles cache-first resolution internally.

---

## Backend-to-Frontend Alignment State Vector

`PlayerDashboardController#alignment_state` serializes the player's full standing vector into a JSON payload delivered to the frontend. This endpoint is polled by the dashboard on a configurable interval (default: every 10 seconds when the dashboard is active).

### Payload Schema

```json
{
  "player_id": "c9a3f102-7e84-4b21-a601-5e9034dc9a31",
  "alignment_vector": [
    {
      "faction_id": "colonial_authority_kepler",
      "faction_name": "Kepler Colonial Authority",
      "faction_type": "colonial_authority",
      "score": 312.5,
      "tier": "neutral",
      "tier_numeric": 3,
      "score_normalized": 0.656,
      "trend": "declining",
      "last_event": "unlicensed_extraction",
      "last_event_at": "2157-03-14T09:14:22Z"
    },
    {
      "faction_id": "syndicate_deep_reach_logistics",
      "faction_name": "Deep Reach Logistics Syndicate",
      "faction_type": "corporate_syndicate",
      "score": 587.0,
      "tier": "trusted",
      "tier_numeric": 4,
      "score_normalized": 0.794,
      "trend": "stable",
      "last_event": "contract_completed",
      "last_event_at": "2157-03-13T22:41:05Z"
    },
    {
      "faction_id": "black_market_outer_veil",
      "faction_name": "Outer Veil Network",
      "faction_type": "black_market_network",
      "score": -387.0,
      "tier": "hostile",
      "tier_numeric": 2,
      "score_normalized": 0.307,
      "trend": "improving",
      "last_event": "black_market_sale",
      "last_event_at": "2157-03-14T07:58:44Z"
    }
  ],
  "global_security_rating": 2.1,
  "kos_active": false,
  "cached_at": "2157-03-14T09:20:00Z"
}
```

Field notes:
- `score_normalized` maps the raw score from `[-1000, 1000]` to `[0.0, 1.0]` for direct use by frontend slider components: `(score + 1000) / 2000.0`
- `tier_numeric` is a 1–6 integer corresponding to the six tier levels in ascending order (`kos` = 1, `allied` = 6), for use by components that need numeric comparisons rather than string matching
- `trend` is derived from the delta between the last two standing snapshots: `"improving"`, `"declining"`, or `"stable"` (less than 1.0 point change)
- `global_security_rating` is a composite float derived from the weighted average of all Colonial Authority and Corporate Syndicate standings; it is the value displayed in the top-level HUD security indicator

---

## Frontend UI Implementation

### Status Indicator Components

The alignment state vector drives three distinct UI elements on the player dashboard:

**1. Faction Badge Row**

A horizontal row of faction badges rendered beneath the player name. Each badge displays the faction's icon, abbreviated name, and a color-coded border corresponding to the tier:

| Tier | Badge Border Color |
|---|---|
| `allied` | `#00D4AA` (teal) |
| `trusted` | `#5BC8F5` (blue) |
| `neutral` | `#A0A0A0` (grey) |
| `suspect` | `#F5C842` (amber) |
| `hostile` | `#F57842` (orange) |
| `kos` | `#E03030` (red, pulsing animation) |

Badges are ordered by faction type: Colonial Authorities first, Corporate Syndicates second, Independent and Black Market factions last.

**2. Reputation Slider**

For each faction in the `alignment_vector`, a custom JavaScript slider widget renders the player's standing. The slider is read-only (players cannot drag it) and maps directly from `score_normalized`:

```javascript
function renderReputationSlider(factionData) {
  const sliderEl = document.getElementById(`slider-${factionData.faction_id}`);
  const fillEl = sliderEl.querySelector('.reputation-fill');
  const labelEl = sliderEl.querySelector('.reputation-tier-label');

  // score_normalized is already [0.0, 1.0] — map directly to percentage fill
  fillEl.style.width = `${(factionData.score_normalized * 100).toFixed(1)}%`;
  fillEl.setAttribute('data-tier', factionData.tier);
  labelEl.textContent = factionData.tier.replace('_', ' ').toUpperCase();

  // Apply trend indicator arrow
  const trendEl = sliderEl.querySelector('.reputation-trend');
  trendEl.textContent = factionData.trend === 'improving' ? '▲'
                       : factionData.trend === 'declining' ? '▼'
                       : '—';
}
```

The slider fill color must match the badge border color for the current tier. Color is applied via a CSS data attribute selector: `[data-tier="kos"] { background-color: #E03030; }`, not via inline styles, so that theming overrides function correctly.

**3. Global Security Rating HUD Element**

The top-level heads-up display renders `global_security_rating` as a numeric value (one decimal place) alongside a color-coded icon. This is the single most-visible alignment indicator and must update on every polling cycle.

```javascript
function updateSecurityRatingHUD(alignmentPayload) {
  const rating = alignmentPayload.global_security_rating;
  const hudEl = document.getElementById('hud-security-rating');

  hudEl.querySelector('.rating-value').textContent = rating.toFixed(1);

  // Color thresholds mirror the tier boundaries scaled to the composite range
  const colorClass = rating >= 4.0 ? 'rating-trusted'
                   : rating >= 2.5 ? 'rating-neutral'
                   : rating >= 1.0 ? 'rating-suspect'
                   : 'rating-hostile';

  hudEl.className = `hud-security-widget ${colorClass}`;

  if (alignmentPayload.kos_active) {
    hudEl.classList.add('rating-kos-pulse');
  }
}
```

The `rating-kos-pulse` CSS class applies a red pulsing border animation. It must be removed immediately if a subsequent polling response returns `kos_active: false`.

### Polling and State Sync

The frontend alignment poller runs as a dedicated JavaScript module, not as part of the general data refresh cycle:

```javascript
class AlignmentPoller {
  constructor(playerId, intervalMs = 10000) {
    this.playerId = playerId;
    this.intervalMs = intervalMs;
    this.timer = null;
  }

  start() {
    this.fetchAndRender();
    this.timer = setInterval(() => this.fetchAndRender(), this.intervalMs);
  }

  stop() {
    if (this.timer) clearInterval(this.timer);
  }

  async fetchAndRender() {
    const response = await fetch(`/api/players/${this.playerId}/alignment_state`);
    if (!response.ok) return; // Fail silently; do not clear current display on network error
    const data = await response.json();
    data.alignment_vector.forEach(faction => renderReputationSlider(faction));
    updateSecurityRatingHUD(data);
  }
}
```

Polling must fail silently on network errors — the current displayed state should persist rather than clearing to a blank or error state. A separate connectivity indicator (outside the alignment widgets) handles offline notification.

---

## Gap Tracking & Known Issues

- [ ] **Overflow/underflow unit test coverage:** The clamp in `FactionStandingEngine#apply_delta` must have explicit spec coverage for boundary conditions: a delta that would push a score above 1000.0, a delta that would push below -1000.0, and a delta applied to a score already at the boundary. Verify these are in the spec suite before Phase 4.
- [ ] **Cache invalidation on batch penalty application:** When `AccountabilityService` applies bulk penalties (e.g., after a cargo audit that flags multiple violations simultaneously), the cache invalidation must fire once per affected faction record, not once for the entire batch. Confirm the current implementation does not batch-invalidate with a single cache flush that could miss individual faction keys.
- [ ] **`kos` tier badge animation performance:** The pulsing CSS animation on `kos`-tier badges must be tested for frame rate impact when a player has multiple simultaneous `kos` factions. If more than two badges are pulsing simultaneously, consider switching to a static indicator to avoid animation jank on lower-end clients.
- [ ] **Automated defense contractor reaction hooks:** The Security Contractor faction response to `kos` state transitions (NPC intercept spawning, station lockout enforcement) is documented in `docs/wiki/The-Traitor-Playbook.md`. The `FactionStandingEngine` emits a `standing_tier_changed` event on every tier transition; the defense contractor reaction system must subscribe to this event and filter for `kos_active` transitions specifically.

---

*Last verified against: `FactionStandingEngine`, `AccountabilityService`, `PlayerDashboardController` — Phase 3 (Integration & Restoration)*
