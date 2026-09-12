# Visual Contract — Asset Generation

**Version**: 1.0  
**Created**: 2026-09-11  
**Status**: Canonical contract for asset generation visuals  
**Scope**: Development-time visual artifact definitions and their relationship to canonical game data

---

## 1. Purpose and Scope

This document defines the authoritative contract for **asset generation visuals** in Galaxy Game. It establishes:

- The roles of each artifact type in the asset pipeline.
- How `asset_id` serves as the shared canonical identity across all artifact types.
- The separation between canonical game data (runtime) and development-time visual artifacts.
- The PromptCompiler's public interface and its constraints.
- Format requirements for Visual Definition files.

### What This Contract Covers

- Asset Registry, Blueprint, Operational Data, Visual Definition, Visual Profile, and Render Template roles and relationships.
- `asset_id` as the shared canonical identity across all artifact types.
- PromptCompiler's public interface and input/output contract.
- Visual Definition format requirements (human-readable vs machine-readable).
- Known violations of this contract in existing files.

### What This Contract Does NOT Cover

- Runtime game logic or non-visual asset relationships.
- Migration strategies for existing files that violate this contract.
- Implementation details of PromptCompiler's internal composition pipeline.
- Visual Profile resolution mechanisms (handled by development-time orchestration).
- Render Template format specifics beyond their role as PromptCompiler inputs.

---

## 2. Canonical Identities and Roles

### `asset_id` — The Shared Canonical Identity

Every asset in Galaxy Game has a single, unique `asset_id`. This identifier is the **only** shared key across all artifact types:

- **Asset Registry**: Stores `asset_id` as the primary lookup key.
- **Blueprint**: Contains `asset_id` to identify the unit/component it defines.
- **Operational Data**: References `asset_id` to provide runtime properties for a blueprint.
- **Visual Definition**: Contains `asset_id` to define the visual appearance of an asset.
- **Visual Profile**: Contains `asset_id` to define visual composition rules (color, animation, complexity).
- **Render Template**: Contains `asset_id` to define output formats (sprite sheets, catalog renders, etc.).

**Critical**: `asset_id` is a **shared identity**, not a file path. Development-time orchestration determines which Visual Definition, Visual Profile, and Render Template apply for a given `asset_id`. No artifact searches the repository by `asset_id`.

### Artifact Roles

| Artifact | Domain | Role |
|----------|--------|------|
| **Asset Registry** | Canonical game data | Central registry mapping `asset_id` to all associated artifacts. The single source of truth for asset existence and identity. |
| **Blueprint** | Canonical game data | Defines the unit/component's physical properties, required materials, production data, cost data, and deployment characteristics. **Does NOT carry visual fields.** |
| **Operational Data** | Canonical game data | Provides runtime operational properties (power consumption, payload, range, autonomy) for a blueprint. Referenced by blueprint via `operational_data_reference`. |
| **Visual Definition** | Development-time visual artifact | Defines the visual appearance of an asset: silhouette, color profile, material profiles, recognition features, render profiles, camera profiles, complexity levels, design constraints. |
| **Visual Profile** | Development-time visual artifact | Defines visual composition rules for an asset: color schemes, animation profiles, complexity-level variants, shared components across asset families. |
| **Render Template** | Development-time visual artifact | Defines output formats and rendering parameters for an asset: sprite sheet layout, catalog render angles, engineering render styles, blueprint view specifications. |

### Separation of Concerns

```
Canonical Game Data (Runtime)          Development-Time Visual Artifacts
─────────────────────────────          ───────────────────────────────────
Asset Registry                         Visual Definition
Blueprint                              Visual Profile
Operational Data                       Render Template
                                       PromptCompiler (consumes resolved inputs)
```

**Explicit statement**: Blueprints do **not** carry `visual_profile` or `visual_definition` fields. The link between canonical game data and visual artifacts is `asset_id`, resolved by development-time orchestration.

---

## 3. PromptCompiler Contract

### Public Interface

```ruby
PromptCompiler.compile(
  asset_id:,
  blueprint_path:,
  operational_data_path:,
  visual_definition_path:,
  render_template_path:
)
```

**This is the complete and authoritative public interface.** No additional arguments are part of this contract. Any future change to the public interface is a separate implementation decision.

### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset_id` | String | The canonical shared identity across all artifact types. Used for provenance and logging, not for repository search. |
| `blueprint_path` | Path | Absolute path to the blueprint JSON file. Already resolved by orchestration. |
| `operational_data_path` | Path | Absolute path to the operational data JSON file. Already resolved by orchestration. |
| `visual_definition_path` | Path | Absolute path to the Visual Definition file (raw JSON or Markdown-extracted JSON). Already resolved by orchestration. |
| `render_template_path` | Path | Absolute path to the Render Template file. Already resolved by orchestration. |

### Key Constraints

1. **PromptCompiler consumes already-resolved inputs.** It does **not** search the repository by `asset_id`. All paths are provided by development-time orchestration.

