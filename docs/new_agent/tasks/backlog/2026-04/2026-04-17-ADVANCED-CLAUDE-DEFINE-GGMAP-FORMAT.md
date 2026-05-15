# 2026-04-17-ADVANCED-CLAUDE-DEFINE-GGMAP-FORMAT

**Status**: BACKLOG

**Agent Assignment**
**Assigned To**: GPT-4.1 0.33x — Advanced research task for defining .ggmap map format specification
**Supervision Level**: 🔴 Watched carefully

## Context
Galaxy Game requires next-generation map format beyond FreeCiv/Civ4, supporting scientific, strategic, terraforming, and gameplay layers. Must enable non-destructive hierarchical editing and support large high-resolution datasets.

## Problem Statement
No current format meets Galaxy Game needs for terrain data storage, exchange, and interoperability. Need foundational .ggmap format for future terrain and gameplay systems.

**Expected**: Complete .ggmap format specification supporting all required layers with hierarchical non-destructive editing.

## Files Involved
### Primary Files — you will create
| File | Purpose | Action |
|---|---|---|
| `docs/architecture/ggmap_format.md` | Format specification | Create comprehensive document |
| `galaxy_game/lib/ggmap.rb` | Format handler class | Design Ruby reader/writer classes |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `galaxy_game/app/services/map_export_service.rb` | Integration point for export |
| `galaxy_game/app/services/terrain_service.rb` | Integration point for terrain loading |

## Implementation Steps
1. **Format specification**: Define header structure, data sections, compression, metadata
2. **Hierarchical layer system**: Design base, scientific, strategic, terraforming, scenario layers
3. **Data schema design**: Create hierarchical JSON schema with validation rules
4. **Implementation planning**: Design Ruby classes, identify integration points, plan tools
5. **Research references**: Review existing formats for best practices

## Acceptance Criteria
- [ ] Complete .ggmap format specification document with all layer definitions
- [ ] Data structures support scientific, strategic, and gameplay data
- [ ] Hierarchical, non-destructive layer system
- [ ] Ruby classes designed for reading/writing/validation
- [ ] Integration points identified in terrain service and monitor interface
- [ ] Format supports all current and planned terrain/map features
- [ ] All design decisions and research documented

## Stop Conditions
- Architectural or data model blockers found
- Suitable open standard found that meets all requirements

## Commit Instructions
```bash
git add docs/architecture/ggmap_format.md
git add galaxy_game/lib/ggmap.rb
git commit -m "docs: .ggmap format specification — hierarchical map format for Galaxy Game terrain data"
```