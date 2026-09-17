# Asset Generation — Lookup Architecture Audit

**Date**: 2026-08-27
**Purpose**: Complete audit of GalaxyGame's existing JSON lookup/data-access architecture to determine correct integration boundary for the asset-generation pipeline.
**Status**: AUDIT ONLY — no code changes made.

---

## 1. EXECUTIVE SUMMARY

GalaxyGame has a **mature, well-established JSON lookup architecture** with:

- **`GalaxyGame::Paths`** — centralized path configuration (single source of truth)
- **`Lookup::*` services** — 10+ domain-specific lookup services inheriting from `BaseLookupService`, each with class-level caching
- **`CatalogService`** — a high-level aggregation service that loads blueprints + operational data and provides cross-domain query capabilities

**Critical finding**: The current Phase 1 implementation (Profile Resolution Engine, Composition Refinery, Prompt Compiler) contains **hard-coded Docker paths, host paths, and duplicated JSON loading logic** that directly contradicts the established architecture.

**Recommendation**: The asset-generation pipeline should consume data through **CatalogService** (for blueprints + operational data) and **direct file reads via GalaxyGame::Paths constants** (for Visual Definitions, Visual Profiles, Render Templates). It should NOT implement its own JSON loading or path resolution.

---

## 2. EXISTING LOOKUP/DATA ARCHITECTURE

### 2.1 Architecture Overview

```
GalaxyGame::Paths (centralized path configuration)
        ↓
┌─────────────────────────────────────────────────────┐
│              Lookup::* Services                      │
│                                                      │
│  Each service:                                       │
│  - Inherits from BaseLookupService                   │
│  - Has class-level cache (@data_cache / @*_cache)    │
│  - Loads JSON files via Dir.glob + File.read         │
│  - Exposes find_* methods                            │
│  - Uses GalaxyGame::Paths for path resolution        │
└──────────────────────┬──────────────────────────────┘
                       ↓
              CatalogService (aggregation layer)
                       ↓
              Canonical Parsed Data
```

### 2.2 All Lookup Services Inventory

| Service | File Path | Status | JSON Domain | Uses GalaxyGame::Paths? | Caching |
|---------|-----------|--------|-------------|------------------------|---------|
| `Lookup::BaseLookupService` | `galaxy_game/app/services/lookup/base_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Base class for all lookups | Yes (via `Rails.root.join('app', 'data')`) | Class-level `@data_cache` |
| `Lookup::BlueprintLookupService` | `galaxy_game/app/services/lookup/blueprint_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Blueprints (components, units, modules, rigs, facilities, items, structures, crafts) | Yes (`GalaxyGame::Paths::JSON_DATA`) | Class-level `@blueprints_cache` |
| `Lookup::CraftLookupService` | `galaxy_game/app/services/lookup/craft_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Craft operational data (atmospheric, ground, space) | Yes (`GalaxyGame::Paths::CRAFTS_PATH`) | Class-level `@crafts_cache` |
| `Lookup::UnitLookupService` | `galaxy_game/app/services/lookup/unit_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Unit operational data | Yes | Class-level cache |
| `Lookup::ModuleLookupService` | `galaxy_game/app/services/lookup/module_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Module operational data | Yes | Class-level cache |
| `Lookup::StructureLookupService` | `galaxy_game/app/services/lookup/structure_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Structure operational data | Yes | Class-level cache |
| `Lookup::RigLookupService` | `galaxy_game/app/services/lookup/rig_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Rig operational data | Yes | Class-level cache |
| `Lookup::ItemLookupService` | `galaxy_game/app/services/lookup/item_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Item data | Yes | Class-level cache |
| `Lookup::MaterialLookupService` | `galaxy_game/app/services/lookup/material_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Material/fuel/chemical resources | Yes (`GalaxyGame::Paths::MATERIALS_PATH`) | Class-level cache |
| `Lookup::StarSystemLookupService` | `galaxy_game/app/services/lookup/star_system_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Star system data | Yes | Class-level cache |
| `Lookup::LogisticsLookupService` | `galaxy_game/app/services/lookup/logistics_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Logistics data | Yes | Class-level cache |
| `Lookup::PlanetaryGeologicalFeatureLookupService` | `galaxy_game/app/services/lookup/planetary_geological_feature_lookup_service.rb` | ✅ IMPLEMENTED + TESTED | Geological features | Yes | Class-level cache |
| `Lookup::EarthReferenceService` | `galaxy_game/app/services/lookup/earth_reference_service.rb` | ✅ IMPLEMENTED + TESTED | Earth reference data | Yes | Class-level cache |
| `Lookup::LegacyPortAdapter` | `galaxy_game/app/services/lookup/legacy_port_adapter.rb` | ✅ IMPLEMENTED + TESTED | Legacy port data (extends BlueprintLookupService) | Inherits from BlueprintLookupService | Inherits cache |

**Total: 14 Lookup services** (1 base class + 13 domain-specific services).

### 2.3 Common Pattern Across All Lookup Services

Every Lookup service follows this pattern:

```ruby
module Lookup
  class SomeLookupService < BaseLookupService
    # Class-level cache (per-service)
    def self.some_cache
      @some_cache ||= load_some_class
    end

    def self.reset_cache!
      @some_cache = nil
    end

    # Path resolution via GalaxyGame::Paths
    def self.base_path
      Pathname.new(GalaxyGame::Paths::SOME_PATH)
    end

    # Domain-specific path constants
    SOME_PATHS = {
      category: {
        path: -> { base_path.join("subcategory") },
        recursive_scan: true
      }
    }

    def initialize
      @data = self.class.some_cache
    end

    def find_something(query)
      # Exact match → name match → partial match
    end
  end
