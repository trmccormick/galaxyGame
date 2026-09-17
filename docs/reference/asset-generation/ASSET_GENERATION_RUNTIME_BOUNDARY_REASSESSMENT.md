# Asset Generation — Runtime Boundary Reassessment

**Date**: 2026-08-28
**Purpose**: Correct the fundamental architectural assumption that the asset-generation pipeline is a Rails runtime subsystem. Establish clear boundary between development-time authoring and game runtime.
**Status**: REASSESSMENT ONLY — no code changes made.

---

## 0. PHASE 1 FILE INVENTORY & CLASSIFICATION

### 0.1 Service Files (currently in Rails)

| File | Location | Classification | Rails Dependencies |
|------|----------|---------------|-------------------|
| `profile_resolution_engine.rb` | `galaxy_game/app/services/asset_generation/` | **DEVELOPMENT TOOLING** | `GalaxyGame::Paths::DOCS_PATH` (line 222) |
| `composition_refinery.rb` | `galaxy_game/app/services/asset_generation/` | **DEVELOPMENT TOOLING** | None (pure logic) |
| `prompt_compiler.rb` | `galaxy_game/app/services/asset_generation/` | **DEVELOPMENT TOOLING** | `CatalogService` (injected), `GalaxyGame::Paths::DOCS_PATH` (line 460) |

### 0.2 Spec Files (currently in Rails)

| File | Location | Classification | Rails Dependencies |
|------|----------|---------------|-------------------|
| `profile_resolution_engine_spec.rb` | `galaxy_game/spec/services/asset_generation/` | **DEVELOPMENT TOOLING TEST** | `require 'rails_helper'` (line 3) |
| `composition_refinery_spec.rb` | `galaxy_game/spec/services/asset_generation/` | **DEVELOPMENT TOOLING TEST** | `require 'rails_helper'` (line 3) |
| `prompt_compiler_spec.rb` | `galaxy_game/spec/services/asset_generation/` | **DEVELOPMENT TOOLING TEST** | `require 'rails_helper'` (line 3), `instance_double(CatalogService)` (lines 16, 149, 185, 204) |

### 0.3 Docker Configuration (added to support Phase 1)

| File | Line | Content | Classification |
|------|------|---------|---------------|
| `docker-compose.dev.yml` | 21 | `../docs:/home/docs # Mount docs directory for GalaxyGame::Paths::DOCS_PATH` | **INCORRECT — added solely to support Phase 1** |

### 0.4 Specification / Documentation Files (in docs/ — already correct)

| File | Location | Classification |
|------|----------|---------------|
| `VISUAL_PROFILE_precision_industrial_v1.md` | `docs/reference/asset-generation/` | **SPECIFICATION** — locked attributes source of truth |
| `PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md` | `docs/reference/asset-generation/` | **SPECIFICATION** — render rules |
| `visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json` | `docs/reference/asset-generation/` | **SPECIFICATION** — asset appearance |
| `ASSET_GENERATION_*.md`, `PROFILE_COMPOSITION_SPEC.md`, `ASSET_PROMPT_COMPILER_CONTRACT.md` | `docs/reference/asset-generation/` | **SPECIFICATION** — architecture/contracts |
| `rh400_run0{3-6}_profile_composed_prompt.txt` | `docs/reference/asset-generation/` | **STATIC GENERATED ASSET** — frozen prompts |
| `ibeam_mk1_prompt_primary.txt`, `ibeam_mk1_prompt_quadrant.txt` | `docs/reference/asset-generation/` | **STATIC GENERATED ASSET** — frozen prompts |

### 0.5 Canonical Game Data (in data/ — already correct)

| File | Location | Classification |
|------|----------|---------------|
| `regolith_harvester_rover_bp.json` | `data/json-data/blueprints/crafts/ground/` | **GAME RUNTIME DATA** — blueprint |
| `regolith_harvesting_rover_data.json` | `data/json-data/operational_data/crafts/ground/` | **GAME RUNTIME DATA** — operational data |

### 0.6 Dependency Analysis

