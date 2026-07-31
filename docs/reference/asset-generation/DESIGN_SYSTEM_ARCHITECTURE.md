---
date_created: 2026-07-19
type: SYSTEM_OVERVIEW
status: active
purpose: Show complete design system architecture
---

# GalaxyGame Design System Architecture

**Context**: Evolved from individual sprite generation → reproducible asset pipeline (identified by ChatGPT, July 19, 2026)

---

## Design System Hierarchy

```
Level 0: PHILOSOPHY
├─ VISUAL_PHILOSOPHY.md
│  (Why? What should it feel like?)
│  - 9 core principles: Grounded, Functional, Progressive, Modular, Industrial, 
│    Human, Simulation-First, Location-Agnostic, Consistency
│  - Answers fundamental design questions
│  - Drives all downstream decisions

Level 1: FRAMEWORK
├─ Icon Bible (2026-07-19-HIGH-DESIGN-GALAXYGAME_ICON_BIBLE.md)
│  (How should each category look?)
│  - Asset hierarchy (Resources, Items, Equipment, Structures, Vehicles, etc.)
│  - Color families + Shape language
│  - Material library + Lighting rules
│  - Tech level progression (Mk1-Mk5)
│  - Animation language
│  - Damage states
│  - Visual complexity levels (L0-L5)
│  - Prompt templates
│  - 11-step production pipeline
│
├─ Asset Registry Specification (2026-07-19-HIGH-DESIGN-ASSET_REGISTRY_SPECIFICATION.md)
│  (What assets exist?)
│  - Canonical list of 250+ planned assets
│  - Asset ID format
│  - Category organization
│  - Growing throughout development

Level 2: SPECIFICATION
├─ Design Research Index (DESIGN_RESEARCH_INDEX.md)
│  (Which research session covers this?)
│  - Maps 10 ChatGPT sessions to asset types
│  - Priority-ordered 16-task generation workflow
│  - Cross-session themes
│
└─ Research Session Files (10 files)
   (Detailed specifications for each domain)
   - Session 1: Architecture patterns
   - Session 2: Catalog render standards ⭐
   - Session 3: Terrain/biome organization ⭐
   - Session 4: Vehicle variant architecture
   - Session 5: Visual identity + branding
   - Session 6: Manufacturing methods ⭐
   - Session 7: Corporate ecosystem
   - Session 8: Component render specs ⭐
   - Session 9: Prompt templates ⭐
   - Session 10: Biome compression ⭐

Level 3: REFERENCE
├─ UNIFIED_ASSET_CATALOG_ARCHITECTURE.md
│  (How to organize canonically?)
│  - Location-agnostic naming principle
│  - Resource categorization
│  - Implementation rules
│  - Migration path
│
└─ Existing Design Guidance
   - PHASE1-CRITICAL-PATH.md
   - And other project documentation
```

---

## Asset Generation Pipeline

```
PHILOSOPHY LAYER
    ↓
FRAMEWORK LAYER (Icon Bible + Registry)
    ↓
SPECIFICATION LAYER (Research Index + Sessions)
    ↓
GENERATION WORKFLOW
│
├─ Step 1: Define Resource
│   (Add JSON definition with canonical ID)
│   Input: Resource JSON
│   Output: Canonical registry entry
│
├─ Step 2: Reference Specifications
│   (Find relevant research sessions)
│   Input: Asset type (Component, Resource, Unit, etc.)
│   Output: Session references + detailed specs
│
├─ Step 3: Generate Prompt
│   (Fill parametric template from specifications)
│   Input: Specifications + blueprint data
│   Output: Structured prompt (5-10 variables)
│
├─ Step 4: Generate Asset
│   (AI image generation using prompt)
│   Input: Structured prompt
│   Output: Asset image(s)
│
├─ Step 5: Validate Against Philosophy
│   (Review for grounded, functional, progressive, etc.)
│   Input: Generated asset
│   Output: Approved or rejected
│
├─ Step 6: Store in Asset Library
│   (Register with canonical ID)
│   Input: Validated asset
│   Output: Asset library entry + sprite sheets
│
└─ Step 7: Reference in Gameplay
    (Available for use everywhere)
    Input: Canonical asset ID
    Output: Consistent visual in game

RESULT: New asset, generated in minutes, consistent with all others
```

---

## Why This Matters

### Before (Asset-First Approach)
- Create individual sprites
- Manually ensure consistency
- Each new location = new assets
- Every tech level = separate designs
- Adding new resources = redo existing assets to match

**Problem**: Doesn't scale. Hundreds of variants impossible.

### After (Architecture-First Approach)
- Define asset once in JSON
- Architecture generates all variants
- Location changes = JSON metadata only
- Tech level changes = parameters only
- New resources = automatic variant generation

**Solution**: Scales infinitely. 300+ consistent assets possible.

---

## Key Insight: Philosophy Drives Implementation

Instead of: "Make this look cool"
→ We ask: "How do we make this automated and consistent?"

Instead of: "What would look good here?"
→ We ask: "What does the philosophy require?"

Instead of: "Let me hand-craft this"
→ We ask: "How do we parametrize this for automation?"

This mental shift from "art pipeline" to "asset generation system" is what makes scaling possible.

---

## Current Status

✅ **Complete**:
- VISUAL_PHILOSOPHY.md (foundation)
- Icon Bible (framework)
- Design Research Index (specification mapping)
- 10 Research Session files (detailed specs)
- Asset Registry Specification (what exists)
- UNIFIED_ASSET_CATALOG_ARCHITECTURE.md (organizing principle)

⏳ **In Progress**:
- First asset generation using this system (unit sprites)
- Component render specifications formalization
- Prompt template automation (PromptBuilder service)

🔴 **Next**:
- Generate terrain/biome tiles (Layer 0 + 1)
- Generate component catalog (using Session 2, 6, 8, 9 specs)
- Generate corporate branding (using Session 5, 7)
- Establish visual identity guidelines (extracted from research)

---

## How to Use This System

**For Design Decisions**:
1. Read VISUAL_PHILOSOPHY.md
2. Reference Icon Bible section
3. Check UNIFIED_ASSET_CATALOG_ARCHITECTURE.md for naming

**For Asset Generation**:
1. Define resource in JSON
2. Look up relevant session in Design Research Index
3. Read session file for detailed specifications
4. Use Icon Bible Section 12 prompt template (parametric)
5. Generate asset using specifications
6. Validate against VISUAL_PHILOSOPHY.md principles

**For New Expansions** (e.g., new planet):
1. Location affects JSON metadata only
2. No asset regeneration needed
3. Same asset library works everywhere
4. Simulation parameters adjust, visuals stay consistent

---

## The Goal

**Build a system where**:
- Every asset follows documented philosophy
- Every asset derives from specifications
- Every asset generation is reproducible
- Every new asset inherits consistency automatically
- Adding 1,000 assets doesn't require 1,000x effort

**That system is now in place.**

The next phase is using it to generate the actual assets.

---

## References

- VISUAL_PHILOSOPHY.md (foundation)
- Icon Bible (framework)
- Design Research Index (specifications)
- 10 Research session files (details)
- UNIFIED_ASSET_CATALOG_ARCHITECTURE.md (organization)
- Asset Registry Specification (catalog)

ChatGPT insight (2026-07-19): Recognition that this evolved from "design sprites" to "design the system that generates sprites."