end
```

**Key architectural principles**:
1. **Centralized paths**: All services use `GalaxyGame::Paths` constants, never hard-coded paths
2. **Class-level caching**: Each service has its own class-level cache, loaded once per process lifetime
3. **Base class inheritance**: All inherit from `BaseLookupService` which provides `load_json_file`, `cache_result`, etc.
4. **Graceful degradation**: Missing directories produce warnings, not errors
5. **Test environment handling**: Base class skips validation in test env

---

## 3. GALAXYGAME::PATHS AUDIT

### 3.1 Current Path Configuration

**File**: `galaxy_game/config/initializers/game_data_paths.rb`

**Root data path**:
```ruby
JSON_DATA = if ENV['GALAXY_JSON_DATA_PATH']
  Pathname.new(ENV['GALAXY_JSON_DATA_PATH']).freeze
else
  RAILS_ROOT.join('app', 'data').freeze
end
```

**Key paths defined**:
| Constant | Path | Purpose |
|----------|------|---------|
| `JSON_DATA` | `RAILS_ROOT/app/data` | Root for all JSON data |
| `TEMPLATE_PATH` | `JSON_DATA/templates` | Template files |
| `DOCS_PATH` | `RAILS_ROOT/../docs` | Documentation |
| `UNITS_PATH` | `JSON_DATA/operational_data/units` | Unit operational data |
| `MODULES_PATH` | `JSON_DATA/operational_data/modules` | Module operational data |
| `RIGS_PATH` | `JSON_DATA/operational_data/rigs` | Rig operational data |
| `STRUCTURES_PATH` | `JSON_DATA/operational_data/structures` | Structure operational data |
| `CRAFTS_PATH` | `JSON_DATA/operational_data/crafts` | Craft operational data |
| `RESOURCES_PATH` | `JSON_DATA/resources` | Resource materials/fuels |
| `MATERIALS_PATH` | `RESOURCES_PATH/materials` | Material definitions |
| `BLUEPRINTS_PATH` | `JSON_DATA/blueprints` | Blueprint files |

### 3.2 Missing Paths for Asset-Generation Data

**Gaps identified**:

| Data Type | Path Needed | Currently Defined? |
|-----------|-------------|-------------------|
| **Visual Definitions** | `docs/reference/asset-generation/visual_definitions/` | ❌ NO — stored in docs/, not JSON_DATA |
| **Visual Profiles** | `docs/reference/asset-generation/` | ❌ NO — stored in docs/, not JSON_DATA |
| **Render Templates** | `docs/reference/asset-generation/` | ❌ NO — stored in docs/, not JSON_DATA |

**Why these are missing**: Visual Definitions, Visual Profiles, and Render Templates are **markdown/specification documents**, not operational JSON data. They live in `docs/reference/asset-generation/`, which is intentionally separate from `JSON_DATA`.

**Recommendation**: These should be accessed via `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')` or a new constant like `ASSET_GENERATION_DOCS_PATH = DOCS_PATH.join('reference', 'asset-generation').freeze`.

