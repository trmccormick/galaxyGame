# Task: ComponentProductionJob Remaining Specs (~9 failures)

**Priority**: MEDIUM  
**Est. time**: 45-60 min  
**Specs**: spec/models/component_production_job_spec.rb (~9 fail → 0)  
**Context**: Session C: model restored (21/30 specs), remaining post-model verification  
**Files**: app/models/component_production_job.rb + related  

## Diagnostics (Run First)
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/models/component_production_job_spec.rb'
grep -n "process_tick\|status\|scopes" app/models/component_production_job.rb
cat spec/factories/component_production_jobs.rb | head -30
```
Expected Scope
Scopes (active/in_progress/completed)

process_tick logic/guards

Edge cases (fail/cancel, progress calc)

Factory traits alignment

Surgical Workflow
Run diagnostics → paste full RSpec + grep output

Synthesis: failure lines + shared roots + fix plan

[Approval] Impl bounded changes matching ShellPrintingJob/Component precedent

Verify: isolated 0 failures + job cluster no regressions

Verification Commands
rspec spec/models/component_production_job_spec.rb → 0

rspec spec/models/*job_spec.rb → stable

Commit: "Complete ComponentProductionJob specs (~9→0)"