```
ProfileResolutionEngine
  ├── GalaxyGame::Paths::DOCS_PATH   ← Rails runtime dependency (WRONG for tooling)
  ├── Filesystem reads (Visual Profile markdown)  ← Correct for authoring
  └── Pure Ruby logic                ← No Rails needed

CompositionRefinery
  └── Pure Ruby logic                ← No Rails needed (already correct)

PromptCompiler
  ├── CatalogService (injected)      ← Rails runtime dependency (WRONG for tooling)
  ├── GalaxyGame::Paths::DOCS_PATH   ← Rails runtime dependency (WRONG for tooling)
  ├── Filesystem reads (Visual Definition JSON)  ← Correct for authoring
  └── Pure Ruby logic                ← No Rails needed
```

**Isolation check** (verified via grep): No controller, model, config, or other service references `asset_generation` / `AssetGeneration`. The Phase 1 services are **completely isolated** from the rest of the Rails application. Moving them out will not break any game-runtime code.

---

## 1. THE FUNDAMENTAL MISTAKE

### What Went Wrong

The Phase 1 implementation (ProfileResolutionEngine, CompositionRefinery, PromptCompiler) was placed inside `galaxy_game/app/services/asset_generation/` as if it were a **Rails runtime subsystem**. This created several cascading problems:

1. **Docker mount pressure**: Since the services read files from `docs/`, we felt compelled to mount `docs/` into the Rails container — which is architecturally wrong.
2. **Runtime coupling**: The pipeline was treated as if it needs to execute during gameplay, when its actual purpose is development-time prompt generation.
3. **Service layer confusion**: These are not application services; they are **tooling components** used by Qwen (the AI assistant) during the asset authoring workflow.

### The Correct Model

```
DEVELOPMENT-TIME AUTHORING WORKFLOW (outside Rails):

  GalaxyGame canonical data (data/)
    +
  Source specifications (docs/)
    ↓
  Qwen reads directly from filesystem
    ↓
  Profile Resolution → Composition → Prompt Compilation
    ↓
  FROZEN prompt
    ↓
  Human submits to ChatGPT/Gemini
    ↓
  Generated assets
    ↓
  Asset QA (human-automated hybrid)
    ↓
  Approved assets → Asset Registry → Game-ready files

GAME RUNTIME (inside Rails):

  Asset Registry lookup (by canonical ID)
    ↓
  Serve approved assets to game
```

**Rails does NOT need to:**
- Invoke an LLM
- Generate prompts during gameplay
- Generate images
- Communicate with ChatGPT/Gemini
- Read Visual Profiles at runtime
- Read Render Templates at runtime
- Mount the docs directory into Docker

---

## 2. WHY WAS THE PIPELINE BEING IMPLEMENTED INSIDE RAILS?

### Root Cause Analysis

The pipeline was placed inside Rails because:

1. **Proximity bias**: The canonical data lives under `data/` which is inside the Rails project structure, so it seemed natural to put the processing code alongside it.
2. **Service pattern familiarity**: GalaxyGame has a mature Lookup service architecture (`Lookup::*` services), making it tempting to add another service for asset generation.
3. **CatalogService integration**: The PromptCompiler was designed to use `CatalogService` (a Rails service), which created the illusion that the pipeline belongs in Rails.
4. **Testing convenience**: RSpec tests run inside the Rails test environment, making it easy to write specs alongside other service specs.

### Why This Was Wrong

The asset-generation pipeline is a **development-time tooling system**, not a game subsystem. Its outputs (frozen prompts) are consumed by humans who submit them to external LLMs — this happens entirely outside the game runtime. The only thing that eventually enters Rails is the **approved assets** (images, metadata), not the prompt generation process.

---

## 3. COMPONENT-BY-COMPONENT BOUNDARY ANALYSIS

### 3.1 Profile Resolution Engine

