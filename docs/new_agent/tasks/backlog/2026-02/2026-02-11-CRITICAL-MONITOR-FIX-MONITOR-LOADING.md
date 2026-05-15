# TASK: 2026-02-11-CRITICAL-MONITOR-FIX-MONITOR-LOADING
**Status**: BACKLOG  
**Priority**: CRITICAL  
**Type**: bug-fix  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: 0.33x (Gemini Flash)  
**Why This Agent**: Straightforward JS asset loading fix, self-contained  
**Supervision Level**: standard  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
The admin planetary monitor page fails to render the canvas/map on first load, requiring a manual page refresh. This affects system administration and monitoring capabilities. The page loads the HTML structure but the JavaScript for canvas rendering is not executed.

**Relevant Architecture Docs** — read before starting:
- `docs/systems/monitoring.md` — [describes admin monitoring interfaces]
- `docs/developer/frontend-assets.md` — [asset pipeline and JS loading]

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

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `app/views/admin/celestial_bodies/planetary.html.erb` | Admin planetary view template | head section for JS include |
| `app/javascript/admin/monitor.js` | Planetary canvas rendering logic | initialization code |
| `config/importmap.rb` | Rails importmap configuration | pin monitor.js |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/assets/stylesheets/admin/monitor.css.scss` | Monitor styling | ensure styles load |

---

## Implementation Steps

### Step 1 — Pin monitor.js in importmap
Add pin for admin/monitor.js to enable loading

```ruby
# config/importmap.rb
pin "admin/monitor"
```

### Step 2 — Include monitor.js in planetary view
Add JavaScript include tag to head section

```erb
<!-- app/views/admin/celestial_bodies/planetary.html.erb -->
<%= javascript_include_tag 'admin/monitor' %>
```

### Step 3 — Verify JS initialization
Check that monitor.js DOMContentLoaded event fires and canvas renders

### Step 4 — Test loading behavior
- Load planetary page directly (not via refresh)
- Confirm canvas renders without manual refresh
- Check browser console for any JS errors

### Step 5 — Run tests
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/features/admin/planetary_monitor_spec.rb'
Expected result: X examples, 0 failures

---

## Acceptance Criteria
- [ ] Planetary monitor page loads canvas immediately on first visit
- [ ] No manual refresh required to see planetary map
- [ ] monitor.js executes on page load
- [ ] Canvas renders terrain data when available
- [ ] No JavaScript errors in browser console
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Root cause is deeper architectural issue (not just asset loading)
- Changes affect other admin views unexpectedly
- monitor.js has complex dependencies preventing load

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add config/importmap.rb app/views/admin/celestial_bodies/planetary.html.erb
git commit -m "fix: admin planetary monitor — include monitor.js for canvas rendering on first load"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: [none]  
**Blocks**: [admin monitoring features]  
**Related tasks**: [none]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `config/importmap.rb` — pinned admin/monitor.js
- `app/views/admin/celestial_bodies/planetary.html.erb` — added JS include tag

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]