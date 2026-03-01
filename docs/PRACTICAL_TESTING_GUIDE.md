# Practical Testing Guide for Galaxy Game

## Service Namespace Integrity (AIManager, Ceres, Mars, etc.)

### Mandate: Nested Module Definitions

For all game services (including AIManager, Ceres, Mars, and future expansions), you **must** use nested module definitions in Ruby files. This means:

```
module AIManager
  module Testing
    class PerformanceMonitor
      # ...
    end
  end
end
```

**Do NOT use the compact `module AIManager::Testing` syntax** for service classes. Zeitwerk (Rails' autoloader) may fail to resolve the parent module if it is not already loaded, leading to `NameError` exceptions and autoloading failures.

### Directory Structure

- Each namespace must have a matching directory structure. For example, `AIManager::Testing::PerformanceMonitor` must be in `app/services/ai_manager/testing/performance_monitor.rb`.
- If a namespace module (e.g., `AIManager::Testing`) is used, ensure there is **not** a file named `app/services/ai_manager/testing.rb` that conflicts with the `app/services/ai_manager/testing/` directory. If a namespace file is needed, it should only define the module and not contain logic or require statements.

### RSpec and Autoloading

- All specs for namespaced services must require `rails_helper` (not `spec_helper`).
- Do not use `require_relative` for app/services code. Rely on Rails-native autoloading.
- If you encounter `NameError: uninitialized constant`, check for:
  - Incorrect or missing nested module definitions
  - Directory/file conflicts (see above)
  - Missing namespace files (e.g., `ai_manager/testing.rb` should only define the module)

### Verification

- After any structural or namespace change, run:
  - `bin/rails zeitwerk:check` (to verify autoloading compliance)
  - The relevant RSpec suite

---

This guide is a living document. Update it whenever new namespace or autoloading patterns are introduced.