**Current location**: `galaxy_game/app/services/asset_generation/profile_resolution_engine.rb`
**What it does**: Reads Visual Profile markdown → extracts locked attributes (materials, finish, aesthetic) → resolves profile types.
**Runtime need**: NONE. This is a specification parser used during authoring.
**Correct location**: Development-time tooling — either:
- A standalone Ruby script/gem outside Rails
- Direct file reads by Qwen (current practice, which works fine)

### 3.2 Composition Refinery

**Current location**: `galaxy_game/app/services/asset_generation/composition_refinery.rb`
**What it does**: Takes structured profile attributes + Visual Definition → composes prompt sections organized by priority tier.
**Runtime need**: NONE. This is a prompt composition tool used during authoring.
**Correct location**: Development-time tooling — same as Profile Resolution Engine.

### 3.3 Prompt Compiler / Builder

**Current location**: `galaxy_game/app/services/asset_generation/prompt_compiler.rb`
**What it does**: Walks five-layer dependency chain → produces FROZEN prompt with provenance header.
**Runtime need**: NONE. This is the final authoring tool that outputs a frozen prompt for human submission to LLMs.
**Correct location**: Development-time tooling — same as above.

### 3.4 What Rails DOES Need at Runtime

| Component | Purpose | Current Implementation | Correct Location |
|-----------|---------|----------------------|------------------|
| **Asset Registry lookup** | Find approved assets by canonical ID | NOT YET IMPLEMENTED | Rails service (Lookup::AssetRegistryService) |
| **Approved asset serving** | Serve game-ready images to game client | NOT YET IMPLEMENTED | Rails controller/asset pipeline |
| **Blueprint data** | Game logic uses blueprints for craft behavior | ✅ EXISTS (CatalogService, BlueprintLookupService) | Already in Rails — correct |
| **Operational data** | Game logic uses operational data for runtime behavior | ✅ EXISTS (CatalogService, CraftLookupService) | Already in Rails — correct |

**Key insight**: The only thing the asset-generation pipeline produces that eventually enters Rails is **approved assets** (images + metadata). The prompt generation process itself never enters the game runtime.

---

## 4. WHERE SHOULD EACH COMPONENT LIVE?

