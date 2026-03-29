# Task: Fix Units::Computer#upgrade_efficiency spec

**Spec**: `spec/models/units/computer_spec.rb:38`
**Priority**: MEDIUM  
**Est. time**: 20 minutes  
**Files**: `app/models/units/computer.rb`

## Issue
Units::Computer#upgrade_efficiency increases efficiency upgrade value

text
Expected: Method returns/changes efficiency value on call  
Actual: Returns nil/unchanged (simple method logic failure)

## Diagnostic Commands
```bash
docker exec -it web bash -c "grep -n 'def upgrade_efficiency\|efficiency_upgrade' app/models/units/computer.rb"
docker exec -it web bash -c "grep -A10 -B5 'def upgrade_efficiency' app/models/units/computer.rb || echo 'Method missing'"
docker exec -it web bash -c "cat spec/models/units/computer_spec.rb -A50 | grep -A5 -B5 'upgrade_efficiency'"
```

## Expected patterns (check these)
1. **Missing return**: `def upgrade_efficiency; self.efficiency_upgrade += 1; end` → needs explicit `return`
2. **Wrong attr**: Uses `efficiency` instead of `efficiency_upgrade`
3. **No mutation**: Reads attr but doesn't change it
4. **Nil guard missing**: `efficiency_upgrade.nil? ? 1 : efficiency_upgrade + 1`

## Surgical Fix Template
```ruby
def upgrade_efficiency
  self.efficiency_upgrade = (efficiency_upgrade || 0) + 1
end
```

## What NOT to do
- Don't add validations/callbacks
- Don't touch blueprint loading
- Don't modify other computer methods
- Don't change class inheritance

## Verification
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/units/computer_spec.rb:38 --format documentation'
Expected: 1 example, 0 failures

text

## Completion Report Required
Line numbers changed

Before/after method code

rspec output (full summary line)

Any unexpected failures found