2. **Visual Profile resolution is handled by development-time orchestration, NOT by the PromptCompiler public API.** The compiler does not accept a `visual_profile_path:` argument. Any future change to add Visual Profile resolution to the public interface is a separate implementation decision after this contract is established.

3. **Output**: A frozen image prompt string for image-generation models, composed from profile attributes, visual definition data, blueprint data, and operational data according to the internal composition pipeline.

---

## 4. Visual Definition Format Contract

### Human-Readable Visual Definition (`.md`)

- Format: Markdown document with optional YAML frontmatter and embedded JSON code block.
- Purpose: Designer-friendly authoring and review. The prose sections are for human consumption; the embedded JSON is machine-parseable after extraction.
- Example structure:
  ```
  ---
  date_created: YYYY-MM-DD
  type: VISUAL_DEFINITION_INSTANCE
  status: active
  asset_id: ASSET_ID_HERE
  blueprint_ref: blueprint_identifier
  purpose: Brief description
  ---

  # Visual Definition — [Asset Name]

  **Asset ID**: `ASSET_ID_HERE`
  **Blueprint Reference**: `blueprint_identifier`

  ## Structured Data

  ```json
  { "visual_definition": { ... } }
  ```
  ```

### Machine-Readable Visual Definition (`.json`)

- Format: Raw, valid JSON. No Markdown, no YAML frontmatter, no embedded code blocks.
- Purpose: Direct machine consumption by tooling that expects a single JSON parse.
- **Explicit statement**: Any file named `*.json` must be valid JSON when parsed directly. If a file contains Markdown or YAML, it must use the `.md` extension.

### Format Selection Guidance

| Use Case | Recommended Format | Extension |
|----------|-------------------|-----------|
| Designer authoring/review | Markdown + YAML frontmatter + embedded JSON | `.md` |
| Tooling consumption (direct parse) | Raw valid JSON | `.json` |
| Canonical reference / schema compliance | Raw valid JSON | `.json` |

**Explicit statement**: Markdown-wrapped Visual Definitions must **not** use the `.json` extension. The extension must accurately reflect the file's parseable format.

---

## 5. Known Violations and Migration

### Current Violations

The following existing files violate this contract:

| File | Violation |
|------|-----------|
| `docs/reference/asset-generation/visual_definitions/VEHICLE_HARVESTER_ROVER_RH400.json` | Named `.json` but contains Markdown + YAML frontmatter + embedded JSON. Direct `JSON.parse` on the file will fail. |

### Migration Policy

- Files that violate this contract require migration to comply with the format requirements above.
- **Migration strategy is a separate task.** This contract does not prescribe how existing files should be migrated (e.g., renaming extensions, generating derivative formats, updating tooling references).
- Migration decisions should consider: impact on existing tooling, backward compatibility, and whether the migration can be done incrementally.

---

## 6. Boundaries and Non-Goals

### Boundaries

- **Asset-generation tooling is development-time infrastructure** outside the Rails runtime. It operates independently of game simulation logic.
- **Qwen (or any orchestration agent) is a consumer of this tooling**, not its owner. Orchestration resolves `asset_id` to artifact paths; it does not define the contract.
- **RH-400 is a fixture/example**, not an architectural dependency. The contract applies universally, not just to RH-400 or vehicle assets.

### Non-Goals

- Defining runtime game logic for visual asset usage (e.g., how sprites are rendered in-game).
- Specifying image-generation model parameters beyond the prompt format PromptCompiler outputs.
- Migrating existing files that violate this contract (see Section 5).
- Defining Visual Profile resolution mechanisms (handled by development-time orchestration).

---

## 7. Dependency Map

This contract is a prerequisite for:

1. **PromptCompiler/input-contract implementation decisions** — The corrected public interface defines the target; any PromptCompiler adjustments must conform to this contract.
2. **RH-400 Visual Definition migration/normalization** — The format contract (Section 4) defines the target state for existing violations.
3. **Standalone asset-generation execution verification** — A stable visual contract is required before implementation work can proceed against a known interface.

---

## Appendix A: Glossary

| Term | Definition |
|------|-----------|
| `asset_id` | Unique canonical identifier shared across all artifact types for a given asset. |
| Asset Registry | Central registry mapping `asset_id` to all associated artifacts. |
| Blueprint | Canonical game data defining physical properties, materials, production, and cost. |
| Operational Data | Canonical game data providing runtime operational properties for a blueprint. |
| Visual Definition | Development-time visual artifact defining appearance (silhouette, color, materials, features). |
| Visual Profile | Development-time visual artifact defining composition rules (color schemes, animation, complexity). |
| Render Template | Development-time visual artifact defining output formats (sprite sheets, catalog renders). |
| PromptCompiler | Tool that consumes resolved artifact inputs and produces frozen image prompts for generation models. |
| Development-time orchestration | The process of resolving `asset_id` to specific artifact paths; handles Visual Profile resolution. |

---

*This document is the canonical contract for asset generation visuals in Galaxy Game. It was established 2026-09-11 based on architectural decisions from the RH-400 visual-profile/contract audit and multi-agent consensus.*