### 3.3 Path Resolution Pattern

All paths use this pattern:
```ruby
Pathname.new(GalaxyGame::Paths::SOME_CONSTANT)
# OR
RAILS_ROOT.join('app', 'data')  # for JSON_DATA itself
```

**No service hard-codes filesystem paths.** All path resolution flows through `GalaxyGame::Paths`.

---

## 4. BLUEPRINT LOOKUP AUDIT

### 4.1 Lookup::BlueprintLookupService

**File**: `galaxy_game/app/services/lookup/blueprint_lookup_service.rb`

**Status**: ✅ IMPLEMENTED + TESTED

**Responsibilities**:
- Loads ALL blueprint JSON files from 8 categories (components, units, modules, rigs, facilities, items, structures, crafts)
- Provides `find_blueprint(query, category)` method
- Provides `all_blueprints` and `blueprints_by_category(category)` methods
- Class-level caching via `@blueprints_cache`

**Path resolution**: Uses `GalaxyGame::Paths::JSON_DATA.join("blueprints")` as base path.

**Cache behavior**: Loads once per process lifetime via `self.blueprints_cache`. Reset via `self.reset_cache!`.

**Public interface**:
```ruby
find_blueprint(query, category = nil)  # Returns single blueprint or nil
all_blueprints                          # Returns all blueprints array
blueprints_by_category(category)        # Returns filtered array
reset_cache!                            # Resets class-level cache
```

**Major callers**: Used throughout the codebase for blueprint lookups. Referenced in `structures_assembly_validation.rake` and many services.

### 4.2 What BlueprintLookupService Does NOT Own

- Operational data (handled by CatalogService)
- Visual Definitions (no lookup service exists)
- Visual Profiles (no lookup service exists)
- Render Templates (no lookup service exists)
- Cross-domain queries (handled by CatalogService)

---

## 5. OTHER LOOKUP SERVICES AUDIT

### 5.1 Lookup::CraftLookupService

**File**: `galaxy_game/app/services/lookup/craft_lookup_service.rb`

**Status**: ✅ IMPLEMENTED + TESTED

**Responsibilities**:
- Loads craft operational data from atmospheric/ground/space subdirectories
- Provides `find_craft(craft_type)` method with exact ID → exact name → partial match fallback
- Class-level caching via `@crafts_cache`

**Path resolution**: Uses `GalaxyGame::Paths::CRAFTS_PATH` and subcategory paths.

### 5.2 Lookup::MaterialLookupService

**File**: `galaxy_game/app/services/lookup/material_lookup_service.rb`

**Status**: ✅ IMPLEMENTED + TESTED

**Responsibilities**:
- Loads material/fuel/chemical resource data
- Provides `find_material(query)` method
- Class-level caching via `@materials_cache`

**Path resolution**: Uses `GalaxyGame::Paths::MATERIALS_PATH`.

### 5.3 Other Lookup Services

All other Lookup services (Unit, Module, Structure, Rig, Item, StarSystem, Logistics, PlanetaryGeologicalFeature, EarthReference) follow the same pattern as CraftLookupService and MaterialLookupService:
- Inherit from `BaseLookupService`
- Have class-level cache
- Use `GalaxyGame::Paths` for path resolution
- Expose `find_*` methods

**None of these services handle asset-generation data (Visual Definitions, Visual Profiles, Render Templates).**

---

## 6. CANONICAL ASSET-GENERATION DATA ACCESS

### 6.1 Current Access Patterns for Each Canonical Source

| Canonical Source | Where Stored | How Currently Accessed | Lookup Service Exists? |
|-----------------|--------------|----------------------|----------------------|
| **Blueprint** | `JSON_DATA/blueprints/` (via GalaxyGame::Paths) | `Lookup::BlueprintLookupService.find_blueprint()` | ✅ YES |
| **Operational Data** | `JSON_DATA/operational_data/` (via GalaxyGame::Paths) | `CatalogService.find_operational_data_by_name()` | ⚠️ PARTIAL — CatalogService aggregates, no dedicated Lookup service |
| **Visual Definition** | `docs/reference/asset-generation/visual_definitions/` | Direct file read (no lookup service) | ❌ NO |
| **Visual Profile** | `docs/reference/asset-generation/` (markdown) | Direct file read (no lookup service) | ❌ NO |
| **Render Template** | `docs/reference/asset-generation/` (markdown) | Direct file read (no lookup service) | ❌ NO |

