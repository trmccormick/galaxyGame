# Monitor View Loading Issue - Analysis
**Issue**: Map doesn't display on first page load, requires refresh
**Impact**: Poor user experience, confusing behavior
**Priority**: HIGH (affects every planet view)

---

## Problem Description

### Current Behavior:
```
User clicks "Monitor" for any planet
  ↓
Page loads (URL changes, view renders)
  ↓
Canvas appears but is BLANK/EMPTY
  ↓
User hits F5 (refresh)
  ↓
Map displays correctly
```

### Expected Behavior:
```
User clicks "Monitor" for any planet
  ↓
Page loads (URL changes, view renders)
  ↓
Canvas displays map immediately
  ↓
User sees terrain without needing refresh
```

---

## Root Cause Analysis

### Classic Race Conditions

This is almost certainly a **JavaScript timing issue**. Common causes:

### Cause 1: Canvas Renders Before Data Loads (Most Likely)
```javascript
// What's probably happening:
document.addEventListener('DOMContentLoaded', () => {
  const canvas = document.getElementById('terrain-canvas');
  const ctx = canvas.getContext('2d');
  
  // Canvas is ready...
  renderTerrain(ctx, terrainData); // But terrainData is undefined!
});

// Meanwhile, terrainData loads asynchronously:
fetch('/api/terrain/123').then(data => {
  terrainData = data; // Too late! Canvas already tried to render
});
```

**Why refresh works**: On refresh, the terrain data is cached (or loads faster), so it's available when canvas renders.

### Cause 2: Turbo/Turbolinks Page Load (Rails 7 Issue)
```javascript
// Rails 7 uses Turbo for page navigation
// Turbo doesn't fire DOMContentLoaded on subsequent page loads

// What works on first visit:
document.addEventListener('DOMContentLoaded', initCanvas);

// What doesn't work on Turbo navigation:
// DOMContentLoaded doesn't fire again!

// Need this instead:
document.addEventListener('turbo:load', initCanvas);
```

**Why refresh works**: Full page reload triggers DOMContentLoaded properly.

### Cause 3: Data in Page but JavaScript Doesn't Find It
```erb
<!-- monitor.html.erb -->
<script>
  const terrainData = <%= raw @terrain_map.to_json %>;
</script>

<script src="/assets/terrain_renderer.js"></script>

<!-- Problem: terrain_renderer.js executes before terrainData is defined -->
```

**Why refresh works**: On refresh, browser execution order might be different.

### Cause 4: Canvas Size Not Set Before Render
```javascript
const canvas = document.getElementById('terrain-canvas');
canvas.width = 800;  // Not set yet!
canvas.height = 600; // Not set yet!

// Canvas has no dimensions, so nothing renders
renderTerrain(canvas); // Draws to 0x0 canvas (invisible)
```

**Why refresh works**: On refresh, CSS might load first, giving canvas initial size.

---

## Investigation Steps

### Step 1: Check Browser Console
**What to look for**:
```
First load (blank map):
  - JavaScript errors?
  - "terrainData is undefined"?
  - "Cannot read property 'elevation' of undefined"?
  - Canvas size errors?

After refresh (works):
  - Same errors or different?
  - Any warnings about timing?
```

### Step 2: Check Network Tab
**What to look for**:
```
First load:
  - Is terrain data fetched? (look for AJAX/fetch requests)
  - What's the timing? (does it load after canvas renders?)
  - Any 404s or failed requests?

After refresh:
  - Different timing?
  - Data loads faster?
  - Different request order?
```

### Step 3: Examine JavaScript Event Listeners
**Check monitor view file**:
```bash
# Find the monitor view
grep -r "terrain-canvas" app/views/admin/celestial_bodies/

# Check what JavaScript is loaded
grep -r "addEventListener" app/views/admin/celestial_bodies/monitor.html.erb

# Look for:
- DOMContentLoaded (might not fire with Turbo)
- turbo:load (correct for Rails 7)
- window.onload (fires after everything loads)
```

