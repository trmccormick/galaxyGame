# 2026-04-22-HIGH-BUG-FIX-SHELL PRINTING JOB FACTORY STRING STATUS FIX

**Agent:** GPT-4.1 (0.25x)
**Priority:** HIGH
**Type:** BUG-FIX
**Status:** BACKLOG

## Context
Migrated from backlog_april_2026 archive.

## Summary
# Task: ShellPrintingJob Factory Traits Symbol Fix (6 specs)

**Priority**: HIGH  
**Est. time**: 15 min  
**Specs**: spec/models/shell_printing_job_spec.rb (15→0)

---

## Original Content

# Task: ShellPrintingJob Factory Traits Symbol Fix (6 specs)

**Priority**: HIGH  
**Est. time**: 15 min  
**Specs**: spec/models/shell_printing_job_spec.rb (15→0)  
**Files**: spec/factories/shell_printing_jobs.rb (trait statuses only)  

## Root Cause Confirmed
- Model perfect: enum/validates/process_tick all present  
- Factory default good: `status { :pending }`  
- Traits broken: `status { 'in_progress' }` → string not enum-mapped → nil  

## Exact Fix
In `spec/factories/shell_printing_jobs.rb` **change traits only**:
```ruby
trait :in_progress do
  status { :in_progress }  # symbol, was string
  started_at { Time.current }
  progress_hours { 5.0 }
end

trait :completed do
  status { :completed }    # symbol, was string
  started_at { 1.day.ago }
  completed_at { Time.current }
  progress_hours { 10.0 }
end
NO other changes.

Verification
rspec spec/models/shell_printing_job_spec.rb → 0 failures

rspec spec/models/*job_spec.rb → no regressions

Commit: "Fix ShellPrintingJob factory traits symbols (6 specs)"