### 6.2 Why Visual Definitions/Profiles/Templates Have No Lookup Service

These are **specification documents**, not operational data:
- Visual Definitions are JSON schema instances (one per asset)
- Visual Profiles are markdown documents (reusable across assets)
- Render Templates are markdown templates (shared across assets)

They are not loaded at application startup like operational data. They are loaded on-demand when an asset is being generated. This is a different access pattern than the Lookup services, which load all data at startup.

**Recommendation**: These should be accessed via:
1. **Direct file reads** using `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')` as base path
2. **CatalogService** could potentially be extended to index these documents, but that's a future enhancement, not required for Phase 1

---

## 7. CATALOGSERVICE RELATIONSHIP

### 7.1 CatalogService Actual Role

**File**: `galaxy_game/app/services/catalog_service.rb`

**Status**: ✅ IMPLEMENTED + TESTED

**What it does**:
- Loads ALL blueprints from `GalaxyGame::Paths::BLUEPRINTS_PATH` (via Dir.glob)
- Loads ALL operational data from `JSON_DATA/operational_data/**` (via Dir.glob)
- Builds structured entry hashes with metadata (id, name, type, category, subcategory, file_path, etc.)
- Provides cross-domain query methods:
  - `find_entry(id)` — find by ID across both blueprints and operational data
  - `find_operational_data_by_name(blueprint_filename)` — cross-reference lookup
  - `find_blueprint_by_name(op_filename)` — reverse cross-reference lookup
  - `entries_for(category:, subcategory:, search:)` — filtered query builder

**What it does NOT do**:
- Does NOT load Visual Definitions, Visual Profiles, or Render Templates
- Does NOT provide blueprint-specific lookup (that's BlueprintLookupService's job)
- Does NOT provide craft/material/unit/etc. specific lookup (those are individual Lookup services)

### 7.2 Relationship Between CatalogService and Lookup Services

**CatalogService is a high-level aggregation layer**, not a replacement for Lookup services:

```
BlueprintLookupService → loads blueprints (domain-specific, class-level cache)
CraftLookupService → loads crafts (domain-specific, class-level cache)
MaterialLookupService → loads materials (domain-specific, class-level cache)
... (10+ other domain-specific Lookup services)
        ↓
CatalogService → aggregates blueprints + operational data for cross-domain queries
```

**Key distinction**:
- **Lookup services** are domain-specific, loaded at startup, with class-level caching
- **CatalogService** is a cross-domain aggregator that loads blueprints + operational data on-demand (per-request caching via `@entries`)

### 7.3 Should PromptCompiler Use CatalogService?

**YES — for blueprints and operational data.**

Rationale:
1. CatalogService already loads both blueprints AND operational data in a single pass
2. It provides cross-reference methods (`find_operational_data_by_name`, `find_blueprint_by_name`) that are exactly what the PromptCompiler needs
3. It uses `GalaxyGame::Paths` for path resolution (no hard-coded paths)
4. It has per-request caching via `@entries` (efficient for generation workflows)

**Should NOT use CatalogService for**:
- Visual Definitions — not loaded by CatalogService, stored in docs/
- Visual Profiles — markdown documents, not JSON data
- Render Templates — markdown templates, not JSON data

### 7.4 Duplication Risk Assessment

| Component | Current Phase 1 Implementation | Existing Alternative | Duplication? |
|-----------|-------------------------------|---------------------|-------------|
| Blueprint loading | PromptCompiler reads files directly | CatalogService.find_entry() + BlueprintLookupService | ✅ YES — should use CatalogService |
| Operational data loading | PromptCompiler reads files directly | CatalogService.find_operational_data_by_name() | ✅ YES — should use CatalogService |
| Visual Definition loading | Hard-coded path resolution | Direct file read via GalaxyGame::Paths::DOCS_PATH | ⚠️ PARTIAL — needs path fix, not full Lookup service |
| Visual Profile loading | Hard-coded path resolution | Direct file read via GalaxyGame::Paths::DOCS_PATH | ⚠️ PARTIAL — needs path fix, not full Lookup service |
| Render Template loading | Direct file read (correct) | Direct file read via GalaxyGame::Paths::DOCS_PATH | ✅ CORRECT — no duplication |