### Step 4: Check Data Loading Method
**Is terrain data**:
```erb
A. Embedded in page? (fast, should work)
   <script>
     const terrainData = <%= raw @terrain_map.to_json %>;
   </script>

B. Fetched via AJAX? (slow, timing issues)
   <script>
     fetch('/admin/terrain/<%= @celestial_body.id %>')
       .then(r => r.json())
       .then(data => renderTerrain(data));
   </script>

C. Loaded from separate JS file? (execution order issues)
   <script src="/assets/terrain_loader.js"></script>
```

### Step 5: Add Debug Logging
**Temporary debugging**:
```javascript
console.log('[TERRAIN] Page load started');

document.addEventListener('turbo:load', () => {
  console.log('[TERRAIN] Turbo load fired');
  console.log('[TERRAIN] Canvas element:', document.getElementById('terrain-canvas'));
  console.log('[TERRAIN] Terrain data available:', typeof terrainData !== 'undefined');
  
  if (typeof terrainData !== 'undefined') {
    console.log('[TERRAIN] Data dimensions:', terrainData.width, 'x', terrainData.height);
    renderTerrain(terrainData);
  } else {
    console.error('[TERRAIN] Data not available at render time!');
  }
});
```

---

## Likely Solutions (Ordered by Probability)

### Solution 1: Use Turbo Load Event (90% probability)
**If**: Using Rails 7 with Turbo
**Fix**: Change event listener

```javascript
// BEFORE (doesn't work with Turbo):
document.addEventListener('DOMContentLoaded', () => {
  initializeTerrainMap();
});

// AFTER (works with Turbo):
document.addEventListener('turbo:load', () => {
  initializeTerrainMap();
});

// OR support both:
['DOMContentLoaded', 'turbo:load'].forEach(event => {
  document.addEventListener(event, () => {
    initializeTerrainMap();
  });
});
```

### Solution 2: Wait for Data Before Rendering (80% probability)
**If**: Data loads asynchronously
**Fix**: Add loading state

```javascript
// Add loading indicator
let terrainData = null;

async function loadAndRenderTerrain(celestialBodyId) {
  showLoadingSpinner();
  
  try {
    const response = await fetch(`/admin/terrain/${celestialBodyId}`);
    terrainData = await response.json();
    
    renderTerrain(terrainData);
    hideLoadingSpinner();
  } catch (error) {
    console.error('Failed to load terrain:', error);
    showErrorMessage();
  }
}

// Call on page load
document.addEventListener('turbo:load', () => {
  const bodyId = document.querySelector('[data-body-id]').dataset.bodyId;
  loadAndRenderTerrain(bodyId);
});
```

### Solution 3: Ensure Canvas Dimensions (60% probability)
**If**: Canvas size is zero on first render
**Fix**: Set dimensions explicitly

```javascript
function initializeCanvas() {
  const canvas = document.getElementById('terrain-canvas');
  const container = canvas.parentElement;
  
  // Set canvas size from container or explicit values
  canvas.width = container.clientWidth || 800;
  canvas.height = container.clientHeight || 600;
  
  console.log('Canvas initialized:', canvas.width, 'x', canvas.height);
  
  // Now render
  if (terrainData) {
    renderTerrain(canvas, terrainData);
  }
}

document.addEventListener('turbo:load', initializeCanvas);
```

### Solution 4: Defer JavaScript Execution (50% probability)
**If**: Script runs before elements exist
**Fix**: Use defer or move script to bottom

```erb
<!-- BEFORE (might run too early): -->
<script>
  initializeTerrainMap();
</script>

<div id="terrain-canvas"></div>

<!-- AFTER (runs after HTML parsed): -->
<div id="terrain-canvas"></div>

<script>
  // Or use defer attribute:
  initializeTerrainMap();
</script>
```

### Solution 5: Force Data to Be Available (40% probability)
**If**: Data embedded but not accessible
**Fix**: Ensure proper scope

```erb
<!-- Embed data globally -->
<script>
  window.TERRAIN_DATA = <%= raw @terrain_map.to_json %>;
  window.CELESTIAL_BODY_ID = <%= @celestial_body.id %>;
</script>

<!-- Then in main script: -->
<script>
  document.addEventListener('turbo:load', () => {
    if (window.TERRAIN_DATA) {
      renderTerrain(window.TERRAIN_DATA);
    } else {
      console.error('TERRAIN_DATA not available');
    }
  });
</script>
```

---

## Testing Plan

