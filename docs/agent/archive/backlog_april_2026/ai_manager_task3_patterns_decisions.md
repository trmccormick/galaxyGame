# Task 3: Fix Patterns Page + Clean Up Decisions Page

**Priority:** MEDIUM  
**Estimated Time:** 1 hour  
**Risk Level:** LOW (view changes only, minimal controller)  
**Agent:** GPT-4.1 (Copilot)  
**Dependencies:** Task 1 (SCSS + layout) must be complete first  

---

## 🎯 Objective

Two focused fixes:

1. **Patterns page** — replace non-functional JavaScript `alert()` buttons with a real form submission that uses the existing planner route. Load actual pattern names from controller instead of hardcoded HTML options.
2. **Decisions page** — apply Task 1 layout classes, fix stat cards to show real counts from `@decisions`.

---

## 📁 Files to Modify

- `app/views/admin/ai_manager/patterns.html.erb` — replace JS alerts, apply layout
- `app/views/admin/ai_manager/decisions.html.erb` — apply layout, wire stat cards
- `app/controllers/admin/ai_manager_controller.rb` — update `patterns` action only

---

## 🛠️ Step 1: Update `patterns` Controller Action

Find:
```ruby
def patterns
  # TODO: Load AI patterns for testing
  @patterns = []
end
```

Replace with:
```ruby
def patterns
  @patterns = []
  @available_patterns = [
    { id: 'mars-terraforming',  label: 'Mars Terraforming' },
    { id: 'venus-industrial',   label: 'Venus Industrial' },
    { id: 'titan-fuel',         label: 'Titan Fuel Mining' },
    { id: 'asteroid-mining',    label: 'Asteroid Mining' },
    { id: 'europa-water',       label: 'Europa Water Extraction' }
  ]
end
```

---

## 🛠️ Step 2: Replace `patterns.html.erb`

Replace entire file with:

