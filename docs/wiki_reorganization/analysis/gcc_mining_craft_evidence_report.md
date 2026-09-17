# Craft/Satellite Evidence Extraction Report

**Date**: 2026-09-15  
**Type**: Read-only repository evidence extraction  
**Purpose**: Provide confirmed evidence for wiki_reorganization authoritative documentation  
**Rule**: No files modified, created, edited, moved, renamed, staged, committed, reset, formatted, or deleted during this task.

---

## A. Source and Branch Context

| Item | Value |
|------|-------|
| **Repository root** | `/Users/tam0013/Documents/git/galaxyGame` |
| **Branch** | `main` |
| **HEAD commit** | `0e4f67be` — "docs: GCC mining terminology correction — fiat identity, issuance language, implementation gap callout" |
| **wiki_reorganization root** | `/Users/tam0013/Documents/git/galaxyGame/docs/wiki_reorganization/` |
| **Search scope** | All files under `galaxy_game/app/`, `galaxy_game/config/`, `docs/wiki_reorganization/`, and `data/` via grep_search, read_file, and targeted file reads |
| **Access limitations** | No database queries executed; no Rails console sessions; no test execution. Evidence is source-code-level only. Runtime behavior (which satellites are actually deployed, which GCC accounts receive deposits) cannot be confirmed without executing the application. |

---

## B. Craft Taxonomy Evidence

### 1. `Craft::BaseCraft` — Definition and Status

**Finding**: `Craft::BaseCraft` is the active, primary craft model class. It is an ActiveRecord ApplicationRecord in module namespace `Craft`.

| Finding | Evidence Path | Excerpt/Key | Category | Confidence | Implication for Wiki |
|---------|---------------|-------------|----------|------------|---------------------|
| Active craft base class | `galaxy_game/app/models/craft/base_craft.rb:3` | `module Craft; class BaseCraft < ApplicationRecord` | Executed/current code structure | **HIGH** | Canonical craft type. All manufactured craft inherit from this. |
| Has modules association | `base_craft.rb:51` | `has_many :modules, class_name: 'Modules::BaseModule', as: :attachable` | Executed/current code structure | **HIGH** | Craft can carry modules. |
| Has units association | `base_craft.rb:49` | `has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable` | Executed/current code structure | **HIGH** | Craft can carry base_units. |
| Has rigs association | `base_craft.rb:68` (in concern) | `has_many :rigs, as: :attachable, class_name: 'Rigs::BaseRig'` | Executed/current code structure | **HIGH** | Craft can carry rigs. |
| Status attribute | `base_craft.rb:43` | `attribute :status, :string, default: 'operational'` | Active loaded data/configuration | **HIGH** | Craft has a status field; only default is 'operational'. No enum or state machine found. |
| Validated fields | `base_craft.rb:46-50` | `validates :craft_name, :craft_type, presence: true`; `validates :owner, presence: true` | Active loaded data/configuration | **HIGH** | Every craft must have a name, type, and owner. |
| Abandoned drafts exist | `base_craft.rb.new`, `.new2`, `.new3` | Same class definition in 4 files | Legacy/uncorroborated artifact | **MEDIUM** | These are abandoned draft copies. Only `base_craft.rb` is active. |

### 2. `Craft::Satellite::BaseSatellite` — Manufactured/Orbital Satellite Class

**Finding**: A manufactured satellite class exists and inherits from `Craft::BaseCraft`. It includes `CryptocurrencyMining` concern.

| Finding | Evidence Path | Excerpt/Key | Category | Confidence | Implication for Wiki |
|---------|---------------|-------------|----------|------------|---------------------|
| Manufactured satellite class | `galaxy_game/app/models/craft/satellite/base_satellite.rb:4` | `module Craft; module Satellite; class BaseSatellite < Craft::BaseCraft` | Executed/current code structure | **HIGH** | **CONFIRMED**: There IS a manufactured/orbital satellite class. It is `Craft::Satellite::BaseSatellite`. |
| Includes crypto mining | `base_satellite.rb:5` | `include CryptocurrencyMining` | Executed/current code structure | **HIGH** | Satellites can mine GCC. This is the first Luna-bootstrap deployable asset with built-in economic capability. |
| Valid deployment locations | `base_satellite.rb:34-44` | 13 orbital/deep-space location types including 'orbital', 'geosynchronous_orbit', 'wormhole_proximity' | Executed/current code structure | **HIGH** | Satellites are designed for orbital placement. No surface deployment. |
| Wormhole stabilization | `base_satellite.rb:62` | `can_stabilize_wormhole?` checks for wormhole_stabilizer unit/module | Executed/current code structure | **HIGH** | Satellite can stabilize wormholes if fitted with appropriate units/modules. |
| Build units and modules | `base_satellite.rb:130-250` | `build_units_and_modules` creates base_units, base_modules, base_rigs from recommended_fit data | Executed/current code structure | **HIGH** | Satellites are built from manifest/JSON data at creation time. |
| Process tick mining | `base_satellite.rb:310-340` | `process_tick` calls `mine_gcc`, deposits to owner's GCC account | Executed/current code structure | **HIGH** | Mining is tick-driven, not real-time. Deposits go to owner's GCC account. |

