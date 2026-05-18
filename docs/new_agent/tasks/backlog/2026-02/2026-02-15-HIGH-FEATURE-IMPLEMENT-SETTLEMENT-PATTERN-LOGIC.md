---
status: BACKLOG
priority: HIGH
type: feature
system_domain: AI_MANAGER
mvp_alignment: AI_MANAGER_LUNA_SETTLEMENT
local_worker_safe: true
---

# TASK: Implement Settlement Pattern Serialization Logic
**Status**: BACKLOG
**Priority**: HIGH
**Type**: feature
**Created**: 2026-02-15
**Last Updated**: 2026-05-17

---

## Local Worker Triage Report
*Filled in by local model (Ollama via Continue) during backlog review*
*Local models read task files only — they cannot run commands or access the DB*

- **Template Conformance**: PASS
- **Docker Wrapper Check**: N/A
- **MVP Alignment**: VALID — enables Luna pattern storage and cross-system deployment
- **MVP Impact Note**: Reduces continuous geospatial map calculations by caching successful base layouts as portable JSON templates
- **Action Line**: READY FOR CLOUD HANDOFF

---

## Context

To reduce continuous, high-overhead geospatial map calculations, the AI Manager must be able to remember its high-yielding base layout configurations (the **Luna Pattern**) and save them as reusable templates.

When implementing, the agent must embed these serialization requirements:
1. **JSON Layout Blueprinting**: Convert successful grid coordinate snapshots containing structural anchors (i-beam coordinates, structural margins, and panel layouts) into flat JSON files.
2. **Layout Portability**: The pattern must be structured generically so it can be unpacked and laid down on entirely different planets or systems (such as Super-Mars or Alpha Centauri setups) without re-calculating raw spatial clearance parameters from scratch.

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/services/ai_manager/pattern_serializer.rb` | Serialize/deserialize grid layout snapshots to JSON | `def capture_pattern`, `def apply_pattern` |
| `app/models/settlement_pattern.rb` | Model storing schema definitions and serialized layouts | JSON columns layout schema |
| `spec/services/ai_manager/pattern_serializer_spec.rb` | Validate JSON structure, footprint metrics, and portability | Blueprint verification specs |

---

## Implementation Blueprint Reference

```ruby
# app/services/ai_manager/pattern_serializer.rb
module AiManager
  class PatternSerializer
    def initialize(lunar_map)
      @lunar_map = lunar_map
    end

    def capture_pattern(center_coordinate, scope_radius)
      grid_data = @lunar_map.nodes_within(center_coordinate, scope_radius)
      
      # Map layout geometry into a portable schema format
      {
        pattern_name: "Luna_Pattern_Standard",
        structural_framework: "i_beam_grid",
        nodes: grid_data.map { |node| { x: node.x_offset, y: node.y_offset, asset: node.structural_type } }
      }.to_json
    end
    
    def apply_pattern(layout_name, target_region)
      layout = load_from_storage(layout_name)
      
      # Unpack pattern to target coordinates with terrain validation
      result = {
        success: true,
        deployed_nodes: 0,
        failed_positions: [],
        region: target_region
      }
      
      if layout && target_region.compatible?(layout.structural_framework)
        # Deploy logic would go here
      end
      
      result.to_json
    rescue => e
      { success: false, error: e.message }.to_json
    end
  end
end
```

> **0x/0.33x agents**: follow these steps exactly in order.  
> **1x agents**: use as reference only — do not assume any details outside what's specified.

---

## Reference Files for Implementation
*Agents must consult these files to understand the existing schema and constraints*

| File | Purpose | Key Constraints |
|---|---|---|
| `app/services/ai_manager/pattern_serializer.rb` | Core serialization logic (to be created) | Must match Luna pattern structure |
| `app/models/settlement_pattern.rb` | Model storing layouts (may need to add JSON column) | Use schema for validation |
| `app/controllers/plans_controller.rb` | Existing controller with `set_plan_data` method | Verify it handles JSON layout input |

---

## Implementation Steps for Agent

1. **Step 1: Add Pattern Capture Method**
   - Implement `capture_pattern(center_coordinate, scope_radius)` to extract nodes within radius
   - Include structural metadata (i-beam coordinates, panel types) in output
   - Return as compact JSON with pattern identifier

2. **Step 2: Add Pattern Application Method**  
   - Implement `apply_pattern(layout_name, target_region)` to unpack and deploy patterns
   - Validate target terrain compatibility (super-mars vs earth clearance)
   - Return success/failure with affected coordinate offsets

3. **Step 3: Wire into Settlement Controller**
   - Inject `PatternSerializer` into AI Manager's orchestration layer
   - Call capture after successful simulation runs (golden pattern extraction)
   - Queue application for new settlement requests needing Luna patterns

---

## Supervision & Safety Notes

- **No External Access**: This task operates purely within the codebase — no DB writes, Docker operations, or terminal commands required.
- **Deterministic Output**: Serialization must produce identical JSON for the same input grid state (no random seeds).
- **Cross-system Ready**: Test patterns on both Lunar and simulated Super-Mars environments to verify portability.

---

## Testing Requirements
*Agents must verify these behaviors when implementing*

- [ ] `capture_pattern` correctly serializes grid data to Luna pattern JSON
- [ ] Pattern includes structural framework type (i_beam_grid)
- [ ] Serialized patterns can be applied to different planetary coordinates
- [ ] Model schema supports the new JSON column
- [ ] Controller properly accepts and stores layout data
- [ ] Tests pass in local environment (Ollama) and cloud (GPT-4.1 0x)

---

## Implementation Checklist
*Track these items as you build the feature*

- [ ] Created `app/services/ai_manager/pattern_serializer.rb` with capture/apply methods
- [ ] Updated `settlement_pattern.rb` schema to support JSON layout storage
- [ ] Wire-pattern serializer into plans controller lifecycle
- [ ] Written tests in `spec/services/ai_manager/pattern_serializer_spec.rb`
- [ ] Verified cross-platform portability (Luna → Super-Mars scenario)
- [ ] Documented implementation decisions and trade-offs
"