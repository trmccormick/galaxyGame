# 2026-04-10-HIGH-FEATURE-SHELL PRINTING JOB STATUS FACTORY VALIDATION TICK

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** FEATURE
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: ShellPrintingJob Factory Status + Validation + process_tick (6 specs)

**Priority**: HIGH  
**Est. time**: 45-60 min  
**Specs**: spec/models/shell_printing_job_spec.rb (15 ex, 6 fail → 0)

---

## Original Content

# Task: ShellPrintingJob Factory Status + Validation + process_tick (6 specs)

**Priority**: HIGH  
**Est. time**: 45-60 min  
**Specs**: spec/models/shell_printing_job_spec.rb (15 ex, 6 fail → 0)  
**Files**: spec/factories/shell_printing_jobs.rb, app/models/shell_printing_job.rb  
**Precedent**: ComponentProductionJob model/factory pattern (enum status, validates presence, process_tick(delta))  

## Issue Summary
From RSpec:  
- Factory creates job.status nil (missing default/trait)  
- Blocks start!/complete! expects, update!(progress_hours) → "Status can't be blank"  
- process_tick no-op (change by 0.0)  
Full output in chat history.  

## Diagnostics (Run First)
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/shell_printing_job_spec.rb:50 --order defined'
grep -n "factory :shell_printing_job\|status" spec/factories/shell_printing_jobs.rb
grep -n "validates :status\|process_tick\|progress_hours" app/models/shell_printing_job.rb
cat spec/factories/shell_printing_jobs.rb  # full factory
Expected Root Causes
Factory missing status { :pending } or sequence

Model missing validates :status, presence: true

def process_tick(delta) stubbed/not impl (should progress_hours += delta; save!; check complete)

Surgical Fix Steps (Approval Required)
Factory: Add status { :pending } to default (or trait if variants needed)

Model:

ruby
enum status: { pending: 0, in_progress: 1, completed: 2, failed: 3, cancelled: 4 }
validates :status, presence: true
# Match ComponentProductionJob#process_tick
def process_tick(delta_hours)
  update!(progress_hours: progress_hours + delta_hours)
  complete! if progress_hours >= total_hours
end
NO touch: Don't alter spec, integration, or other models

Verification
rspec spec/models/shell_printing_job_spec.rb → 0 failures

rspec spec/models/*job*_spec.rb → no new regressions

Log any blueprint/data mismatches (backlog if found)

Completion Report Template
Diagnostics output

Files changed (diff)

RSpec results (isolated + jobs cluster)

Issues discovered (if any)
