# TASK: Job System Phase 4b — Build ImportOrder Model and Migrate Logistics Call Sites
**Status**: BACKLOG
**Priority**: HIGH
**Type**: architecture
**Created**: 2026-04-21
**Last Updated**: 2026-04-21

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Schema is fully specified. Migration and model creation is mechanical.
Call site migration is explicit. Requires care but no architectural judgment.
**Supervision Level**: 🔴 Watched carefully

> ⚠️ Read the logistics architecture spec before touching anything.
> Import orders are NOT jobs. Never create a Job record for logistics.
> Earth is a seeded Settlement record — never hardcode 'earth' as a string.

---

## Context

Task 4a must be complete before this task runs. After Task 4a, the remaining
`ResourceJob` references in service files are all logistics call sites:
`earth_import`, `scheduled_import`, `contracted_harvesting`.

These are being replaced by the new `ImportOrder` model. This task creates
the model and migrates all remaining logistics call sites.

**Read before starting:**
- `docs/architecture/logistics/logistics_architecture.md` — REQUIRED
- `docs/architecture/ai_manager/astrolift_corporation.md` — REQUIRED
- `galaxy_game/app/models/job.rb` — confirm Job exists (Task 1 complete)
- `galaxy_game/db/seeds.rb` — check if Earth settlement and AstroLift are seeded

---

## Problem Statement

`ResourceJob` logistics call sites (`earth_import`, `scheduled_import`,
`contracted_harvesting`) are mismodeled as production jobs. They are logistics
operations — resource transit between settlements. They belong in `ImportOrder`.

---

## Step 0 — Pre-flight Checks

### Confirm Task 4a complete
```bash
grep -n "earth_import\|scheduled_import\|contracted_harvesting" \
  galaxy_game/app/services/resource/acquisition.rb \
  galaxy_game/app/services/resource/job_processor.rb \
  galaxy_game/app/services/ai_manager/resource_planner.rb
```
These should be the ONLY remaining ResourceJob references. If production
call sites still exist — Task 4a is not done. Stop.

### Check Earth settlement seed
```bash
grep -rn "earth\|Earth" galaxy_game/db/seeds.rb
```
If Earth is not seeded as a Settlement — add to Synthesis Report.
Do not proceed with migration until Earth settlement exists.

### Check AstroLift seed
```bash
grep -rn "astrolift\|AstroLift" galaxy_game/db/seeds.rb
```
If AstroLift is not seeded — add to Synthesis Report.

---

## ImportOrder Schema

```ruby
# db/migrate/TIMESTAMP_create_import_orders.rb
create_table :import_orders do |t|
  t.references :destination_settlement, null: false,
               foreign_key: { to_table: :settlements }
  t.references :origin_settlement, null: false,
               foreign_key: { to_table: :settlements }
  t.references :initiated_by, polymorphic: true, null: false
  t.string :item_type, null: false
  t.integer :quantity, null: false
  t.integer :status, default: 0, null: false
  t.decimal :cost_gcc, precision: 12, scale: 2
  t.decimal :eap_at_order_time, precision: 12, scale: 2
  t.boolean :emergency, default: false, null: false
  t.datetime :arrives_at
  t.timestamps
end

add_index :import_orders, :status
add_index :import_orders, [:destination_settlement_id, :status]
add_index :import_orders, [:initiated_by_type, :initiated_by_id]
```

## ImportOrder Model

```ruby
# app/models/import_order.rb
class ImportOrder < ApplicationRecord
  belongs_to :destination_settlement,
             class_name: 'Settlement::BaseSettlement'
  belongs_to :origin_settlement,
             class_name: 'Settlement::BaseSettlement'
  belongs_to :initiated_by, polymorphic: true

  enum status: {
    pending: 0,
    in_transit: 1,
    delivered: 2,
    cancelled: 3
  }

  validates :item_type, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :arrives_at, presence: true

  # Luna-first transit time constant
  # Replace with route-based calculation in Phase 3
  EARTH_LUNA_TRANSIT_DAYS = 3

  scope :active, -> { where(status: [:pending, :in_transit]) }
  scope :arriving_soon, -> { in_transit.where('arrives_at <= ?', Time.current) }

  def deliver!
    update!(status: :delivered)
    # Output delivery to destination inventory handled by caller
  end
end
```

⚠️ Verify `Settlement::BaseSettlement` is the correct class name before using it.
Check: `grep -rn "class BaseSettlement" galaxy_game/app/models/`

## ImportOrder Factory

```ruby
# spec/factories/import_orders.rb
FactoryBot.define do
  factory :import_order do
    association :destination_settlement, factory: :settlement
    association :origin_settlement, factory: :settlement
    association :initiated_by, factory: :player
    item_type { 'iron_plate' }
    quantity { 100 }
    status { :pending }
    cost_gcc { 5000.00 }
    eap_at_order_time { 5500.00 }
    emergency { false }
    arrives_at { 3.days.from_now }

    trait :in_transit do
      status { :in_transit }
      arrives_at { 1.day.from_now }
    end

    trait :delivered do
      status { :delivered }
      arrives_at { 1.day.ago }
    end

    trait :emergency do
      emergency { true }
      arrives_at { 12.hours.from_now }
    end

    trait :arriving_now do
      status { :in_transit }
      arrives_at { 10.minutes.ago }
    end
  end
end
```