### Test 1: Identify Event Listener Issue
```javascript
// Add to monitor.html.erb temporarily:
<script>
  console.log('=== TERRAIN DEBUG START ===');
  
  ['DOMContentLoaded', 'turbo:load', 'load'].forEach(event => {
    document.addEventListener(event, () => {
      console.log(`[${event}] fired at`, Date.now());
      console.log(`  Canvas exists:`, !!document.getElementById('terrain-canvas'));
      console.log(`  Data available:`, typeof terrainData !== 'undefined');
    });
  });
</script>

<!-- Then check console on first load vs. refresh -->
```

### Test 2: Verify Data Loading Timing
```javascript
// Add before render code:
console.log('Terrain data structure:', {
  exists: !!terrainData,
  keys: terrainData ? Object.keys(terrainData) : null,
  dimensions: terrainData ? `${terrainData.width}x${terrainData.height}` : null,
  elevationExists: terrainData?.elevation?.length > 0
});
```

### Test 3: Test Canvas State
```javascript
// Check canvas before rendering:
const canvas = document.getElementById('terrain-canvas');
console.log('Canvas state:', {
  exists: !!canvas,
  width: canvas?.width,
  height: canvas?.height,
  offsetWidth: canvas?.offsetWidth,
  offsetHeight: canvas?.offsetHeight
});
```

---

## Quick Fix to Test Theory

### Temporary Workaround:
```javascript
// Add this to force render after delay:
document.addEventListener('turbo:load', () => {
  // Try immediate render
  attemptRender();
  
  // If that fails, try again after delay
  setTimeout(() => {
    console.log('[TERRAIN] Retry render after 100ms');
    attemptRender();
  }, 100);
});

function attemptRender() {
  const canvas = document.getElementById('terrain-canvas');
  if (canvas && typeof terrainData !== 'undefined') {
    console.log('[TERRAIN] Rendering...');
    renderTerrain(canvas, terrainData);
  } else {
    console.warn('[TERRAIN] Not ready:', { canvas: !!canvas, data: typeof terrainData !== 'undefined' });
  }
}
```

**If this fixes it**: Confirms timing issue, then implement proper solution.

---

## Recommended Action

### Immediate (For Grok):
1. **Add debug logging** to identify which event fires
2. **Check browser console** on first load vs. refresh
3. **Examine monitor.html.erb** for event listeners
4. **Report findings** with specific error messages/logs

### After Diagnosis:
**Most likely fix**: Change `DOMContentLoaded` to `turbo:load`
**Estimated time**: 30 minutes to identify, 15 minutes to fix

### Acceptance Criteria:
- ✅ Map displays on first page load (no refresh needed)
- ✅ Works for Earth (NASA data)
- ✅ Works for exoplanets (generated data)
- ✅ No console errors
- ✅ Loading indicator shows while data loads (nice-to-have)

---

## Impact Assessment

### Current Impact:
- **User Experience**: Very poor (every user must refresh)
- **Perception**: Looks broken/buggy
- **Workflow**: Adds friction to every planet view

### After Fix:
- **User Experience**: Smooth, immediate
- **Perception**: Professional, polished
- **Workflow**: Seamless planet exploration

### Priority Justification:
This should be **Priority 1** because:
- Affects every single planet view
- Simple fix (likely 1 line change)
- High user impact for low effort
- Makes everything else look better

---

## Task for Grok

**Title**: Diagnose and Fix Monitor View Loading Issue

**Investigation** (30 minutes):
1. Add debug logging to monitor.html.erb
2. Check browser console on first load
3. Identify which events fire (or don't fire)
4. Report findings with logs

**Fix** (15 minutes):
Based on findings, likely:
- Change event listener to `turbo:load`
- Or ensure data availability before render
- Or add proper async loading

**Testing** (15 minutes):
1. Test Earth monitor (first load, no refresh)
2. Test exoplanet monitor (first load, no refresh)
3. Test multiple planets in sequence
4. Verify no console errors

**Total**: ~1 hour to completely fix

---

**Recommendation**: Fix this BEFORE investigating generated terrain quality. 

Why? Because if the map doesn't show properly, we can't even evaluate if the generated terrain "looks odd" - we need reliable rendering first!

