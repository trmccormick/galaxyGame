# TASK: 2026-02-11-HIGH-FEATURE-ADD-ADMIN-CELESTIAL-BODY-SHOW-VIEW
**Status**: BACKLOG  
**Priority**: HIGH  
**Type**: feature  
**Created**: 2026-02-11  
**Last Updated**: 2026-05-14  

---

## Agent Assignment

**Assigned To**: 0.33x (Gemini Flash)  
**Why This Agent**: Straightforward admin view creation, follows existing patterns  
**Supervision Level**: standard  

**Supervision Legend**:
- 🔴 Watched carefully = 0x/0.25x agents
- 🟡 Standard = 0.33x agents  
- 🟢 Autonomous OK = 1x agents

---

## Context
Admin interface lacks a dedicated show view for celestial bodies. Currently, "View" links in admin simulation redirect to public pages instead of admin views with enhanced controls and information.

**Relevant Architecture Docs** — read before starting:
- `docs/systems/admin-interface.md` — [admin interface patterns]
- `docs/developer/rails-views.md` — [view creation guidelines]

---

## Problem Statement
Admin simulation page "View" links go to public celestial body pages instead of admin show views. Missing admin show action and view for comprehensive celestial body management.

**Current behavior**: View links redirect to public `/celestial_bodies/:id`  
**Expected behavior**: View links redirect to admin `/admin/celestial_bodies/:id` with admin controls  

---

## Files Involved

### Primary Files — you will edit these
| File | Purpose | Key Method/Section |
|---|---|---|
| `config/routes.rb` | Admin routes | add :show to celestial_bodies |
| `app/controllers/admin/celestial_bodies_controller.rb` | Admin controller | add show action |
| `app/views/admin/celestial_bodies/show.html.erb` | Admin show view | new file |
| `app/views/admin/simulation/index.html.erb` | Simulation view | update View link |

### Reference Files — read but do not edit
| File | Why You Need It |
|---|---|
| `app/views/admin/celestial_bodies/planetary.html.erb` | Existing admin view | styling pattern |

---

## Implementation Steps

### Step 1 — Update admin routes
Add :show to admin celestial_bodies resources in config/routes.rb

```ruby
namespace :admin do
  resources :celestial_bodies, only: [:index, :show] do
    # existing member routes
  end
end
```

### Step 2 — Add show action to controller
Add show method to Admin::CelestialBodiesController

```ruby
def show
  @celestial_body = safe_find(CelestialBodies::CelestialBody, params[:id])
  @atmosphere = @celestial_body.atmosphere
  @hydrosphere = @celestial_body.hydrosphere
  @geosphere = @celestial_body.geosphere
  @biosphere = @celestial_body.biosphere
end
```

### Step 3 — Create admin show view
Create app/views/admin/celestial_bodies/show.html.erb with:
- Comprehensive celestial body information
- Admin controls (edit, monitor, surface view)
- System integration details
- AI analysis options
- Terraforming status
- Settlement information
- SimEarth aesthetic

### Step 4 — Update simulation view link
Change View link in admin/simulation/index.html.erb to use admin_celestial_body_path

### Step 5 — Test navigation
Verify View links in admin simulation go to admin show page

### Step 6 — Run tests
DO NOT INFER THE COMMAND. Run this exact string from the host terminal:

Bash
docker exec -it web bash -c 'cd /home/galaxy_game && unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/controllers/admin/celestial_bodies_controller_spec.rb'
Expected result: X examples, 0 failures

---

## Acceptance Criteria
- [ ] Admin celestial_bodies routes include :show action
- [ ] Admin::CelestialBodiesController has show action
- [ ] Admin show view displays comprehensive information and controls
- [ ] Simulation View links redirect to admin show page
- [ ] No routing errors
- [ ] Consistent with other admin interfaces
- [ ] Isolation run: 0 failures
- [ ] No regressions in related specs
- [ ] Full suite run completed and logged

---

## Stop Conditions — escalate to user immediately if:
- Route conflicts with existing admin routes
- Controller action conflicts with existing methods
- View creation requires complex logic beyond display

---

## Commit Instructions
Run git commands on **host**, not inside container:
```bash
git add config/routes.rb app/controllers/admin/celestial_bodies_controller.rb app/views/admin/celestial_bodies/show.html.erb app/views/admin/simulation/index.html.erb
git commit -m "feat: add admin celestial body show view

- Add :show to admin celestial_bodies routes
- Implement show action in controller
- Create comprehensive admin show view
- Update simulation View links to use admin path"
git push
```

---

## Documentation
- [ ] No doc changes needed

---

## Dependencies
**Blocked by**: [none]  
**Blocks**: [admin navigation improvements]  
**Related tasks**: [none]  

---

## Completion Report
*Filled in by the implementing agent after completion*

**Completed by**: [agent name]  
**Completion date**: YYYY-MM-DD  
**Final test result**: X examples, Y failures  

### What was changed
- `config/routes.rb` — added :show to admin celestial_bodies
- `app/controllers/admin/celestial_bodies_controller.rb` — added show action
- `app/views/admin/celestial_bodies/show.html.erb` — created admin show view
- `app/views/admin/simulation/index.html.erb` — updated View link

### Issues discovered
[Any problems found during implementation that weren't in the original task]

### Follow-up tasks needed
[Any new backlog items identified — do not create the files, just list them here]

### Lessons learned
[What worked, what didn't, what future tasks in this area should know]