### Recommended Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  DEVELOPMENT-TIME (outside Rails)                           │
│                                                             │
│  Asset Generation Tooling (standalone Ruby tool/gem)        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ Profile Resolution Engine                             │  │
│  │ Composition Refinery                                  │  │
│  │ Prompt Compiler                                       │  │
│  └───────────────────────────────────────────────────────┘  │
│         ↓ reads directly from filesystem                     │
│  GalaxyGame canonical data (data/)                           │
│  Source specifications (docs/)                               │
│         ↓ produces                                           │
│  FROZEN prompts → Human → LLM → Generated assets           │
│         ↓ stores                                             │
│  Asset Registry (approved assets metadata)                   │
└─────────────────────────────────────────────────────────────┘
                          ↓
                    APPROVED ASSETS
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  GAME RUNTIME (inside Rails)                                │
│                                                             │
│  Lookup::AssetRegistryService                               │
│    - find_approved_asset(canonical_id, render_type)         │
│    - list_render_types(canonical_id)                        │
│    - get_provenance(canonical_id)                           │
│                                                             │
│  Asset serving (controller + asset pipeline)                │
│    - GET /assets/:canonical_id/:render_type                 │
│    - GET /assets/:canonical_id/complexity/:level            │
└─────────────────────────────────────────────────────────────┘
```

### What Lives Where

| Component | Location | Reason |
|-----------|----------|--------|
| Profile Resolution Engine | Development tooling (outside Rails) | Reads source specs, produces intermediate structured data for authoring |
| Composition Refinery | Development tooling (outside Rails) | Composes prompts from specs, used only during authoring |
| Prompt Compiler | Development tooling (outside Rails) | Produces FROZEN prompts for human submission, never needed at runtime |
| Asset Registry lookup | Rails service | Game needs to find approved assets by canonical ID |
| Approved asset serving | Rails controller + asset pipeline | Game needs to load images at runtime |
| Canonical data (blueprints, operational) | `data/` (inside project, mounted in Docker) | Both authoring and runtime consume this |
| Source specs (Visual Profiles, Definitions, Templates) | `docs/` (outside Docker) | Authoring only — never needs to be in container |

---

## 5. HOW SHOULD QWEN ACCESS CANONICAL DATA AND SPECIFICATIONS?

### Current Practice (Correct)

Qwen reads files directly from the filesystem:
- Blueprints: `data/json-data/blueprints/crafts/ground/regolith_harvester_rover_bp.json`
- Operational data: `data/json-data/operational_data/crafts/ground/regolith_harvesting_rover_data.json`
- Visual Definitions: `docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json`
- Visual Profiles: `docs/reference/asset-generation/VISUAL_PROFILE_precision_industrial_v1.md`
- Render Templates: `docs/reference/asset-generation/PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0.md`

This works perfectly because Qwen operates on the host filesystem, not inside Docker. **No Rails service is needed for this.**

### What Should NOT Change

Qwen should continue to read canonical data and specifications directly from the filesystem. The Lookup services (BlueprintLookupService, CatalogService, etc.) are for **game runtime** — they load data that the game needs during gameplay. They are not a substitute for Qwen's direct file access during authoring.

---

## 6. DOES ANY EXISTING RAILS SERVICE NEED MODIFICATION?

### No Changes Needed to Existing Services

| Existing Service | Needs Modification? | Reason |
|-----------------|--------------------|--------|
| `Lookup::BlueprintLookupService` | NO | Correctly serves blueprint data at runtime |
| `Lookup::CraftLookupService` | NO | Correctly serves craft operational data at runtime |
| `CatalogService` | NO | Correctly aggregates blueprints + operational data for runtime |
| All other Lookup services | NO | Unrelated to asset generation |

### What DOES Need to Be Built (Future)

A new Rails service: `Lookup::AssetRegistryService` — but this is a **runtime lookup service** that reads approved asset metadata, NOT the prompt generation pipeline. It would:

```ruby
module Lookup
  class AssetRegistryService < BaseLookupService
    # Find an approved asset by canonical ID and render type
    def find_approved_asset(canonical_id, render_type:)
      # Read from approved assets registry (JSON or DB)
    end

    # List all render types for a canonical asset
    def list_render_types(canonical_id)
      # Return available render variants
    end

    # Get provenance metadata for an approved asset
    def get_provenance(canonical_id)
      # Return blueprint version, prompt version, QA status, etc.
    end
  end
end
```

This service reads from the **Asset Registry** (approved assets), not from source specifications. It is fundamentally different from the PromptCompiler.

---

## 7. WHAT SHOULD THE EVENTUAL ASSET REGISTRY CONTAIN?

The Asset Registry stores metadata about **approved, game-ready assets** — not the prompt generation process.

```json
{
  "canonical_id": "VEHICLE_HARVESTER_ROVER_RH400",
  "render_types": {
    "catalog": {
      "image_path": "app/assets/images/crafts/ground/regolith_harvester_rover_catalog.png",
      "prompt_version": 1,
      "prompt_provenance": {
        "blueprint_version": "2.1",
        "visual_profile": "precision_industrial_v1",
        "visual_definition": "VEHICLE_HARVESTER_ROVER_RH400",
        "render_template": "PRODUCTION_ASSET_RENDER_TEMPLATE_V1.0",
        "generated_at": "2026-08-28T...",
        "generator": "ChatGPT"
      },
      "qa_status": "approved",
      "qa_date": "2026-08-28",
      "complexity_levels": ["L0", "L1", "L2", "L3", "L4", "L5"]
    }
  },
  "blueprint_version": "2.1",
  "status": "active"
}
```

**Key distinction**: The Asset Registry stores **approved outputs**, not **generation inputs**. It is a lookup table for the game runtime to find game-ready assets.

---

## 8. CLEAN BOUNDARY DEFINITION

### Development-Time Asset Authoring (outside Rails)

```
INPUT:
  - GalaxyGame canonical data (data/) — source of truth
  - Source specifications (docs/) — Visual Profiles, Definitions, Templates