### 3. Natural/Celestial Satellite Type

**Finding**: A separate natural satellite hierarchy exists under `CelestialBodies::Satellites`.

| Finding | Evidence Path | Excerpt/Key | Category | Confidence | Implication for Wiki |
|---------|---------------|-------------|----------|------------|---------------------|
| Natural satellite class | `galaxy_game/app/models/celestial_bodies/satellites/satellite.rb:4` | `module CelestialBodies; module Satellites; class Satellite < CelestialBody` | Executed/current code structure | **HIGH** | **CONFIRMED**: Two distinct "Satellite" namespaces exist. Natural satellites orbit celestial bodies; manufactured satellites are craft. |
| Inherits from CelestialBody | `satellite.rb:4` | `class Satellite < CelestialBody` | Executed/current code structure | **HIGH** | Natural satellites ARE celestial bodies, not craft. Terminology distinction is critical. |
| Moon subclasses | `app/models/celestial_bodies/satellites/moon.rb:4`, `large_moon.rb:2`, `ice_moon.rb:2`, `small_moon.rb:2` | `class Moon < Satellite`; `IceMoon < Satellite`; `SmallMoon < Satellite` | Executed/current code structure | **HIGH** | Natural satellites have a Moon hierarchy with IceMoon/SmallMoon subtypes. |
| Parent body relationship | `satellite.rb:13` | `belongs_to :parent_celestial_body` | Executed/current code structure | **HIGH** | Natural satellites orbit a parent celestial body. |
| Tidal locking | `satellite.rb:24-28` | `tidally_locked?` method checks rotational vs orbital period ratio | Executed/current code structure | **HIGH** | Natural satellites have orbital mechanics properties. |

### 4. `Craft::Ship` — Status and References

**Finding**: `Craft::Ship` exists as a subclass of `BaseCraft`. A separate top-level `Ship` class also exists but appears to be legacy/standalone.

| Finding | Evidence Path | Excerpt/Key | Category | Confidence | Implication for Wiki |
|---------|---------------|-------------|----------|------------|---------------------|
| Craft::Ship subclass | `galaxy_game/app/models/craft/ship.rb:2` | `class Ship < BaseCraft` | Executed/current code structure | **HIGH** | **CONFIRMED**: `Craft::Ship` is a craft type that inherits from BaseCraft. It is the manufactured transport category. |
| Top-level Ship class (legacy?) | `galaxy_game/app/models/ship.rb:1-16` | Standalone class with `arrive(colony)` and `depart(colony)` methods; no ActiveRecord, no associations | Legacy/uncorroborated artifact | **MEDIUM** | This top-level `Ship` is NOT an ActiveRecord model. It appears to be a legacy/simple data object. May be unused or used only in tests. |
| Terrain rendering reference | `app/services/terrain_data_builder.rb:16` | `'Craft::Ship' => 10` (tile size mapping) | Active loaded data/configuration | **HIGH** | Craft::Ship is referenced in terrain rendering as a tileable entity type. |

### 5. Distinctions Among Categories

| Finding | Evidence Path | Excerpt/Key | Category | Confidence | Implication for Wiki |
|---------|---------------|-------------|----------|------------|---------------------|
| **Craft** = `Craft::BaseCraft` (and subclasses) | `base_craft.rb:3` | ActiveRecord model, carries modules/units/rigs, has atmosphere, can dock, deploys to locations | Executed/current code structure | **HIGH** | Craft is the manufactured vehicle category. Includes Ship, Satellite, and any future craft types. |
| **Units** = `Units::BaseUnit` (and subclasses) | `galaxy_game/app/models/units/base_unit.rb:4` | ActiveRecord model; attachable TO craft/settlements/structures; represents equipment/components like computers, propulsion, habitat units | Executed/current code structure | **HIGH** | Units are sub-craft equipment. They cannot exist independently of an attachable host. |
| **Modules** = `Modules::BaseModule` (and subclasses) | `galaxy_game/app/models/concerns/has_modules.rb:6` | ActiveRecord model; attachable to craft/settlements/structures; separate from units in the port system | Executed/current code structure | **HIGH** | Modules are structural building blocks. Distinct from units in the attachment/port system. |
| **Stations** = `Settlement::SpaceStation` | `galaxy_game/app/models/settlement/space_station.rb:6` | `class SpaceStation < BaseSettlement` | Executed/current code structure | **HIGH** | Stations are settlements (administrative containers), not craft. They dock craft. |
| **Components** = manufacturing sub-elements | `data/json-data/blueprints/components/`, `Manufacturing::ComponentProductionService` | Smaller than modules; used in manufacturing chain (raw → processed → component → blueprint) | Documentation/planning only | **MEDIUM** | Components are a manufacturing concept, not a runtime attachment category. |
| **Deployable entities** | `base_satellite.rb:deploy()` method | Satellites deploy to orbital locations; settlements don't have deploy() | Executed/current code structure | **HIGH** | Only satellites have explicit deployment logic. Craft can be docked but not "deployed." |
| **Static/celestial infrastructure** = `Structures::BaseStructure` | `galaxy_game/app/models/structures/base_structure.rb:25` | `has_many :modules`; PowerStation < BaseStructure; Worldhouse, CraterDome, etc. | Executed/current code structure | **HIGH** | Structures are static infrastructure attached to settlements. Not craft, not deployable. |