---

## 8. CURRENT PHASE 1 INTEGRATION

### 8.1 Profile Resolution Engine

**Current implementation**: Reads Visual Profile markdown directly via hard-coded path resolution.

**Problems identified**:
1. **Hard-coded Docker paths**: `Pathname.new('/home/docs/reference/asset-generation')` — contradicts centralized path configuration
2. **Hard-coded host paths**: `Pathname.new(File.expand_path('../../../../docs/reference/asset-generation', __dir__))` — brittle, breaks in different environments
3. **No GalaxyGame::Paths usage**: Should use `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')`

**Correct integration**:
```ruby
# Profile Resolution Engine should:
base_dir = GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')
profile_path = base_dir.join("VISUAL_PROFILE_#{visual_profile_id}.md")
content = profile_path.exist? ? profile_path.read : raise(ProfileNotFoundError, ...)
```

### 8.2 Composition Refinery

**Current implementation**: Takes structured Hash inputs, produces composed sections.

**Problems identified**:
1. **Symbol/string key inconsistency**: Visual Definition JSON uses string keys (`"visual_priority"`), but code expects symbol keys (`:visual_priority`). This is a data normalization issue.
2. **No canonical data loading**: Correct — Composition Refinery should NOT load data. It transforms already-resolved data.

**Correct integration**:
- Data normalization (symbol vs string keys) should happen at the **Lookup boundary** (CatalogService or a new adapter), not in Composition Refinery
- Composition Refinery should receive normalized Hash inputs and produce structured output

### 8.3 Prompt Compiler / Builder

**Current implementation**: Walks five-layer chain, loads data via CatalogService mock, produces FROZEN prompt.

**Problems identified**:
1. **Visual Definition loading**: Hard-coded path resolution with Docker/host fallback — should use `GalaxyGame::Paths::DOCS_PATH`
2. **Blueprint/operational data loading**: Uses CatalogService (correct), but test mocks are fragile
3. **No duplication of data loading**: Correct — uses CatalogService for blueprints + operational data

**Correct integration**:
```ruby
# Prompt Compiler should:
# 1. Load blueprint + operational data via CatalogService (CORRECT)
blueprint_entry = catalog_service.find_entry(asset_id)
ops_entry = catalog_service.find_operational_data_by_name(blueprint_filename)

# 2. Load Visual Definition via GalaxyGame::Paths (NEEDS FIX)
vd_path = GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation', 'visual_definitions', "#{asset_id.upcase}.json")
vd_data = JSON.parse(vd_path.read) if vd_path.exist?

# 3. Load Visual Profile via GalaxyGame::Paths (handled by Profile Resolution Engine)
# 4. Load Render Template via GalaxyGame::Paths (CORRECT — direct file read)
template_content = render_template_path.read
```

---

## 9. DUPLICATION/OVERLAP ANALYSIS

### 9.1 Identified Duplication

| Duplication | Existing Code | Phase 1 Code | Risk Level |
|------------|---------------|-------------|-----------|
| **Blueprint loading** | CatalogService + BlueprintLookupService | PromptCompiler reads files directly | 🔴 HIGH — should use CatalogService |
| **Operational data loading** | CatalogService | PromptCompiler reads files directly | 🔴 HIGH — should use CatalogService |
| **Path resolution** | GalaxyGame::Paths (all services) | Hard-coded Docker/host paths in Profile Resolution Engine | 🔴 HIGH — should use GalaxyGame::Paths |
| **JSON parsing** | BaseLookupService.load_json_file() | Direct File.read + JSON.parse in Profile Resolution Engine | 🟡 MEDIUM — could reuse BaseLookupService pattern |

### 9.2 No Duplication (Correctly Implemented)

| Component | Status | Notes |
|-----------|--------|-------|
| Composition Refinery | ✅ NO DUPLICATION | Transforms data, doesn't load it |
| Render Template loading | ✅ NO DUPLICATION | Direct file read is correct for templates |
| Prompt structure generation | ✅ NO DUPLICATION | New functionality, no existing equivalent |

