# Task 1: AI Manager SCSS File + 2-Pane Layout Standardization

**Priority:** HIGH  
**Estimated Time:** 1-2 hours  
**Risk Level:** LOW (styling only, no logic changes)  
**Agent:** GPT-4.1 (Copilot)  
**Dependencies:** None  

---

## 🎯 Objective

Create a dedicated `_ai_manager.scss` file with the neon blue theme and standardize ALL AI Manager views to use a consistent 2-pane layout. Remove all 3-pane layouts where the 3rd pane has no content. Do NOT change any Ruby/controller logic — styling and layout structure only.

---

## 📋 Exact Files to Create/Modify

### CREATE (new file):
- `app/assets/stylesheets/admin/_ai_manager.scss`

### MODIFY (layout structure only):
- `app/views/admin/ai_manager/index.html.erb`
- `app/views/admin/ai_manager/missions.html.erb`
- `app/views/admin/ai_manager/decisions.html.erb`
- `app/views/admin/ai_manager/planner.html.erb`
- `app/views/admin/ai_manager/patterns.html.erb`
- `app/views/admin/ai_manager/performance.html.erb`
- `app/views/admin/ai_manager/testing/index.html.erb`
- `app/views/admin/ai_manager/testing/performance.html.erb`
- `app/views/admin/ai_manager/testing/validation.html.erb`

### MODIFY (add import):
- `app/assets/stylesheets/admin/dashboard.scss` — add `@import 'ai_manager';` at the bottom

---

## 🎨 Step 1: Create `_ai_manager.scss`

Create this file at `app/assets/stylesheets/admin/_ai_manager.scss` with exactly this content:

```scss
// AI Manager Neon Blue Theme
// All AI Manager admin pages use this stylesheet

// ── Layout ─────────────────────────────────────────────────────────────────

.ai-manager-layout {
  display: grid;
  grid-template-columns: 220px 1fr;
  grid-template-rows: auto 1fr;
  grid-template-areas:
    "sidebar header"
    "sidebar main";
  min-height: 100vh;
  background: linear-gradient(135deg, #0a0a2e 0%, #1a1a4e 100%);
  color: #e8f5ff;
}

// ── Sidebar ────────────────────────────────────────────────────────────────

.ai-manager-sidebar {
  grid-area: sidebar;
  background: rgba(10, 10, 46, 0.95);
  border-right: 2px solid #00aaff;
  padding: 1.5rem 1rem;

  h3 {
    font-size: 0.75rem;
    font-weight: 700;
    letter-spacing: 0.1em;
    color: #00aaff;
    text-transform: uppercase;
    margin: 1.5rem 0 0.5rem;

    &:first-child {
      margin-top: 0;
    }
  }
}

.ai-manager-nav-link {
  display: block;
  padding: 0.5rem 0.75rem;
  margin-bottom: 0.25rem;
  border-radius: 4px;
  color: #a0c8ff;
  text-decoration: none;
  font-size: 0.875rem;
  transition: background 0.15s, color 0.15s;

  &:hover {
    background: rgba(0, 170, 255, 0.15);
    color: #e8f5ff;
  }

  &.active {
    background: rgba(0, 170, 255, 0.25);
    color: #00aaff;
    border-left: 3px solid #00aaff;
    font-weight: 600;
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

.ai-manager-header {
  grid-area: header;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid rgba(0, 170, 255, 0.3);
  background: rgba(10, 10, 46, 0.7);

  h1 {
    font-size: 1.25rem;
    font-weight: 700;
    color: #e8f5ff;
    letter-spacing: 0.05em;
    margin: 0 0 0.25rem;
  }

  .header-meta {
    font-size: 0.8rem;
    color: #6aa0cc;

    .status-ok { color: #4ade80; }
    .status-warn { color: #facc15; }
    .status-error { color: #f87171; }
  }
}

// ── Main Content ───────────────────────────────────────────────────────────

.ai-manager-main {
  grid-area: main;
  padding: 1.5rem;
  overflow-y: auto;
}

// ── Cards ──────────────────────────────────────────────────────────────────

.ai-card {
  background: rgba(26, 26, 78, 0.9);
  border: 1px solid rgba(0, 170, 255, 0.4);
  border-radius: 8px;
  padding: 1.25rem;
  margin-bottom: 1.25rem;
  color: #e8f5ff;

  h2, h3 {
    color: #00aaff;
    margin-top: 0;
  }
}

// ── Metrics Grid ───────────────────────────────────────────────────────────

.ai-metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.ai-metric-card {
  background: rgba(0, 40, 80, 0.8);
  border: 1px solid rgba(0, 170, 255, 0.4);
  border-radius: 8px;
  padding: 1rem;
  text-align: center;

  .metric-label {
    font-size: 0.75rem;
    color: #6aa0cc;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin-bottom: 0.5rem;
  }

  .metric-value {
    font-size: 1.75rem;
    font-weight: 700;
    color: #00aaff;
  }

  .metric-trend {
    font-size: 0.75rem;
    margin-top: 0.25rem;

    &.positive { color: #4ade80; }
    &.negative { color: #f87171; }
    &.neutral  { color: #6aa0cc; }
  }
}

// ── Tables ─────────────────────────────────────────────────────────────────

.ai-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;

  th {
    background: rgba(0, 40, 80, 0.9);
    color: #00aaff;
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.75rem;
    letter-spacing: 0.08em;
    padding: 0.75rem 1rem;
    text-align: left;
    border-bottom: 2px solid rgba(0, 170, 255, 0.4);
  }

  td {
    padding: 0.75rem 1rem;
    border-bottom: 1px solid rgba(0, 170, 255, 0.15);
    color: #e8f5ff;
  }

  tr:hover td {
    background: rgba(0, 170, 255, 0.05);
  }
}

// ── Buttons ────────────────────────────────────────────────────────────────

.ai-btn {
  display: inline-block;
  padding: 0.4rem 0.9rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  text-decoration: none;
  border: none;
  transition: opacity 0.15s;

  &:hover { opacity: 0.85; }

  &--primary {
    background: linear-gradient(45deg, #0066cc, #0088ff);
    color: white;
  }

  &--secondary {
    background: rgba(0, 100, 200, 0.3);
    border: 1px solid #0088ff;
    color: #a0c8ff;
  }

  &--danger {
    background: rgba(200, 30, 30, 0.4);
    border: 1px solid #f87171;
    color: #fca5a5;
  }

  &--small {
    padding: 0.25rem 0.6rem;
    font-size: 0.75rem;
  }
}

// ── Status Badges ──────────────────────────────────────────────────────────

.ai-badge {
  display: inline-block;
  padding: 0.2rem 0.5rem;
  border-radius: 3px;
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;

  &--success  { background: rgba(74, 222, 128, 0.2); color: #4ade80; border: 1px solid #4ade80; }
  &--warning  { background: rgba(250, 204, 21, 0.2);  color: #facc15; border: 1px solid #facc15; }
  &--error    { background: rgba(248, 113, 113, 0.2); color: #f87171; border: 1px solid #f87171; }
  &--info     { background: rgba(0, 170, 255, 0.2);   color: #00aaff; border: 1px solid #00aaff; }
  &--neutral  { background: rgba(100, 116, 139, 0.2); color: #94a3b8; border: 1px solid #94a3b8; }
}

// ── Alerts ─────────────────────────────────────────────────────────────────

.ai-alert {
  padding: 0.75rem 1rem;
  border-radius: 6px;
  margin-bottom: 0.75rem;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;

  a { color: inherit; text-decoration: underline; }

  &--warning { background: rgba(250, 204, 21, 0.1);  border-left: 4px solid #facc15; color: #fef08a; }
  &--error   { background: rgba(248, 113, 113, 0.1); border-left: 4px solid #f87171; color: #fca5a5; }
  &--info    { background: rgba(0, 170, 255, 0.1);   border-left: 4px solid #00aaff; color: #bae6fd; }
}

// ── Placeholder ────────────────────────────────────────────────────────────

.ai-placeholder {
  text-align: center;
  padding: 3rem;
  color: #4a6080;
  font-size: 0.9rem;
  border: 1px dashed rgba(0, 170, 255, 0.2);
  border-radius: 8px;
}
```