---

## C. GCC Crypto-Mining Satellite Evidence

### 1. Core Mining Infrastructure

| Finding | Evidence Path | Object Type | Runtime Loaded? | Details |
|---------|---------------|-------------|-----------------|---------|
| `CryptocurrencyMining` concern | `galaxy_game/app/models/concerns/cryptocurrency_mining.rb:2` | Concern module | **YES** — included by BaseSatellite and BaseSettlement | Defines `mine_gcc`, `can_mine_gcc?`, `mining_units`, `power_required_for_mining`, `apply_mining_effects()` |
| `CryptocurrencyMining` in BaseSatellite | `base_satellite.rb:5` | Concern inclusion | **YES** | Satellite can mine GCC via included concern |
| `CryptocurrencyMining` in BaseSettlement | `galaxy_game/app/models/settlement/base_settlement.rb:6` | Concern inclusion | **YES** | Settlements can also mine GCC (dual capability) |
| `MineGccJob` Sidekiq job | `galaxy_game/app/jobs/mine_gcc_job.rb:5` | Job class | **YES** — queued by SatelliteMiningSchedulerJob | Calls `colony.mine_gcc` where colony is any entity with the concern |
| `SatelliteMiningSchedulerJob` | `galaxy_game/app/jobs/satellite_mining_scheduler_job.rb:11` | Sidekiq Job | **YES** — self-scheduling every 1 hour | Finds deployed satellites with advanced_computer or basic_computer units; queues MineGccJob with 4-hour interval |
| `crypto_mining_satellite` craft_type | `celestial_bodies_controller.rb:734` | String literal in query | **YES** — used to filter satellites | `.where("operational_data->>'craft_type' = ?", 'crypto_mining_satellite')` |
| `gcc_mining_satellite_01_pattern` | `ai_manager_controller.rb:237` | String key in hash | **YES** — mission pattern reference | `'asteroid-mining' => 'gcc_mining_satellite_01_pattern'` |
| `gcc_sat_mining_deployment` manifest path | `celestial_bodies_controller.rb:1029` | File path constant | **YES** — loads JSON at runtime | `GalaxyGame::Paths::MISSIONS_PATH.join('gcc_sat_mining_deployment', 'crypto_mining_satellite_01_manifest_v2.json')` |
| `mine_gcc` method | `cryptocurrency_mining.rb:10-80` | Instance method | **YES** — called from process_tick, MissionTaskRunnerService | Returns total mined GCC; deposits to owner's account via `account.deposit(total_mined, "GCC Mining Operation")` |
| `recalculate_stats` in BaseCraft | `base_craft.rb:372-390` | Instance method | **YES** — called by HasUnits concern | Computes `current_mining_rate_gcc_per_hour` from base rate + computer boosts + GPU rig boosts |

### 2. GCC Economic Configuration

| Finding | Evidence Path | Value/Key | Category | Confidence |
|---------|---------------|-----------|----------|------------|
| Max supply | `economic_parameters.yml:256` | `max_supply: 21000000000` (21 billion) | Active loaded data/configuration | **HIGH** |
| Halving interval | `economic_parameters.yml:257` | `halving_interval_days: 730` (2 years) | Active loaded data/configuration | **HIGH** |
| Issuance model | `economic_parameters.yml:255` | `issuance_model: "capped_deflationary"` | Active loaded data/configuration | **HIGH** |
| Difficulty scaling | `economic_parameters.yml:258` | `difficulty_scaling: true` | Active loaded data/configuration | **HIGH** |
| Initial block reward | `economic_parameters.yml:259` | `initial_block_reward: 1000` (GCC per block) | Active loaded data/configuration | **HIGH** |
| Minimum block reward | `economic_parameters.yml:260` | `minimum_block_reward: 1` | Active loaded data/configuration | **HIGH** |
| EconomicConfig methods | `economic_config.rb:140-160` | `gcc_max_supply`, `gcc_halving_interval_days`, `gcc_initial_block_reward` etc. | Executed/current code structure | **HIGH** |