PROCESS:
  - Qwen reads files directly from filesystem
  - Profile Resolution Engine (tooling) parses specs
  - Composition Refinery (tooling) composes prompt sections
  - Prompt Compiler (tooling) produces FROZEN prompt

OUTPUT:
  - FROZEN prompt → Human → LLM → Generated assets
  - Approved assets → Asset Registry (metadata only)
```

### Game Runtime Asset Consumption (inside Rails)

```
INPUT:
  - Asset Registry (approved assets metadata)
  - Approved asset files (images, etc.)

PROCESS:
  - Lookup::AssetRegistryService.find_approved_asset(canonical_id, render_type:)
  - Rails serves approved assets to game client

OUTPUT:
  - Game-ready assets loaded by player
```

### The Boundary Line

```
                    ┌─────────────────────────────┐
                    │   DEVELOPMENT-TIME          │
                    │                             │
                    │  Canonical data (data/)     │──→ Source of truth for BOTH phases
                    │  Source specs (docs/)       │──→ Authoring only
                    │  Profile Resolution         │──→ Tooling, not runtime
                    │  Composition Refinery       │──→ Tooling, not runtime
                    │  Prompt Compiler            │──→ Tooling, not runtime
                    │  FROZEN prompt              │──→ Output of authoring
                    │  LLM generation             │──→ External to both
                    │  Asset QA                   │──→ Human-automated hybrid
                    │  Asset Registry (metadata)  │──→ Bridge between phases
                    └──────────────┬──────────────┘
                                   │
                                   ▼ approved assets
                    ┌─────────────────────────────┐
                    │   GAME RUNTIME              │
                    │                             │
                    │  Asset Registry lookup      │──→ Find approved assets
                    │  Asset serving              │──→ Serve to game client
                    │  Game logic (blueprints)    │──→ Existing services, unchanged
                    └─────────────────────────────┘
```

---

## 9. RECOMMENDED ARCHITECTURE

### What Remains in `docs/`

- Visual Definitions (JSON) — source specifications for authoring
- Visual Profiles (markdown) — source specifications for authoring
- Render Templates (markdown) — source specifications for authoring
- Architecture documents, validation reports, experiment artifacts

**These are authoring-only. Never mounted into Docker.**

### What Belongs in `data/`

- Blueprints (JSON) — canonical data for both authoring and runtime
- Operational data (JSON) — canonical data for both authoring and runtime
- Schema definitions (JSON) — validation specs for both phases
- **Future: Asset Registry metadata** (JSON or DB) — approved assets lookup

### What Is Authoritative

| Data Type | Authoritative Source | Derived Representation |
|-----------|---------------------|----------------------|
| Blueprint geometry/dimensions | `data/json-data/blueprints/` | Game runtime via CatalogService |
| Operational behavior | `data/json-data/operational_data/` | Game runtime via CatalogService |
| Visual appearance specs | `docs/reference/asset-generation/` | Authoring tooling (Profile Resolution) |
| Render rules | `docs/reference/asset-generation/` | Authoring tooling (Composition Refinery) |
| Approved assets | Asset Registry (future) | Game runtime via Lookup::AssetRegistryService |

**No duplication.** Each data type has exactly one authoritative source.

### Whether Compilation/Materialization Is Needed

**Not for Phase 1.** The current approach of Qwen reading source specifications directly is correct and efficient. A compilation/materialization step would be a future optimization if:
- Source specs become too numerous to read efficiently
- Specs need versioned releases independent of the repository
- Non-Ruby tooling needs to consume specs

For now, direct file reads are the simplest and most maintainable approach.

### Where `GalaxyGame::Paths` Participates

| Context | Uses GalaxyGame::Paths? | Why |
|---------|----------------------|-----|
| Game runtime services (Lookup::*) | YES | Need canonical paths to `data/` |
| Development tooling (Qwen) | NO | Reads directly from filesystem |
| Future Asset Registry service | YES | Needs path to registry storage |

**GalaxyGame::Paths is for game runtime, not authoring tooling.**

### What the Rails Runtime Actually Consumes

1. **Approved assets** (images, metadata) — via Lookup::AssetRegistryService (future)
2. **Blueprint data** — via existing CatalogService/BlueprintLookupService (already implemented)
3. **Operational data** — via existing CatalogService/CraftLookupService (already implemented)

**Rails does NOT consume:**
- Visual Profiles
- Visual Definitions
- Render Templates
- Prompt generation output (FROZEN prompts are authoring artifacts, not runtime data)

### How Docker Should Access the Data

**Current Docker mounts (correct):**
- `data/json-data/` → mounted into container (game runtime needs canonical data)
- `galaxy_game/` → mounted into container (Rails application code)

**Should NOT be mounted:**
- `docs/` — authoring-only, never needed at runtime
- `docs/reference/asset-generation/` — authoring-only source specifications

### What Phase 1 Needs to Change

#### Immediate Phase 1 Fix (necessary now)

1. **Move Phase 1 services out of Rails**: Move `galaxy_game/app/services/asset_generation/` to a standalone location:
   - Option A: `tools/asset_generation/` (Ruby scripts/gem outside Rails)
   - Option B: Keep as specification documents only, no implementation in Rails
   
2. **Remove CatalogService dependency**: The PromptCompiler should not depend on CatalogService. It reads source specs directly during authoring.

3. **Fix test architecture**: Phase 1 tests should not run inside `rails_helper` (which boots Rails). They should be standalone Ruby tests or Rake tasks.

#### Future Architectural Improvement (not necessary now)

1. Build `Lookup::AssetRegistryService` for game runtime asset lookup
2. Store approved assets metadata in a dedicated location (JSON file or database)
3. Create asset serving controller for game client access

**Do not implement the future improvement until Phase 1 is restructured.**

---

## 10. SUMMARY OF CORRECTED ARCHITECTURE

### Before (Incorrect — Current State)

```
docs/ ──mounted──→ Docker/Rails ──→ ProfileResolutionEngine ──→ CompositionRefinery ──→ PromptCompiler
                                                                                          ↓
                                                                                    FROZEN prompt
                                                                                          ↓
                                                                                    ChatGPT/Gemini
                                                                                          ↓
                                                                                  Generated assets
