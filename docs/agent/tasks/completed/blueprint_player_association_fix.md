# Task: Fix Blueprint Player Association + ManufacturingService
## Assignee: GPT-4.1
## Priority: High (blocking manfacturing_service_spec:81)
## Branch: regional-view-phase2

---

## Problem

`ManufacturingService.manufacture` calls `owner.blueprints.find_by(name:)` but
`Player` has no `has_many :blueprints` association. `Blueprint belongs_to :player`
exists but the inverse is missing.

Error:
```
NoMethodError: undefined method 'blueprints' for an instance of Player
# ./app/services/manufacturing_service.rb:10
```

---

## Immediate Fix

Add to `app/models/player.rb`:
```ruby
has_many :blueprints, foreign_key: :player_id, dependent: :destroy
```

---

## Verify
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manfacturing_service_spec.rb:81 --format documentation 2>&1 | tail -20'
```

---

## Architectural Note (backlog — do NOT implement in this task)

Blueprint ownership is currently too narrow — only `player_id` on the schema.
In the full architecture, blueprints should be ownable by any entity:
- Players (personal blueprints)
- Organizations/Corporations (shared corporate blueprints)
- Settlements (site-specific blueprints)

This requires:
- Adding a polymorphic `owner` association to blueprints (owner_type/owner_id)
- Migration to add owner columns and populate from existing player_id
- Keeping player_id for backwards compatibility during transition
- Updating ManufacturingService to use owner polymorphically

Document this as a separate backlog task:
`blueprint_polymorphic_ownership.md`