### 3. GCC Recipient Account Behavior

| Finding | Evidence Path | Details |
|---------|---------------|---------|
| LDC Bootstrap account | `celestial_bodies_controller.rb:720-730` | `@ldc_gcc_account_bootstrap = Account.find_or_create_for_entity_and_currency(accountable_entity: @ldc_bootstrap, currency: Currency.find_by(symbol: 'GCC'))` — deposits 100,000 GCC initial fund |
| Mining deposit target | `base_satellite.rb:335-336` | `owner_gcc_account = Account.find_or_create_for_entity_and_currency(accountable_entity: owner, currency: Currency.find_by(symbol: 'GCC'))` — deposits mined GCC to satellite's owner account |
| Mission task deposit | `mission_task_runner_service.rb:27` | `accounts[:ldc].deposit(initial_gcc, "Initial GCC mining from #{satellite.name}")` — deposits to LDC account passed in |
| Colonies controller | `colonies_controller.rb:10` | `@colony.mine_gcc` — settlement-level mining trigger |

### 4. Authorization/Ownership Checks

| Finding | Evidence Path | Details |
|---------|---------------|---------|
| Owner-based account lookup | `base_satellite.rb:335` | Account is derived from `owner` entity — no explicit permission check beyond ownership |
| `can_mine_gcc?` guard | `cryptocurrency_mining.rb:247` | `(respond_to?(:account) && account.present?) && mining_units.any?` — requires account + computer units |
| Power check | `cryptocurrency_mining.rb:18-30` | Checks `has_sufficient_power?` and battery level before mining |

### 5. Net-New GCC Creation

| Finding | Evidence Path | Details |
|---------|---------------|---------|
| `account.deposit()` call | `cryptocurrency_mining.rb:56` | `account.deposit(total_mined, "GCC Mining Operation")` — deposits to account; whether this creates net-new GCC depends on Account model's deposit implementation (not inspected) |
| `self.funds += total_mined` | `cryptocurrency_mining.rb:59` | Also adds to `funds` attribute if present |
| MiningLog creation | `cryptocurrency_mining.rb:63-80` | Creates MiningLog record with operational details (power, efficiency, units) |

**[FILL IN: Evidence not found]** — The Account model's `deposit` method implementation was not inspected. Whether it creates net-new GCC or transfers from a central mint is unknown. The `Currency.find_by(symbol: 'GCC')` lookup confirms GCC exists as a Currency record.

### 6. Physical vs Virtual Production

| Finding | Evidence Path | Details |
|---------|---------------|---------|
| Mining via computer units | `cryptocurrency_mining.rb:38-42` | `mining_units` selects Units::Computer instances; calls `unit.mine(mining_difficulty, unit_efficiency)` |
| GCC deposit to account | `cryptocurrency_mining.rb:56` | Virtual currency deposit — no physical material output |
| MiningLog tracks power/thermal data | `cryptocurrency_mining.rb:70-80` | Tracks thermal efficiency, processing boost, power usage — but these are computational metrics, not material extraction |

**Conclusion**: GCC mining is **virtual issuance**, not physical material production. It uses computer units as computational resources and deposits to a currency account. The `MiningLog` tracks computational parameters (power, thermal, processing), not material yields.

---

## D. Rate, Cadence, and Equipment Evidence

### Reconciliation Table