```

**Problems:**
- `docs/` mounted into Docker (unnecessary, wrong boundary)
- Authoring tooling inside Rails (wrong layer)
- PromptCompiler depends on CatalogService (coupling authoring to runtime)
- Tests run in Rails environment (unnecessary overhead)

### After (Correct — Recommended)

```
docs/ ──(host filesystem)──→ Qwen reads directly
data/ ──mounted──→ Docker/Rails ──→ Lookup::AssetRegistryService (future)
         ↓ mounted
    GalaxyGame runtime services (CatalogService, BlueprintLookupService, etc.)

Authoring workflow (outside Rails):
  docs/ + data/ ──Qwen reads──→ Profile Resolution → Composition → Prompt Compiler ──→ FROZEN prompt
                                                                                          ↓
                                                                                    ChatGPT/Gemini
                                                                                          ↓
                                                                                  Generated assets
                                                                                          ↓
                                                                              Asset Registry (metadata)
```

**Benefits:**
- `docs/` never mounted into Docker
- Authoring tooling clearly separated from game runtime
- No coupling between PromptCompiler and CatalogService
- Tests run as standalone Ruby, not inside Rails
- Clean boundary between development-time and game runtime

---

## 11. IMMEDIATE NEXT STEPS

### Stop (do now)
- [x] Pause Phase 1 implementation
- [x] Identify the fundamental architectural mistake
- [x] Produce this reassessment document

### Do Next (before any more code)
1. **Move Phase 1 services out of Rails** — to `tools/asset_generation/` or keep as specification documents only
2. **Remove CatalogService dependency** from PromptCompiler
3. **Fix test architecture** — standalone Ruby tests, not rails_helper

### Future (after restructure)
1. Build `Lookup::AssetRegistryService` for game runtime
2. Store approved assets metadata
3. Create asset serving controller

---

**END OF REASSESSMENT**
