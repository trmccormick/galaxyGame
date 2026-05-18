# 2026-04-03-HIGH-ARCHITECTURE-PHASE4B TASK BREAKDOWN

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** ARCHITECTURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Status: Verified March 15, 2026 — No evidence of completion in CURRENT_STATUS.md or git log. Task remains active.
# Phase 4B UI Enhancements — Practical Task Breakdown

## Assessment

---

## Original Content

# Status: Verified March 15, 2026 — No evidence of completion in CURRENT_STATUS.md or git log. Task remains active.
# Phase 4B UI Enhancements — Practical Task Breakdown

## Assessment

The original Phase 4B document is a design spec with React component pseudo-code. The game uses ERB views, not React. There are no WebSocket APIs, no `/api/admin/systems` endpoints, and no real-time data infrastructure. Building everything in the spec would require months of work and a frontend framework migration.

**Practical approach:** Extract the valuable UI ideas and implement them as ERB + vanilla JS within the existing admin infrastructure. No new frameworks, no new database tables, no WebSocket architecture.

**Dependency:** All 4 tasks below depend on AI Manager Tasks 1-4 being complete first.

---

## Task 4B-R1: Research — Audit Existing Admin Infrastructure

**Priority:** HIGH (must complete before any 4B implementation)
**Estimated Time:** 30 minutes
**Risk Level:** NONE (read-only research)
**Agent:** GPT-4.1

### Objective
Document the current state of admin infrastructure so Phase 4B tasks can be written with accurate file paths, existing CSS classes, and real route names. This is a research task — no code changes.

### Instructions

Run each command and save the output to `docs/agent/research/phase4b_infrastructure_audit.md`:

```bash
# 1. List all admin routes
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=development bundle exec rails routes | grep "admin" | grep -v "ai_manager" | sort'

# 2. List existing admin SCSS files
docker exec -it web bash -c 'find /home/galaxy_game/app/assets/stylesheets/admin/ -name "*.scss" | sort'

# 3. Check existing JavaScript files in admin
docker exec -it web bash -c 'find /home/galaxy_game/app/javascript -name "*.js" | sort | head -30'

# 4. Check admin dashboard index for current layout pattern
docker exec -it web bash -c 'cat /home/galaxy_game/app/views/admin/dashboard/index.html.erb'

# 5. Check settlements index for existing settlement display
docker exec -it web bash -c 'cat /home/galaxy_game/app/views/admin/settlements/index.html.erb'

# 6. Check solar systems show for existing system display
docker exec -it web bash -c 'cat /home/galaxy_game/app/views/admin/solar_systems/show.html.erb'

# 7. Check galaxies show for existing galaxy display
docker exec -it web bash -c 'cat /home/galaxy_game/app/views/admin/galaxies/show.html.erb'

# 8. Check what columns exist on key models
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=development bundle exec rails runner "puts Settlement::BaseSettlement.column_names.inspect"'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=development bundle exec rails runner "puts CelestialBodies::CelestialBody.column_names.inspect"'
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=development bundle exec rails runner "puts SolarSystem.column_names.inspect"'
```

### Deliverable
Save all output to:
`docs/agent/research/phase4b_infrastructure_audit.md`

Format as:
```markdown
# Phase 4B Infrastructure Audit

## Admin Routes
[paste output]

## SCSS Files
[paste output]

## JavaScript Files
[paste output]

## Dashboard Layout
[paste output]

## Settlements Index
[paste output]

## Solar Systems Show
[paste output]

## Galaxies Show
[paste output]

## Model Columns
[paste output]
```

---

## Task 4B-1: Galaxy Navigation Sidebar for AI Manager

**Priority:** MEDIUM
**Estimated Time:** 1-2 hours
**Risk Level:** LOW
**Agent:** GPT-4.1
**Dependencies:** Task 4B-R1 complete, AI Manager Tasks 1-4 complete

### Objective
Add a galaxy/system navigation panel to the AI Manager sidebar. When viewing the AI Manager, the admin should be able to quickly see which solar systems have active missions and navigate to them. No new routes, no new database tables — uses existing data.