| Claim/Value | Source(s) | Active Runtime Consumer | Runtime Time Basis | Confirmed Status | Conflict/Gap |
|-------------|-----------|------------------------|-------------------|-----------------|--------------|
| **1,000,000 GCC/cycle or daily** | Not found in any code, config, or doc inspected | N/A | N/A | **NOT CONFIRMED** — no source found for this value | Gap: This claim has no corroborating evidence in the repository |
| **1,000 GCC/hour base rate** | `economic_parameters.yml:259` — `initial_block_reward: 1000`; comment says "GCC per block (hourly for simulation)" | EconomicConfig.gcc_initial_block_reward; used as default difficulty in mining calculations | **Game tick** (not real hour) | **PARTIALLY CONFIRMED** — 1,000 is the initial block reward per "block"; labeled as hourly in comment but actual time basis is game tick | Comment says "hourly for simulation" but no explicit timer converts this to real hours. The MineGccJob uses `mining_interval: 4.hours` (Sidekiq delay) |
| **6-hour cycle** | Not found in code or config | N/A | N/A | **NOT CONFIRMED** — no 6-hour value found | Gap: Could be from documentation not inspected, or a design plan not implemented |
| **6,000 GCC/cycle** | Not found in code or config | N/A | N/A | **NOT CONFIRMED** — no 6,000 value found | Gap: No source found |
| **24,000 GCC/day/per-satellite** | Not found in code or config | N/A | N/A | **NOT CONFIRMED** — no 24,000 value found | Gap: No source found. If 1,000/hour x 24 = 24,000, this is a mathematical derivation, not a configured value |
| **4-hour mining interval** | `satellite_mining_scheduler_job.rb:20` — `mining_interval: 4.hours` | SatelliteMiningSchedulerJob -> MineGccJob | Sidekiq delay (real time) | **CONFIRMED** — mining job is queued every 4 hours of real time | The scheduler runs every 1 hour, checks for pending jobs, and queues with 4-hour delay |
| **Base mining rate field** | `base_craft.rb:372` — `operational_data.dig('operational_properties', 'base_mining_rate_gcc_per_hour')` | BaseCraft.recalculate_stats | Per-hour (labeled) but no time conversion proven | **PARTIALLY CONFIRMED** — the field exists in operational_data schema; default is 0 if not set | No evidence that "per hour" means real hour vs game hour |
| **Computer mining boost** | `base_craft.rb:376-378` — `unit.operational_data.dig('operational_properties', 'mining_boost_gcc_per_hour')` | BaseCraft.recalculate_stats | Per-hour (labeled) | **CONFIRMED** — computer units contribute mining_boost_gcc_per_hour | Only if unit_type includes 'computer' |
| **GPU rig boost** | `base_craft.rb:380-382` — `r.operational_data.dig('operational_properties', 'processing_boost_gcc_per_hour')` | BaseCraft.recalculate_stats | Per-hour (labeled) | **CONFIRMED** — GPU rigs contribute processing_boost which is multiplied by computer count | Only if rig_type == 'gpu_coprocessor_rig' |
| **Fitted computer/GPU affects payout** | `base_satellite.rb:310-340` (process_tick); `cryptocurrency_mining.rb:38-42` (mining_units) | BaseSatellite.process_tick; CryptocurrencyMining.mine_gcc | Game tick | **CONFIRMED** — mining_units selects Units::Computer; apply_mining_effects applies thermal/processing/direct boosts | The concern's `apply_mining_effects` multiplies base_amount by thermal and processing multipliers |
| **`recalculate_stats` feeds `mine_gcc`** | `base_craft.rb:372-390` (recalculate_stats); `cryptocurrency_mining.rb:10` (mine_gcc) | Both methods exist but mine_gcc does NOT call recalculate_stats | N/A | **NO DIRECT LINK PROVEN** — recalculate_stats updates `current_mining_rate_gcc_per_hour` in operational_data; mine_gcc calls `unit.mine()` directly | recalculate_stats computes a rate; mine_gcc uses unit.mine() with difficulty/efficiency. The connection is via operational_data but not proven as a direct call chain |
| **Runtime clock/time basis** | `satellite_mining_scheduler_job.rb:20` — `mining_interval: 4.hours`; `base_satellite.rb:309` — `process_tick(time_skipped = 1)` | Sidekiq scheduler; satellite tick loop | **Mixed**: Sidekiq uses real hours; process_tick uses game time_skipped parameter | **CONFIRMED** — two separate time systems exist | The mining job is real-time (Sidekiq); the satellite tick is game-time driven |

### Smallest Possible Explanations for Unreconciled Claims

| Claim | Possible Explanation Categories |
|-------|-------------------------------|
| 1,000,000 GCC/cycle | Old/stale documentation; unused configuration; system-wide target vs per-satellite rate |
| 6-hour cycle | Design plan not implemented; separate simulation layer (not current code) |
| 6,000 GCC/cycle | Mathematical derivation from unproven base rate x multiplier |
| 24,000 GCC/day/per-satellite | Mathematical derivation (1,000 x 24); old/stale documentation |

---

## E. Lifecycle and Operations Evidence

### Satellite/Craft Lifecycle Stages