```erb
<div class="ai-manager-layout">

  <aside class="ai-manager-sidebar">
    <h3>🤖 AI Manager</h3>
    <%= link_to "📊 Dashboard",   admin_ai_manager_path,             class: "ai-manager-nav-link" %>
    <%= link_to "🚀 Missions",    admin_ai_manager_missions_path,    class: "ai-manager-nav-link" %>
    <%= link_to "🧠 Decisions",   admin_ai_manager_decisions_path,   class: "ai-manager-nav-link" %>
    <%= link_to "📋 Planner",     admin_ai_manager_planner_path,     class: "ai-manager-nav-link" %>
    <%= link_to "🎯 Patterns",    admin_ai_manager_patterns_path,    class: "ai-manager-nav-link active" %>
    <%= link_to "📈 Performance", admin_ai_manager_performance_path, class: "ai-manager-nav-link" %>
    <%= link_to "🧪 Testing",     "/admin/ai_manager/testing",       class: "ai-manager-nav-link" %>
    <h3>Admin</h3>
    <%= link_to "← Dashboard", admin_dashboard_path, class: "ai-manager-nav-link" %>
  </aside>

  <header class="ai-manager-header">
    <h1>AI MANAGER — PATTERN ANALYSIS</h1>
    <div class="header-meta">
      Pattern Library: <span class="status-ok"><%= @available_patterns.size %> patterns available</span>
    </div>
  </header>

  <main class="ai-manager-main">

    <%# ── Pattern Test Runner — links to Planner ── %>
    <div class="ai-card">
      <h2>🧪 Pattern Test Runner</h2>
      <p style="color: #6aa0cc; font-size: 0.875rem; margin-bottom: 1rem;">
        Select a pattern below to run it through the Mission Planner simulator.
      </p>
      <div style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: flex-end;">
        <% @available_patterns.each do |pattern| %>
          <%= link_to pattern[:label],
                admin_ai_manager_planner_path(pattern: pattern[:id], tech_level: 'standard', timeline_years: 10, budget_gcc: 1_000_000, priority: 'balanced'),
                class: "ai-btn ai-btn--secondary" %>
        <% end %>
      </div>
      <p style="color: #4a6080; font-size: 0.75rem; margin-top: 1rem;">
        Clicking a pattern opens it in the Mission Planner with default parameters.
      </p>
    </div>

    <%# ── Pattern Types Reference ── %>
    <div class="ai-card">
      <h2>📋 Pattern Types</h2>
      <table class="ai-table">
        <thead>
          <tr>
            <th>Category</th>
            <th>Description</th>
            <th>Examples</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><span class="ai-badge ai-badge--info">Terraforming</span></td>
            <td>Planetary transformation missions</td>
            <td>Mars, Venus</td>
          </tr>
          <tr>
            <td><span class="ai-badge ai-badge--success">Resource Extraction</span></td>
            <td>Mining and harvesting operations</td>
            <td>Titan, Asteroids, Europa</td>
          </tr>
          <tr>
            <td><span class="ai-badge ai-badge--warning">Infrastructure</span></td>
            <td>Base building and orbital construction</td>
            <td>Station construction, habitats</td>
          </tr>
          <tr>
            <td><span class="ai-badge ai-badge--neutral">Research</span></td>
            <td>Scientific investigation and data collection</td>
            <td>Survey missions</td>
          </tr>
        </tbody>
      </table>
    </div>

    <%# ── Loaded Patterns (future) ── %>
    <% if @patterns.any? %>
      <div class="ai-card">
        <h2>🎯 Loaded Patterns</h2>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 1rem;">
          <% @patterns.each do |pattern| %>
            <div class="ai-card" style="margin-bottom: 0;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem;">
                <strong><%= pattern[:name] %></strong>
                <span class="ai-badge ai-badge--<%= pattern[:active] ? 'success' : 'neutral' %>">
                  <%= pattern[:active] ? 'ACTIVE' : 'INACTIVE' %>
                </span>
              </div>
              <p style="color: #6aa0cc; font-size: 0.8rem;"><%= pattern[:description] %></p>
              <%= link_to "Open in Planner",
                    admin_ai_manager_planner_path(pattern: pattern[:id]),
                    class: "ai-btn ai-btn--primary ai-btn--small" %>
            </div>
          <% end %>
        </div>
      </div>
    <% else %>
      <div class="ai-placeholder">
        No dynamic patterns loaded. Use the Pattern Test Runner above to test available patterns via the Mission Planner.
      </div>
    <% end %>

  </main>
</div>
```

---

## 🛠️ Step 3: Update `decisions.html.erb`

Replace the outer wrapper and stat cards only. Keep the decision table and type reference section intact. Replace entire file with:

