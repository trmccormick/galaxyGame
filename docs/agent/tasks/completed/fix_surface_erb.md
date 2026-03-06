# TASK: fix_surface_erb.md
## Assign: Gemini 3 Flash | Priority: HIGH | Time: 15 min
## File: app/views/admin/celestial_bodies/surface.html.erb

Seven targeted changes. Do not reformat or reorganise file.

CHANGE 1 - Remove duplicate unescaped PLANET globals (~lines 133-136)
DELETE this block inside mapControls div:
  <script>
      window.PLANET_TYPE = "<%= @celestial_body.type %>";
      window.PLANET_NAME = "<%= @celestial_body.name %>";
  </script>
Keep only footer versions (~lines 197-198) which are correctly escaped with j helper.

CHANGE 2 - Fix biomes fallback (~line 32)
FROM: biomes: terrain_map_data['biomes'] || terrain_map_data['grid'],
TO:   biomes: terrain_map_data['biomes'],
Reason: terrain_map_data['grid'] is FreeCiv single-char letters not biome strings.
        Biosphere guard in backend means nil is correct fallback now.

CHANGE 3 - Fix canvas sizing (~line 126)
FROM: <canvas id="surfaceCanvas" width="2400" height="1200"></canvas>
TO:   <canvas id="surfaceCanvas" style="display:block; width:100%; height:100%;"></canvas>
Reason: Fixed dims cause blur. JS sets pixel dims to match container on init.

CHANGE 4 - Fix canvas container overflow (~line 124)
FROM: style="overflow: auto; width: 100%; height: 100%;"
TO:   style="overflow: hidden; width: 100%; height: 100%;"
Reason: overflow:auto scrollbar conflicts with JS pan/drag system.

CHANGE 5 - Fix zoom slider range (~line 139)
FROM: min="0.5" max="6" step="0.1" value="2.5"
TO:   min="0.1" max="4" step="0.05" value="1"
Reason: JS auto-fit sets actual starting zoom. Slider needs wider range.

CHANGE 6 - Add iron oxide to planet_data hash (after has_hydrosphere line ~52)
ADD:
  crust_iron_oxide_percentage: @celestial_body.geosphere&.properties&.dig('iron_oxide_percentage') ||
                                @celestial_body.geosphere&.crust_composition&.dig('iron_oxide') || 0,
Reason: monitor.js reads this for rust tint. Without it Mars stays grey.
        Verify exact field path matches what monitor task used.

CHANGE 7 - Add passability and resource rows to right panel cursor section
After cursor-elevation data-row add:
  <div class="data-row">
    <span class="data-label">Passability:</span>
    <span class="data-value" id="cursor-passability">-</span>
  </div>
  <div class="data-row">
    <span class="data-label">Resource:</span>
    <span class="data-value" id="cursor-resource">-</span>
  </div>
Reason: JS tile click handler populates these. DOM elements must exist.

Verification grep after changes:
  grep -n "PLANET_TYPE\|PLANET_NAME\|biomes.*grid\|surfaceCanvas\|overflow.*auto\|iron_oxide\|cursor-passability" \
    app/views/admin/celestial_bodies/surface.html.erb