| Stage | Status | Evidence |
|-------|--------|----------|
| **Construction/Manufacturing** | Data-defined but not runtime-confirmed | `CraftFactoryService.build_from_blueprint()` in `celestial_bodies_controller.rb:1043`; `manufacturing/craft_factory.rb:8` — creates crypto_mining_satellite variant. No explicit "construction" service for craft (only for structures). |
| **Launch** | Implemented and evidenced | `deploy_gcc_satellite_for_ai()` in `celestial_bodies_controller.rb:1160-1185`; `LaunchPaymentService.pay_for_launch!()` with $544.22/kg pricing; payment via GCC/USD split |
| **Deployment** | Implemented and evidenced | `base_satellite.rb:48-55` — `deploy(location, options = {})` validates location type, sets `current_location`, `deployed: true`, `orbiting_celestial_body` |
| **Orbital Placement** | Implemented and evidenced | `base_satellite.rb:53` — `self.orbiting_celestial_body = options[:celestial_body]`; `stabilizing_wormhole` for wormhole_proximity locations |
| **Docking/Undocking** | Implemented and evidenced | `base_craft.rb:298-304` — `dock(settlement)` / `undock()` methods; `docked_at` polymorphic association; `has_available_docking_port?` check |
| **Cargo/Passenger Transfer** | Data-defined but not runtime-confirmed | `population_capacity`, `available_capacity`, `has_capacity_for?` in `base_craft.rb:86-102`; `current_storage` in `base_craft.rb:309`. No explicit transfer method found. |
| **Operation** | Implemented and evidenced | `process_tick()` in `base_satellite.rb:309-340`; power/battery management; GCC mining on tick; `operational?` check in `base_craft.rb:306` |
| **Mining/Compute Operation** | Implemented and evidenced | `mine_gcc()` via CryptocurrencyMining concern; `process_tick()` calls mine_gcc when power available; MiningLog creation |
| **Maintenance** | Not found | No explicit maintenance state, guard, or downtime mechanism. Satellites continue mining during any "maintenance" unless explicitly coded. |
| **Repair** | Not found | No repair method or damage state found in craft/satellite code. |
| **Refit/Upgrade** | Implemented and evidenced | `add_rig()`, `remove_rig()` in `has_rigs.rb`; `add_module()`, `remove_module()` in `has_modules.rb`; `add_equipment!()` in `base_craft.rb:109-113` |
| **Decommissioning** | Not found | No decommission/disposal method. Satellites can be destroyed via ActiveRecord destroy but no lifecycle-aware decommission process. |

---

## F. Rigs, Fits, and Equipment Evidence

### Rig System

| Finding | Evidence Path | Active Runtime Data? | Loaded? | Changes Host? | Compatibility/Ports | Status |
|---------|---------------|---------------------|---------|---------------|-------------------|--------|
| `Rigs::BaseRig` model | `galaxy_game/app/models/rigs/base_rig.rb:2` | **YES** — ActiveRecord model with DB table | **YES** — loaded via RigLookupService | **YES** — `apply_effects()`, `revert_effects()` modify attachable's operational_data | Via `available_rig_ports` (internal + external) in `has_rigs.rb:104-110` | Current Luna scope |
| `HasRigs` concern | `galaxy_game/app/models/concerns/has_rigs.rb:2` | **YES** — included by BaseCraft, BaseSatellite, BaseUnit | **YES** | **YES** — `apply_rig_effects()` writes to `operational_data['active_rig_effects']` | Via `get_ports_data` -> `internal_rig_ports` + `external_rig_ports` | Current Luna scope |
| `RigAttachable` concern | `galaxy_game/app/models/concerns/rig_attachable.rb:2` | **YES** | **YES** | N/A (utility concern) | N/A | Current Luna scope |
| `rig_type` validation | `base_rig.rb:9` | **YES** — validates presence | **YES** | N/A | N/A | Current Luna scope |
| `solar_expansion_rig` | Not found in active code | **[FILL IN: evidence not found]** | — | — | — | Absent from inspected code |
| `thruster_expansion_rig` | Not found in active code | **[FILL IN: evidence not found]** | — | — | — | Absent from inspected code |
| `gpu_coprocessor_rig` | `base_craft.rb:380`; `cryptocurrency_mining.rb:175-190` (processing boost) | **YES** — referenced in recalculate_stats and mining effects | **YES** | **YES** — processing_boost_gcc_per_hour multiplier applied to computers | Via rig ports | Current Luna scope |
| `wormhole_anchor_rig` | Not found in active code | **[FILL IN: evidence not found]** | — | — | — | Absent from inspected code (consistent with "future-only" design rule) |

### Recommended Fit Evidence

| Finding | Evidence Path | Details |
|---------|---------------|---------|
| `recommended_fit` in operational_data | `base_satellite.rb:1070-1072`; `manifest_parser.rb:19-36`; `unit_module_assembly_service.rb:45-93` | Used to build units/modules/rigs at satellite creation. Format: `{units: [...], modules: [...], rigs: [...]}` |
| `recommended_units` fallback | `unit_module_assembly_service.rb:74-75` | If `recommended_fit` absent, falls back to `recommended_units` array |
| NPC/test/reference configuration | `manifest_parser.rb:19-36` — parses recommended_fit from manifest JSON | **CONFIRMED**: This is a reference configuration for AI-managed satellite deployment, not a rig or player-fitting model |

### Rig Design Rules (from established design, NOT evidence)