---

## 10. RECOMMENDED INTEGRATION BOUNDARY

### 10.1 Correct Architecture

```
                 GalaxyGame::Paths
                        ↓
              ┌───────────────────────┐
              │   Existing Lookup Layer │
              │                         │
              │  BlueprintLookupService │ ← for blueprints
              │  CatalogService         │ ← for blueprints + operational data
              │  (direct file reads)    │ ← for Visual Def/Profile/Template
              └───────────────────────┘
                        ↓
                Canonical Parsed Data
                        ↓
             Profile Resolution Engine
                        ↓
              Profile Composition
                        ↓
          Refinements / Safeguards
                        ↓
                Prompt Compiler
```

### 10.2 Specific Integration Points

| Component | Should Use | Why |
|-----------|-----------|-----|
| **Blueprint loading** | `CatalogService.find_entry(asset_id)` | Already loads blueprints, uses GalaxyGame::Paths, provides cross-reference |
| **Operational data loading** | `CatalogService.find_operational_data_by_name(blueprint_filename)` | Cross-references with blueprint, uses GalaxyGame::Paths |
| **Visual Definition loading** | Direct file read via `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation', 'visual_definitions')` | Stored in docs/, not JSON_DATA; one-per-asset, not loaded at startup |
| **Visual Profile loading** | Direct file read via `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')` | Markdown document, reusable across assets |
| **Render Template loading** | Direct file read via `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')` | Markdown template, shared across assets |

---

## 11. REQUIRED PHASE 1 CORRECTIONS

### 11.1 Path Resolution (HIGH PRIORITY)

| File | Issue | Correction |
|------|-------|-----------|
| `profile_resolution_engine.rb` | Hard-coded Docker/host paths in `visual_profile_path` | Use `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation')` |
| `prompt_compiler.rb` | Hard-coded Docker/host paths in `visual_definition_path` | Use `GalaxyGame::Paths::DOCS_PATH.join('reference', 'asset-generation', 'visual_definitions')` |

### 11.2 Data Loading (HIGH PRIORITY)

| File | Issue | Correction |
|------|-------|-----------|
| `prompt_compiler.rb` | Loads blueprints/operational data directly in some code paths | Ensure ALL blueprint/operational data loading goes through CatalogService |

### 11.3 Key Normalization (MEDIUM PRIORITY)

| Component | Issue | Correction |
|-----------|-------|-----------|
| Composition Refinery | Symbol/string key mismatch with Visual Definition JSON | Normalize keys at the Lookup boundary (CatalogService or adapter), not in Composition Refinery |

### 11.4 Classification of Corrections

| Correction | Classification | Priority |
|-----------|---------------|----------|
| Fix path resolution to use GalaxyGame::Paths | REFACTOR | HIGH |
| Ensure all blueprint/ops data loading uses CatalogService | REFACTOR | HIGH |
| Normalize symbol/string keys at Lookup boundary | IMPLEMENT (adapter) | MEDIUM |
| Add GalaxyGame::Paths constants for asset-generation docs | IMPLEMENT | LOW |

---

## 12. CHANGES NOT REQUIRED

### 12.1 No New Lookup Services Needed

Visual Definitions, Visual Profiles, and Render Templates are **specification documents**, not operational data. They don't need dedicated Lookup services because:
- They're loaded on-demand (not at startup)
- They're one-per-asset or shared templates (not bulk-loaded)
- They're markdown/JSON in docs/ (not JSON_DATA/)

### 12.2 No Changes to Existing Services

| Service | Change Required? | Reason |
|---------|-----------------|--------|
| `GalaxyGame::Paths` | ❌ NO — add new constants only if needed | Existing paths are correct; new constants can be added without modifying existing ones |
| `Lookup::BlueprintLookupService` | ❌ NO | Already correct, already uses GalaxyGame::Paths |
| `Lookup::CraftLookupService` | ❌ NO | Not relevant to asset-generation pipeline |
| `CatalogService` | ❌ NO — may extend in future | Currently sufficient for Phase 1; no changes needed |
| All other Lookup services | ❌ NO | Not relevant to asset-generation pipeline |

### 12.3 No Changes to Canonical Data