```erb
<div class="ai-manager-layout">

  <aside class="ai-manager-sidebar">
    <h3>🤖 AI Manager</h3>
    <%= link_to "📊 Dashboard",   admin_ai_manager_path,             class: "ai-manager-nav-link" %>
    <%= link_to "🚀 Missions",    admin_ai_manager_missions_path,    class: "ai-manager-nav-link" %>
    <%= link_to "🧠 Decisions",   admin_ai_manager_decisions_path,   class: "ai-manager-nav-link active" %>
    <%= link_to "📋 Planner",     admin_ai_manager_planner_path,     class: "ai-manager-nav-link" %>
    <%= link_to "🎯 Patterns",    admin_ai_manager_patterns_path,    class: "ai-manager-nav-link" %>
    <%= link_to "📈 Performance", admin_ai_manager_performance_path, class: "ai-manager-nav-link" %>
    <%= link_to "🧪 Testing",     "/admin/ai_manager/testing",       class: "ai-manager-nav-link" %>
    <h3>Admin</h3>
    <%= link_to "← Dashboard", admin_dashboard_path, class: "ai-manager-nav-link" %>
  </aside>

  <header class="ai-manager-header">
    <h1>AI MANAGER — DECISION LOG</h1>
    <div class="header-meta">
      Total Decisions: <span class="status-ok"><%= @decisions.count %></span>
    </div>
  </header>

  <main class="ai-manager-main">

    <%# ── Stats ── %>
    <div class="ai-metrics-grid">
      <div class="ai-metric-card">
        <div class="metric-label">Total Decisions</div>
        <div class="metric-value"><%= @decisions.count %></div>
        <div class="metric-trend neutral">logged</div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Decision Types</div>
        <div class="metric-value"><%= @decisions.map(&:decision_type).uniq.count %></div>
        <div class="metric-trend neutral">unique types</div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Celestial Bodies</div>
        <div class="metric-value"><%= @decisions.map(&:celestial_body_id).uniq.compact.count %></div>
        <div class="metric-trend neutral">involved</div>
      </div>
      <div class="ai-metric-card">
        <div class="metric-label">Most Recent</div>
        <div class="metric-value" style="font-size: 1rem;">
          <%= @decisions.first&.created_at&.strftime('%m/%d %H:%M') || '—' %>
        </div>
        <div class="metric-trend neutral">last decision</div>
      </div>
    </div>

    <%# ── Decision Log Table ── %>
    <div class="ai-card">
      <h2>🧠 AI Decision Log</h2>
      <% if @decisions.empty? %>
        <div class="ai-placeholder">
          <div style="font-size: 3rem; margin-bottom: 1rem;">🧠</div>
          No AI decisions logged yet. Decision tracking will appear here as the AI makes operational choices.
        </div>
      <% else %>
        <table class="ai-table">
          <thead>
            <tr>
              <th>Time</th>
              <th>Celestial Body</th>
              <th>Type</th>
              <th>Reasoning</th>
              <th>Outcome</th>
              <th>Lessons Learned</th>
            </tr>
          </thead>
          <tbody>
            <% @decisions.each do |log| %>
              <tr>
                <td><%= log.created_at.strftime('%Y-%m-%d %H:%M') %></td>
                <td><%= log.celestial_body&.name || '—' %></td>
                <td><span class="ai-badge ai-badge--info"><%= log.decision_type %></span></td>
                <td style="max-width: 300px; font-size: 0.8rem;"><%= log.reasoning %></td>
                <td><%= log.outcome.is_a?(Hash) ? log.outcome.to_json : log.outcome %></td>
                <td><%= (log.metadata['lessons_learned'] if log.metadata).presence || '—' %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      <% end %>
    </div>

    <%# ── Decision Types Reference ── %>
    <div class="ai-card">
      <h2>📋 Decision Types</h2>
      <table class="ai-table">
        <thead>
          <tr><th>Type</th><th>Description</th></tr>
        </thead>
        <tbody>
          <tr><td><span class="ai-badge ai-badge--success">Resource Allocation</span></td><td>Distributing limited resources across competing needs</td></tr>
          <tr><td><span class="ai-badge ai-badge--info">Contract Negotiation</span></td><td>Evaluating and negotiating supply contracts with NPCs</td></tr>
          <tr><td><span class="ai-badge ai-badge--warning">Mission Planning</span></td><td>Strategic decisions about mission priorities and timelines</td></tr>
          <tr><td><span class="ai-badge ai-badge--neutral">Settlement Operations</span></td><td>Day-to-day settlement activities and optimizations</td></tr>
        </tbody>
      </table>
    </div>

  </main>
</div>
```

---

## ✅ Verification

1. Visit `http://localhost:3000/admin/ai_manager/patterns`
   - Confirm pattern buttons link to planner (no `alert()` popups)
   - Confirm no JavaScript errors in console

2. Visit `http://localhost:3000/admin/ai_manager/decisions`
   - Confirm stat cards show real counts
   - Confirm decision table renders real data or empty state message

---

## 🚫 Out of Scope
- Building a real pattern management system
- Adding pattern activation/deactivation backend
- Controller changes beyond `patterns` action
