# Fix ItemLookupService

## CRITICAL CONTEXT — DOCKER VOLUME MOUNT
**ALL AGENTS MUST READ:**
Host path:      ./data/json-data/
Container path: /home/galaxy_game/app/data/
These are the SAME directory via Docker volume mount.
NEVER hardcode either path in Ruby files or specs.
ALWAYS use GalaxyGame::Paths constants instead.
The constants exist specifically to handle this abstraction.

## Issue
~7 failures: spec/services/lookup/item_lookup_service_spec.rb

## Fix
File to edit: app/services/lookup/item_lookup_service.rb

Change 1 — remove test env guard:

```ruby
# FROM:
@items = load_items unless Rails.env.test?
# TO:
@items = load_items
```

Change 2 — replace hardcoded paths with constants:

```ruby
# FROM:
ITEM_PATHS = {
  'consumable' => Rails.root.join('app', 'data', 'items', 'consumable'),
  'container'  => Rails.root.join('app', 'data', 'items', 'container'),
  'equipment'  => Rails.root.join('app', 'data', 'items', 'equipment'),
  'material'   => Rails.root.join('app', 'data', 'items', 'material')
}.freeze
# TO:
ITEM_PATHS = {
  'consumable' => GalaxyGame::Paths::CONSUMABLE_ITEMS_PATH,
  'container'  => GalaxyGame::Paths::CONTAINER_ITEMS_PATH,
  'equipment'  => GalaxyGame::Paths::EQUIPMENT_ITEMS_PATH,
  'tool'       => GalaxyGame::Paths::TOOL_ITEMS_PATH
}.freeze
```

Also remove the base_path method's test env branch entirely

## Tasks
1. Edit app/services/lookup/item_lookup_service.rb
2. Remove test env guard from @items = load_items
3. Replace ITEM_PATHS with GalaxyGame::Paths constants
4. Remove base_path test env branch
5. Run: rspec spec/services/lookup/item_lookup_service_spec.rb
6. Verify all specs pass
7. Commit: Fix ItemLookupService — use GalaxyGame::Paths constants, remove test env guard

## Success Criteria
- All ~7 failures resolved
- No hardcoded paths
- No test env guards
- Uses GalaxyGame::Paths constants

## Priority
MEDIUM — part of LookupService cluster fixes

## Time Estimate
15 minutes

## Agent Assignment
GPT-4.1 (service file edits)