- Blueprint files: NO CHANGES
- Operational data: NO CHANGES
- Visual Definitions: NO CHANGES
- Visual Profiles: NO CHANGES
- Render Templates: NO CHANGES

---

## 13. RISKS / OPEN QUESTIONS

### 13.1 Risks

| Risk | Severity | Mitigation |
|------|----------|-----------|
| **CatalogService not loaded in test env** | MEDIUM | CatalogService uses `GalaxyGame::Paths::JSON_DATA` which works in both dev and test; verify in RSpec |
| **Visual Definition file naming convention** | LOW | Current Phase 1 assumes `{ASSET_ID_UPCASE}.json`; verify this matches existing files |
| **Docker vs host path differences** | MEDIUM | Use `GalaxyGame::Paths::DOCS_PATH` which handles both via `RAILS_ROOT` |

### 13.2 Open Questions

| Question | Impact | Resolution |
|----------|--------|-----------|
| Should CatalogService be extended to index Visual Definitions? | Future enhancement | Not required for Phase 1; direct file reads are sufficient |
| Should Visual Profiles/Render Templates have their own Lookup services? | Future enhancement | Not required for Phase 1; they're shared templates, not per-asset data |
| Should GalaxyGame::Paths get new constants for asset-generation docs? | LOW | Recommended: `ASSET_GENERATION_DOCS_PATH = DOCS_PATH.join('reference', 'asset-generation').freeze` |

---

## 14. RECOMMENDED NEXT IMPLEMENTATION STEP

### Step 1: Fix Path Resolution (REFACTOR — HIGH PRIORITY)

**Files to modify**:
1. `profile_resolution_engine.rb` — replace hard-coded paths with `GalaxyGame::Paths::DOCS_PATH`
2. `prompt_compiler.rb` — replace hard-coded paths with `GalaxyGame::Paths::DOCS_PATH`

**Do NOT modify**:
- `GalaxyGame::Paths` (add new constants only if needed, don't change existing ones)
- Existing Lookup services
- CatalogService
- Canonical data files

### Step 2: Ensure CatalogService Integration (REFACTOR — HIGH PRIORITY)

**Verify**: All blueprint and operational data loading in PromptCompiler goes through CatalogService.

**Do NOT modify**:
- BlueprintLookupService
- CatalogService implementation
- Canonical data files

### Step 3: Fix Test Fixtures (IMPLEMENT — MEDIUM PRIORITY)

**Fix**: Symbol/string key normalization in tests to match actual Visual Definition JSON format.

**Do NOT modify**:
- Production architecture
- Canonical data files

### Step 4: Add GalaxyGame::Paths Constants (IMPLEMENT — LOW PRIORITY)

**Add** (if not already present):
```ruby
# In game_data_paths.rb (append, don't modify existing constants)
ASSET_GENERATION_DOCS_PATH = DOCS_PATH.join('reference', 'asset-generation').freeze
VISUAL_DEFINITIONS_PATH = ASSET_GENERATION_DOCS_PATH.join('visual_definitions').freeze
```

---

## CLASSIFICATION SUMMARY

| Component | Classification | Action |
|-----------|---------------|--------|
| GalaxyGame::Paths | EXISTING — correct, add new constants only | REUSE |
| Lookup::* services | EXISTING — correct, not relevant to asset-generation | REUSE (BlueprintLookupService for blueprints) |
| CatalogService | EXISTING — use for blueprints + operational data | REUSE |
| Profile Resolution Engine path resolution | IMPLEMENT — fix to use GalaxyGame::Paths | REFACTOR |
| Prompt Compiler data loading | IMPLEMENT — ensure uses CatalogService | REFACTOR |
| Composition Refinery key normalization | IMPLEMENT — normalize at Lookup boundary | IMPLEMENT |
| Visual Definition/Profile/Template loading | EXISTING — direct file reads via GalaxyGame::Paths | REUSE |
| New Lookup services for asset-generation data | FUTURE — not required for Phase 1 | OPTIONAL |

---

*Audit completed: 2026-08-27*
*No code changes made. No files modified.*
*Based on comprehensive audit of galaxy_game/app/services/lookup/, galaxy_game/app/services/catalog_service.rb, galaxy_game/config/initializers/game_data_paths.rb, and all Lookup service implementations.*