---

## Implementation Steps

### Step 1 — Generate migration
```bash
docker exec web bash -c 'bundle exec rails generate migration CreateImportOrders'
```
Fill with schema above.

### Step 2 — Run migration
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rails db:migrate'
```

### Step 3 — Create ImportOrder model
Use model code above exactly. Verify Settlement class name first.

### Step 4 — Create factory
Use factory code above exactly.

### Step 5 — Seed Earth settlement and AstroLift if not present
If seeds check in Step 0 showed missing records, add to `db/seeds.rb`:

```ruby
# Earth as logistics origin settlement
# Adjust class names and attributes to match actual Settlement schema
earth_settlement = Settlement::BaseSettlement.find_or_create_by!(
  identifier: 'earth_depot'
) do |s|
  s.name = 'Earth Depot'
  s.settlement_type = :logistics_hub
end
```

⚠️ Check actual Settlement schema before writing seed code.
If `settlement_type` doesn't support `:logistics_hub` — use the closest
existing type and note it in completion report.

### Step 6 — Migrate logistics call sites

For each remaining `ResourceJob.create!` with logistics job_type:

```ruby
# Before
job = ResourceJob.create!(
  job_type: 'earth_import',
  settlement: destination_settlement,
  quantity: quantity,
  completes_at: Time.current + 3.days,
  ...
)

# After
earth = Settlement::BaseSettlement.find_by!(identifier: 'earth_depot')
order = ImportOrder.create!(
  item_type: item_type,
  quantity: quantity,
  origin_settlement: earth,
  destination_settlement: destination_settlement,
  initiated_by: initiated_by,
  arrives_at: Time.current + ImportOrder::EARTH_LUNA_TRANSIT_DAYS.days,
  cost_gcc: calculated_cost,
  eap_at_order_time: calculated_eap,
  emergency: emergency_flag
)
```

Repeat for `scheduled_import` and `contracted_harvesting` call sites —
all map to `ImportOrder`.

### Step 7 — Verify no logistics ResourceJob references remain
```bash
grep -n "earth_import\|scheduled_import\|contracted_harvesting\|ResourceJob" \
  galaxy_game/app/services/resource/acquisition.rb \
  galaxy_game/app/services/resource/job_processor.rb \
  galaxy_game/app/services/ai_manager/resource_planner.rb
```
Expected: no output.

---

## Synthesis Report Format
```
PRE-FLIGHT
Task 4a complete (only logistics references remain): YES/NO
Earth settlement seeded: YES/NO
AstroLift seeded: YES/NO
Settlement class name confirmed: [class name]

LOGISTICS CALL SITES TO MIGRATE
[file] line [N] — job_type: [type] — [description]

PROPOSED CHANGES
[file] line [N] — ResourceJob.create!(earth_import) → ImportOrder.create!(...)

SEED CHANGES NEEDED
[describe or NONE]

RISK
[any shared code, polymorphic types, string comparisons referencing 'ResourceJob']

READY TO APPLY? — waiting for approval
```

---

## Testing Sequence
1. ImportOrder model spec:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/import_order_spec.rb'
```

2. Resource services:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/resource/'
```

3. Full services:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/'
```

4. Full suite:
```bash
docker exec web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec > /home/galaxy_game/log/rspec_full_$(date +%s).log 2>&1'
```

---

## Acceptance Criteria
- [ ] `import_orders` table created and migrated
- [ ] `ImportOrder` model exists with correct schema
- [ ] Factory exists with pending, in_transit, delivered, emergency traits
- [ ] Earth settlement seeded
- [ ] All logistics call sites migrated to `ImportOrder`
- [ ] Zero `ResourceJob` references remain in resource and AI manager services
- [ ] ImportOrder model spec green
- [ ] Resource service specs green
- [ ] No regressions

---

## Stop Conditions
- Task 4a not complete — stop
- Earth settlement class name or attributes don't match schema — stop, report
- A logistics call site passes attributes with no clear ImportOrder mapping — stop, report
- Migration fails — stop, report exact error

---

## Commit Instructions
```bash
# Model and migration
git add galaxy_game/db/migrate/ \
        galaxy_game/app/models/import_order.rb \
        galaxy_game/spec/factories/import_orders.rb \
        galaxy_game/spec/models/import_order_spec.rb
git commit -m "arch: ImportOrder model — logistics transit between settlements, replaces ResourceJob logistics"

# Service migration
git add galaxy_game/app/services/resource/acquisition.rb \
        galaxy_game/app/services/resource/job_processor.rb \
        galaxy_game/app/services/ai_manager/resource_planner.rb \
        galaxy_game/db/seeds.rb
git commit -m "refactor: resource services — migrate logistics call sites from ResourceJob to ImportOrder"
```

---

## Dependencies
**Blocked by**: Task 4a (production call sites must be migrated first)
**Blocks**: Task 7 (ResourceJob can only be retired after 4a + 4b both complete)
**Read**: `docs/architecture/logistics/logistics_architecture.md`
**Read**: `docs/architecture/ai_manager/astrolift_corporation.md`

## Follow-up Tasks (do not implement now)
- ImportOrder delivery worker — poll `arriving_soon` and call `deliver!`
- AstroLift AI Manager manifest generation logic
- Player-visible import order UI
- Route model for Phase 3 cycler network