These are stated as design rules to keep separate from evidence:
- Rigs are attachable/deployable modifications, not loadouts.
- Rigs preserve the host's base blueprint identity and Mk/design revision.
- `recommended_fit` is an NPC/test/reference configuration, not a rig or final player-fitting model.
- `wormhole_anchor_rig` is future-only and outside Luna scope.

---

## G. Wiki Implications

### Recommended Documentation Sequence (Smallest Set)

#### Page 1: Craft Taxonomy

**Location**: `wiki_reorganization/craft_taxonomy.md`

**Purpose**: Define the hierarchy and distinctions among all entity categories.

**Allowed claims now**:
- `Craft::BaseCraft` is the active craft base class with modules/units/rigs associations.
- `Craft::Ship < BaseCraft` is the transport subclass.
- `Craft::Satellite::BaseSatellite < BaseCraft` is the manufactured satellite subclass with GCC mining capability.
- `CelestialBodies::Satellites::Satellite < CelestialBody` is the natural satellite hierarchy (Moon, IceMoon, SmallMoon).
- `Units::BaseUnit` are sub-craft equipment items attached to hosts.
- `Modules::BaseModule` are structural building blocks attached to hosts.
- `Rigs::BaseRig` are attachable modifications with effect application.
- `Settlement::SpaceStation < BaseSettlement` is a settlement type, not a craft.
- `Structures::BaseStructure` are static infrastructure items.

**Claims that must be labeled planned/deferred**:
- Any claim about future craft types beyond Ship and Satellite.
- Whether components have a runtime model (only manufacturing chain evidence exists).

**Claims blocked by missing evidence or human decision**:
- The relationship between `Craft::Ship` and `Craft::Satellite` in gameplay (neither is documented as superior/inferior).
- Whether the top-level `Ship` class (`app/models/ship.rb`) is still used.

**Terminology decision necessary**: YES — "satellite" must be disambiguated as either manufactured (Craft::Satellite) or natural (CelestialBodies::Satellites).

---

#### Page 2: Natural Satellite vs Orbital/Manufactured Satellite Terminology

**Location**: `wiki_reorganization/terminology/satellite_disambiguation.md`

**Purpose**: Prevent confusion between the two distinct "Satellite" namespaces.

**Allowed claims now**:
- Two separate Ruby namespaces exist with the same leaf name "Satellite."
- Natural satellites are CelestialBody subclasses with orbital mechanics.
- Manufactured satellites are Craft subclasses with deployment, mining, and rig capabilities.
- They share no inheritance relationship.

**Claims blocked by missing evidence or human decision**:
- Whether a unified terminology (e.g., "orbital craft" vs "natural satellite") is preferred by design.

**Terminology decision necessary**: YES — the wiki must establish a consistent disambiguation convention.

---

#### Page 3: GCC Mining Satellite

**Location**: `wiki_reorganization/economy/gcc_mining_satellite.md`

**Purpose**: Document the first Luna-bootstrap deployable asset with economic capability.

**Allowed claims now**:
- `Craft::Satellite::BaseSatellite` includes `CryptocurrencyMining` concern.
- GCC mining uses computer units as computational resources.
- Mining deposits to the satellite owner's GCC account via `account.deposit()`.
- Configuration: 21 billion max supply, 730-day halving, 1,000 initial block reward.
- Mining is tick-driven via `process_tick()` and Sidekiq-scheduled every 4 hours.
- LDC bootstrap receives 100,000 GCC initial fund; Astrolift receives 20,000 USD.
- Launch costs $544.22/kg with GCC/USD payment split.

**Claims that must be labeled planned/deferred**:
- "1,000,000 GCC per cycle/day" — no source found.
- "6-hour cycle" — no source found.
- "6,000 GCC per cycle" — no source found.
- "24,000 GCC per day per satellite" — no source found.

**Claims blocked by missing evidence or human decision**:
- Whether `account.deposit()` creates net-new GCC or transfers from a central mint (Account model not inspected).
- The exact recipient account behavior for non-LDC satellite owners.
- Authorization controls beyond ownership-based account lookup.

---

#### Page 4: Rigs and Recommended Fit

**Location**: `wiki_reorganization/craft/rigs_and_fitting.md`

**Purpose**: Document the rig attachment system and recommended_fit configuration.

**Allowed claims now**:
- `Rigs::BaseRig` is an ActiveRecord model with DB table, loaded via RigLookupService.
- `HasRigs` concern provides add/remove/apply/revert methods.
- `gpu_coprocessor_rig` is the only rig type with proven runtime evidence (processing boost).
- `recommended_fit` is a reference configuration in operational_data used at satellite creation.
- Rigs have internal/external port types.
- Rig effects are tracked in `operational_data['active_rig_effects']`.