---

## 🏗️ Step 2: Standardize Layout Structure in ALL Views

Every AI Manager view must use this exact 2-pane wrapper structure. Replace whatever outer wrapper currently exists with:

```erb
<div class="ai-manager-layout">

  <%# ── Sidebar ── %>
  <aside class="ai-manager-sidebar">
    <h3>🤖 AI Manager</h3>
    <%= link_to "📊 Dashboard",   admin_ai_manager_path,             class: "ai-manager-nav-link #{controller.action_name == 'index' ? 'active' : ''}" %>
    <%= link_to "🚀 Missions",    admin_ai_manager_missions_path,    class: "ai-manager-nav-link #{controller.action_name == 'missions' ? 'active' : ''}" %>
    <%= link_to "🧠 Decisions",   admin_ai_manager_decisions_path,   class: "ai-manager-nav-link #{controller.action_name == 'decisions' ? 'active' : ''}" %>
    <%= link_to "📋 Planner",     admin_ai_manager_planner_path,     class: "ai-manager-nav-link #{controller.action_name == 'planner' ? 'active' : ''}" %>
    <%= link_to "🎯 Patterns",    admin_ai_manager_patterns_path,    class: "ai-manager-nav-link #{controller.action_name == 'patterns' ? 'active' : ''}" %>
    <%= link_to "📈 Performance", admin_ai_manager_performance_path, class: "ai-manager-nav-link #{controller.action_name == 'performance' ? 'active' : ''}" %>
    <%= link_to "🧪 Testing",     "/admin/ai_manager/testing",       class: "ai-manager-nav-link #{controller.action_name == 'testing' ? 'active' : ''}" %>
    <h3>Admin</h3>
    <%= link_to "← Dashboard", admin_dashboard_path, class: "ai-manager-nav-link" %>
  </aside>

  <%# ── Header ── %>
  <header class="ai-manager-header">
    <h1>PAGE TITLE HERE</h1>
    <div class="header-meta">
      System: <span class="status-ok">OPERATIONAL</span>
    </div>
  </header>

  <%# ── Main Content ── %>
  <main class="ai-manager-main">
    <%# PAGE CONTENT GOES HERE %>
  </main>

</div>
```

Apply this structure to every `.erb` file listed above. Keep all existing content inside `<main class="ai-manager-main">`. Replace all existing sidebar/nav/header HTML with the standardized version above. Update the page title `h1` appropriately per page.

**Per-page titles:**
- `index.html.erb` → `GALAXY GAME — AI MANAGER`
- `missions.html.erb` → `AI MANAGER — MISSIONS`
- `decisions.html.erb` → `AI MANAGER — DECISION LOG`
- `planner.html.erb` → `AI MANAGER — MISSION PLANNER`
- `patterns.html.erb` → `AI MANAGER — PATTERN ANALYSIS`
- `performance.html.erb` → `AI MANAGER — PERFORMANCE`
- `testing/index.html.erb` → `AI MANAGER — TESTING`
- `testing/performance.html.erb` → `AI MANAGER — TESTING PERFORMANCE`
- `testing/validation.html.erb` → `AI MANAGER — VALIDATION`

---

## 🔗 Step 3: Add SCSS Import

In `app/assets/stylesheets/admin/dashboard.scss` add at the bottom:

```scss
@import 'ai_manager';
```

**Do NOT create a `.css` file. The file must be `_ai_manager.scss` (with underscore prefix).**

---

## ✅ Verification

After implementation visit each page in the browser and confirm:
- Dark blue gradient background
- Blue-bordered sidebar on the left
- Active nav link highlighted in blue
- No green theme remnants
- No 3-pane layouts
- All pages share identical sidebar and header structure

**Do NOT change any Ruby code, controller logic, or instance variable usage.**  
**Do NOT remove any existing ERB content inside the main content area.**  
**CSS files must NOT be created — SCSS only.**

---

## 🚫 Out of Scope for This Task
- Wiring real data to placeholder content (separate task)
- Fixing hardcoded table data (separate task)
- Controller changes (separate task)
- Adding new features or sections