### What to Build
Add a collapsible "GALAXY STATUS" section to the AI Manager sidebar (defined in Task 1's `_ai_manager.scss` layout) that shows:
- Each solar system with active mission count
- Click navigates to `/admin/solar_systems/:id`

### Files to Modify
- `app/views/admin/ai_manager/index.html.erb` — add galaxy status partial
- `app/controllers/admin/ai_manager_controller.rb` — add solar system data to index action
- `app/views/admin/ai_manager/_galaxy_nav.html.erb` — create new partial

### Implementation

**Step 1:** Add to `index` action in controller:
```ruby
@solar_systems_with_missions = SolarSystem.joins(
  celestial_bodies: { settlements: :missions }
).where(missions: { status: :in_progress })
 .select('solar_systems.*, COUNT(DISTINCT missions.id) as active_mission_count')
 .group('solar_systems.id')
 .order('active_mission_count DESC')
 .limit(10)
```

**Step 2:** Create `app/views/admin/ai_manager/_galaxy_nav.html.erb`:
```erb
<div class="ai-galaxy-nav" id="galaxyNav">
  <div class="ai-galaxy-nav-header" onclick="toggleGalaxyNav()">
    <span>🌌 GALAXY STATUS</span>
    <span id="galaxyNavToggle">▼</span>
  </div>
  <div class="ai-galaxy-nav-body" id="galaxyNavBody">
    <% if @solar_systems_with_missions.any? %>
      <% @solar_systems_with_missions.each do |system| %>
        <%= link_to admin_solar_system_path(system), class: "ai-galaxy-nav-item" do %>
          <span class="ai-galaxy-nav-name"><%= system.name %></span>
          <span class="ai-badge ai-badge--info"><%= system.active_mission_count %></span>
        <% end %>
      <% end %>
    <% else %>
      <div style="color: #4a6080; font-size: 0.75rem; padding: 0.5rem;">
        No active missions across systems
      </div>
    <% end %>
  </div>
</div>

<script>
function toggleGalaxyNav() {
  const body = document.getElementById('galaxyNavBody');
  const toggle = document.getElementById('galaxyNavToggle');
  body.style.display = body.style.display === 'none' ? 'block' : 'none';
  toggle.textContent = body.style.display === 'none' ? '▶' : '▼';
}
</script>
```

**Step 3:** Add to `_ai_manager.scss`:
```scss
.ai-galaxy-nav {
  margin-top: 1rem;
  border-top: 1px solid rgba(0, 170, 255, 0.2);
  padding-top: 1rem;
}

.ai-galaxy-nav-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  font-size: 0.75rem;
  font-weight: 700;
  color: #00aaff;
  text-transform: uppercase;
  letter-spacing: 0.1em;
  padding: 0.25rem 0;

  &:hover { color: #e8f5ff; }
}

.ai-galaxy-nav-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.35rem 0.5rem;
  border-radius: 4px;
  color: #a0c8ff;
  text-decoration: none;
  font-size: 0.8rem;

  &:hover {
    background: rgba(0, 170, 255, 0.1);
    color: #e8f5ff;
  }
}
```

**Step 4:** Add `<%= render 'galaxy_nav' %>` to the sidebar in `index.html.erb` after the nav links.

### Verification
Visit `http://localhost:3000/admin/ai_manager` and confirm:
- Galaxy Status section appears in sidebar
- Toggle collapses/expands it
- Solar systems with active missions are listed with counts
- Clicking a system navigates to solar system page

---

## Task 4B-2: Settlement Status Dashboard Page

**Priority:** MEDIUM
**Estimated Time:** 2 hours
**Risk Level:** LOW
**Agent:** GPT-4.1
**Dependencies:** Task 4B-R1 complete, AI Manager Tasks 1-4 complete

### Objective
Create a new `/admin/ai_manager/settlements` page that shows all settlements across all celestial bodies in a card grid with health indicators. This replaces the need for a complex React multi-body dashboard — it's a simple ERB page with real data.

### Files to Create/Modify
- `app/views/admin/ai_manager/settlements.html.erb` — new view
- `app/controllers/admin/ai_manager_controller.rb` — add `settlements` action
- `config/routes.rb` — add settlements route

### Step 1: Add route
In `config/routes.rb` inside the `namespace :admin` > `namespace :ai_manager` block, add:
```ruby
get 'settlements', to: 'ai_manager#settlements'
```

### Step 2: Add controller action
```ruby
def settlements
  @settlements = Settlement::BaseSettlement
    .includes(:location, :missions, :inventory)
    .order(:name)

  @settlements_by_body = @settlements.group_by do |s|
    s.location&.celestial_body
  end

  @total_active_missions = Mission.where(status: :in_progress).count
  @total_failed_missions = Mission.where(status: [:failed, :stalled]).count
end
```

### Step 3: Create `settlements.html.erb`
```erb
<div class="ai-manager-layout">

  <aside class="ai-manager-sidebar">
    <h3>🤖 AI Manager</h3>
    <%= link_to "📊 Dashboard",    admin_ai_manager_path,               class: "ai-manager-nav-link" %>
    <%= link_to "🏙️ Settlements",  admin_ai_manager_settlements_path,   class: "ai-manager-nav-link active" %>
    <%= link_to "🚀 Missions",     admin_ai_manager_missions_path,      class: "ai-manager-nav-link" %>
    <%= link_to "🧠 Decisions",    admin_ai_manager_decisions_path,     class: "ai-manager-nav-link" %>
    <%= link_to "📋 Planner",      admin_ai_manager_planner_path,       class: "ai-manager-nav-link" %>
    <%= link_to "🎯 Patterns",     admin_ai_manager_patterns_path,      class: "ai-manager-nav-link" %>
    <%= link_to "📈 Performance",  admin_ai_manager_performance_path,   class: "ai-manager-nav-link" %>
    <%= link_to "🧪 Testing",      "/admin/ai_manager/testing",         class: "ai-manager-nav-link" %>
    <h3>Admin</h3>
    <%= link_to "← Dashboard", admin_dashboard_path, class: "ai-manager-nav-link" %>
  </aside>

  <header class="ai-manager-header">
    <h1>AI MANAGER — SETTLEMENTS</h1>
    <div class="header-meta">
      Total: <span class="status-ok"><%= @settlements.count %></span> settlements |
      Active Missions: <span class="status-ok"><%= @total_active_missions %></span> |
      Failed: <span class="<%= @total_failed_missions > 0 ? 'status-warn' : 'status-ok' %>">
        <%= @total_failed_missions %>
      </span>
    </div>
  </header>

  <main class="ai-manager-main">

    <% if @settlements_by_body.any? %>
      <% @settlements_by_body.each do |celestial_body, settlements| %>
        <div class="ai-card">
          <h2>
            🪐 <%= celestial_body&.name || 'Unknown Body' %>
            <span class="ai-badge ai-badge--info" style="font-size: 0.75rem;">
              <%= settlements.count %> settlement<%= settlements.count == 1 ? '' : 's' %>
            </span>
          </h2>

          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1rem;">
            <% settlements.each do |settlement| %>
              <%
                active_missions = settlement.missions.select { |m| m.status.to_sym == :in_progress }.count
                failed_missions = settlement.missions.select { |m| [:failed, :stalled].include?(m.status.to_sym) }.count
                health = failed_missions > 0 ? 'error' : active_missions > 0 ? 'success' : 'neutral'
              %>
              <div class="ai-card" style="margin-bottom: 0;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.5rem;">
                  <strong style="font-size: 0.95rem;"><%= settlement.name %></strong>
                  <span class="ai-badge ai-badge--<%= health %>">
                    <%= failed_missions > 0 ? 'ISSUES' : active_missions > 0 ? 'ACTIVE' : 'IDLE' %>
                  </span>
                </div>

                <div style="font-size: 0.8rem; color: #6aa0cc; margin-bottom: 0.75rem;">
                  Type: <%= settlement.settlement_type&.humanize || '—' %> |
                  Pop: <%= settlement.current_population || 0 %>
                </div>

                <div style="display: flex; gap: 0.5rem; font-size: 0.75rem; margin-bottom: 0.75rem;">
                  <span class="ai-badge ai-badge--info"><%= active_missions %> active</span>
                  <% if failed_missions > 0 %>
                    <span class="ai-badge ai-badge--error"><%= failed_missions %> failed</span>
                  <% end %>
                  <span class="ai-badge ai-badge--neutral"><%= settlement.missions.count %> total</span>
                </div>

                <%= link_to "View Missions",
                      admin_ai_manager_missions_path,
                      class: "ai-btn ai-btn--secondary ai-btn--small" %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    <% else %>
      <div class="ai-placeholder">
        No settlements found. Create settlements via the game interface.
      </div>
    <% end %>

  </main>
</div>
```

### Verification
1. Visit `http://localhost:3000/admin/ai_manager/settlements`
2. Confirm settlements grouped by celestial body
3. Confirm health badges reflect real mission status
4. Confirm counts are accurate

---

## Task 4B-3: AI Manager Dashboard Breadcrumb + Status Bar

**Priority:** LOW
**Estimated Time:** 45 minutes
**Risk Level:** LOW
**Agent:** GPT-4.1
**Dependencies:** AI Manager Tasks 1-4 complete, Task 4B-R1 complete

### Objective
Add a persistent status bar to the AI Manager layout (Task 1's `ai-manager-layout`) that shows galaxy-wide summary stats on every AI Manager page. This is the simplified version of the Phase 4B "SystemStatusBar" concept — no WebSockets, just ERB with real DB counts.

### Files to Modify
- `app/assets/stylesheets/admin/_ai_manager.scss` — add status bar styles
- `app/controllers/admin/ai_manager_controller.rb` — add `before_action`
- All AI Manager views — add status bar partial

### Step 1: Add before_action to controller
```ruby
before_action :load_status_bar_data

private

def load_status_bar_data
  @status_bar = {
    total_settlements: Settlement::BaseSettlement.count,
    active_missions: Mission.where(status: :in_progress).count,
    failed_missions: Mission.where(status: [:failed, :stalled]).count,
    total_decisions: AiDecisionLog.count
  }
end
```

### Step 2: Create `app/views/admin/ai_manager/_status_bar.html.erb`
```erb
<div class="ai-status-bar">
  <div class="ai-status-item">
    🏙️ <strong><%= @status_bar[:total_settlements] %></strong>
    <span>Settlements</span>
  </div>
  <div class="ai-status-item">
    🚀 <strong class="<%= @status_bar[:active_missions] > 0 ? 'text-ok' : '' %>">
      <%= @status_bar[:active_missions] %>
    </strong>
    <span>Active Missions</span>
  </div>
  <div class="ai-status-item">
    ⚠️ <strong class="<%= @status_bar[:failed_missions] > 0 ? 'text-warn' : '' %>">
      <%= @status_bar[:failed_missions] %>
    </strong>
    <span>Failed/Stalled</span>
  </div>
  <div class="ai-status-item">
    🧠 <strong><%= @status_bar[:total_decisions] %></strong>
    <span>AI Decisions</span>
  </div>
  <div class="ai-status-item" style="margin-left: auto; font-size: 0.7rem; color: #4a6080;">
    Updated: <%= Time.current.strftime('%H:%M:%S') %>
  </div>
</div>
```

### Step 3: Add to `_ai_manager.scss`
```scss
.ai-status-bar {
  grid-area: header;
  display: flex;
  align-items: center;
  gap: 2rem;
  padding: 0.5rem 1.5rem;
  background: rgba(0, 20, 50, 0.8);
  border-bottom: 1px solid rgba(0, 170, 255, 0.2);
  font-size: 0.8rem;

  .ai-status-item {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    color: #6aa0cc;

    strong {
      color: #e8f5ff;
      font-size: 1rem;
    }

    .text-ok   { color: #4ade80; }
    .text-warn { color: #facc15; }
  }
}
```

### Step 4: Add `<%= render 'status_bar' %>` at the top of `<main class="ai-manager-main">` in ALL AI Manager views.

### Verification
Visit any AI Manager page and confirm the status bar shows real counts at the top of the main content area.

---

## What Was Intentionally Excluded

The following from the original Phase 4B spec are **out of scope** for now:

- **React components** — no React in this codebase
- **WebSocket real-time updates** — requires ActionCable setup, separate project
- **User navigation preferences table** — database migration, no gameplay value yet
- **`/api/admin/systems` endpoints** — no API layer exists
- **Galaxy Selector dropdown** — complex, low value for current team size
- **Inter-settlement resource flow visualization** — requires charting library

These can be revisited once the ERB foundation is solid and real-time data becomes a gameplay priority.