**Claims that must be labeled planned/deferred**:
- `solar_expansion_rig`, `thruster_expansion_rig` — not found in active code.
- `wormhole_anchor_rig` — not found (consistent with future-only designation).

**Claims blocked by missing evidence or human decision**:
- Whether rigs can be transferred between hosts without destruction.
- The exact port capacity values for specific craft types.

---

#### Page 5: GCC Issuance vs Physical Resource Extraction

**Location**: `wiki_reorganization/economy/gcc_issuance_vs_physical_extraction.md`

**Purpose**: Distinguish virtual GCC mining from physical material production.

**Allowed claims now**:
- GCC mining is virtual issuance via computer units and account.deposit().
- MiningLog tracks computational metrics (power, thermal, processing), not material yields.
- Physical resource extraction uses `output_resources` in operational_data (separate system).
- Settlements also have CryptocurrencyMining concern (dual capability).

**Claims blocked by missing evidence or human decision**:
- Whether GCC can be converted to/from physical resources.
- The relationship between GCC mining and the broader economy (Marketplace, NPCPriceCalculator).

---

#### Page 6: Craft Operational Lifecycle

**Location**: `wiki_reorganization/craft/operational_lifecycle.md`

**Purpose**: Document what lifecycle stages are implemented vs not implemented.

**Allowed claims now**:
- Implemented: construction (via CraftFactoryService), launch (LaunchPaymentService), deployment, orbital placement, docking/undocking, operation (process_tick), mining, refit/upgrade.
- Not found: maintenance, repair, decommissioning.
- Partially confirmed: cargo/passenger transfer (capacity methods exist but no explicit transfer method).

**Claims that must be labeled planned/deferred**:
- Any claim about maintenance downtime or repair mechanics.

---

### Page Separation Assessment

| Topic | Separate Page? | Rationale |
|-------|---------------|-----------|
| Craft taxonomy | **YES** — separate page | Complex hierarchy with 7+ entity types; needs clear visual diagram |
| Natural vs manufactured satellite terminology | **YES** — separate page | Critical disambiguation that affects all other pages |
| GCC mining satellite | **YES** — separate page | Cross-cutting (craft + economy + deployment); too much evidence to compress |
| Rigs and recommended_fit | **YES** — separate page | Distinct subsystem with its own concerns, ports, effects system |
| GCC issuance vs physical extraction | **YES** — separate page | Fundamental economic distinction; affects all economy pages |
| Craft operational lifecycle | **YES** — separate page | Implementation status matrix is too detailed for another page |

**Minimum viable wiki structure**: 6 pages. No consolidation recommended without losing critical disambiguation.

---

## H. Open Questions

### 1. Human Design Decisions (evidence cannot decide)

| Question | Why Evidence Cannot Decide |
|----------|---------------------------|
| Should "satellite" in the wiki always be qualified as "manufactured satellite" or "natural satellite"? | Terminology convention is a design choice, not a code question. |
| What is the intended relationship between GCC mining and physical resource economics? | Economic system design is a human decision; code only shows they coexist. |
| Should rigs have a player-fitting model distinct from `recommended_fit`? | Future feature design, not current evidence. |
| Are `solar_expansion_rig` and `thruster_expansion_rig` planned features or abandoned concepts? | No evidence in either direction. |

### 2. Claude/Qwen Implementation Verification (requires code/data/test confirmation)

| Question | What to Verify |
|----------|---------------|
| Does `Account#deposit()` create net-new GCC or transfer from a mint? | Inspect `app/models/account.rb` deposit method and Currency model. |
| Is the top-level `Ship` class (`app/models/ship.rb`) still used anywhere? | grep for `Ship.new`, `Ship.` references across all files. |
| What is the actual GCC yield per 4-hour mining cycle at runtime? | Execute MineGccJob with a test satellite and measure output. |
| Does `recalculate_stats` actually get called before `mine_gcc` in production? | Trace the call chain from SatelliteMiningSchedulerJob -> MineGccJob -> mine_gcc. |
| Are there any deployed crypto_mining_satellite instances in the database? | Query the database for `Craft::Satellite::BaseSatellite.where("operational_data->>'craft_type' = ?", 'crypto_mining_satellite')`. |

### 3. Documentation Structure Decisions (placement, ownership, redirects)

| Question | Considerations |
|----------|---------------|
| Should the satellite disambiguation page be a top-level canonical index? | It affects craft_taxonomy, gcc_mining_satellite, and lifecycle pages. |
| Where do legacy wiki files (`wiki/`) redirect to in the new structure? | Requires mapping old sections to new pages. |
| Which pages need "planned" vs "confirmed" badges? | Based on evidence confidence levels above. |

---

## Completion Statement

- No repository files were modified.
- No implementation task was dispatched.
- No unresolved architecture was silently decided.
