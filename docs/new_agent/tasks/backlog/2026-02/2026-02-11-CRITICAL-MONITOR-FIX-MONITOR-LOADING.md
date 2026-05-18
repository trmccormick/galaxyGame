# TASK: Fix Monitor Loading (Celestial Body Data/Layers)
**Status**: BACKLOG  
**Priority**: CRITICAL  
**Type**: bug-fix  
**Created**: 2026-02-11

---

## Problem Statement
Admin planetary view (planetary.html.erb) displays a blank canvas on initial page load. The canvas element is present in the DOM but no rendering occurs until the page is refreshed.

**Error output** (if applicable):
- Browser console shows no errors
- Canvas element exists but remains blank
- No JavaScript execution traces for monitor.js

**Current behavior**: Canvas loads blank on first visit, requires refresh to display planetary map  
**Expected behavior**: Canvas renders planetary map immediately on page load

---

## Goals
- Fix JS timing and async data loading issues with Turbo/Hotwire lifecycle
- Add loading indicators, error handling, and validation
- Ensure all layers/canvas render on first load without manual refresh
- Integrate fixes in monitor.js, monitor.html.erb, and controller

---

## Acceptance Criteria
- [ ] Planetary monitor page loads canvas immediately on first visit
- [ ] No manual refresh required to see planetary map
- [ ] monitor.js executes correctly with Turbo/Hotwire lifecycle hooks
- [ ] Canvas renders terrain data when available
- [ ] No JavaScript errors in browser console
- [ ] Handles Turbo frame navigation and streaming correctly
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Implementation Steps

### Step 1 — Pin monitor.js in importmap
Add pin for admin/monitor.js to enable loading:

```ruby
# config/importmap.rb
pin "admin/monitor"
```

### Step 2 — Include monitor.js in planetary view
Add JavaScript include tag to head section with Turbo-aware attributes:

```erb
<!-- app/views/admin/celestial_bodies/planetary.html.erb -->
<%= javascript_include_tag 'admin/monitor', ":async" %>
```

### Step 3 — Implement Turbo-aware JS initialization
Replace generic DOMContentLoaded with Turbo lifecycle hooks:

```javascript
// app/javascript/admin/monitor.js
document.addEventListener('turbo:load', function() {
  // Wait for celestial body data to be available in DOM or fetched
  const initMonitor = () => {
    if (!window.monitorData || !window.canvasElement) return;
    
    try {
      // Render layers and canvas here
      renderCelestialLayers();
      initializeCanvas();
    } catch (error) {
      console.error('Monitor initialization failed:', error);
      showErrorState(error.message);
    }
  };

  // Check if data is ready, or wait for API response
  if (document.body.dataset.monitorReady === 'true') {
    initMonitor();
  } else {
    window.addEventListener('monitor:data-ready', initMonitor, { once: true });
  }
});

// Graceful fallback for non-Turbo navigation (direct page load)
if (!window.Turbo || !document.querySelector('[data-turbo-frame]')) {
  document.addEventListener('DOMContentLoaded', () => {
    // Same logic as above for traditional page loads
  });
}
```

### Step 4 — Verify JS initialization and Turbo compatibility
- Confirm monitor.js DOM initialization fires correctly with Turbo
- Check that canvas renders on both initial load and frame navigation
- Verify browser console shows no errors during initialization

### Step 5 — Test loading behavior
- Load planetary page directly (not via refresh)
- Confirm canvas renders without manual refresh
- Check Hotwire streaming scenarios work correctly
- Check browser console for any JS errors

### Step 6 — Run tests
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

```
bash docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/features/admin/planetary_monitor_spec.rb'
```
Expected result: X examples, 0 failures

---

## Related Files/Paths
- `app/views/admin/celestial_bodies/planetary.html.erb`
- `app/javascript/admin/monitor.js`
- `config/importmap.rb`
- `app/assets/stylesheets/admin/monitor.css.scss` (reference only)

---

## Stop Conditions — escalate to user immediately if:
- Root cause is deeper architectural issue (not just asset loading)
- Changes affect other admin views unexpectedly
- monitor.js has complex dependencies preventing load with Turbo events

---

## Commit Instructions
Run git commands on **host**, not inside container:
```
git add config/importmap.rb app/views/admin/celestial_bodies/planetary.html.erb app/javascript/admin/monitor.js
git commit -m "fix: admin planetary monitor — fix Turbo/Hotwire lifecycle for first-load rendering"
git push
```

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `config/importmap.rb` — pinned admin/monitor.js
- `app/views/admin/celestial_bodies/planetary.html.erb` — added JS include tag with async
- `app/javascript/admin/monitor.js` — implemented Turbo-aware initialization logic

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]

---

## Dependencies  
**Blocked by**: [none]  
**Blocks**: [admin monitoring features]  
**Related tasks**: [none]
