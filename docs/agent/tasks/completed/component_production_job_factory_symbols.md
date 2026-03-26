# Task: ComponentProductionJob Factory Status Symbols (~9 specs)

**Priority**: HIGH  
**Est. time**: 10 min  
**Specs**: spec/models/component_production_job_spec.rb (~9 → 0)  
**Files**: spec/factories/component_production_jobs.rb (status strings → symbols)  

## Confirmed Issue
Factory uses strings everywhere:
- default: `status { 'pending' }`
- traits: `'in_progress'`, `'completed'`, etc.
→ enum can't map → nil status → validates fails.

Model enum/scopes perfect ✓

## Exact 5-Line Fix
Replace ALL status strings with symbols:
```ruby
status { :pending }  # was 'pending'

trait :in_progress do
  status { :in_progress }  # was 'in_progress'
  # ...
end

trait :completed do
  status { :completed }    # was 'completed'
  # ...
end

trait :failed do
  status { :failed }       # was 'failed'
  # ...
end
NO other changes.

Verification
text
rspec spec/models/component_production_job_spec.rb → 0
rspec spec/models/*job_spec.rb → stable
