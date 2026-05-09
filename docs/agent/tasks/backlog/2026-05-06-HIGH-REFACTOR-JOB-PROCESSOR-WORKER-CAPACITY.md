# TASK: JobProcessorWorker — Settlement Capacity and Job Promotion
**Status**: BACKLOG
**Priority**: HIGH
**Type**: refactor
**Created**: 2026-05-06
**Promote after**: Task A and Task B complete

---

## Agent Assignment
**Assigned To**: GPT-4.1 0x
**Why This Agent**: Worker logic, needs RSpec confirmation
**Supervision Level**: 🟡 Standard

---

## Context

Job lifecycle:
1. Job created → status: :pending, start_date: nil, completes_at: nil
   Materials removed from owner inventory at submission
2. Slot opens → start_date: Time.current,
   completes_at: start_date + production_time, status: :in_progress
3. Job completes → output added to inventory, status: :ready_to_claim
4. Cancelled before start → materials returned, status: :cancelled

**Depends on**: Task A (job_types on BaseUnit) and Task B (unit JSON files)

---

## Required Changes to JobProcessorWorker

### Responsibility 1 — Complete ready jobs (already exists)
Keep existing logic that marks in_progress jobs as ready_to_claim
when completes_at <= Time.current.

### Responsibility 2 — Promote pending jobs (new)

```ruby
def promote_pending_jobs
  # Find settlements with pending jobs
  settlement_ids = Job.where(status: :pending)
                      .distinct
                      .pluck(:settlement_id)

  settlement_ids.each do |settlement_id|
    settlement = Settlement::BaseSettlement.find(settlement_id)
    promote_jobs_for_settlement(settlement)
  end
end

def promote_jobs_for_settlement(settlement)
  # Get all job types with pending jobs at this settlement
  pending_by_type = Job.where(settlement: settlement, status: :pending)
                       .group(:job_type)
                       .count

  pending_by_type.each do |job_type, count|
    next if count == 0

    # Calculate available capacity for this job_type
    capable_units = settlement.base_units.select do |unit|
      unit.supports_job_type?(job_type)
    end

    total_capacity = capable_units.sum(&:max_concurrent_jobs)

    in_use = Job.where(
      settlement: settlement,
      job_type: job_type,
      status: :in_progress
    ).count

    available_slots = total_capacity - in_use
    next if available_slots <= 0

    # Promote pending jobs FIFO up to available slots
    jobs_to_promote = Job.where(
      settlement: settlement,
      job_type: job_type,
      status: :pending
    ).order(created_at: :asc).limit(available_slots)

    jobs_to_promote.each do |job|
      production_time = job.operational_data
                           &.dig('production_time_hours')
                           &.to_f || 1.0
      job.update!(
        status: :in_progress,
        start_date: Time.current,
        completes_at: Time.current + production_time.hours
      )
      Rails.logger.info("JobProcessorWorker: promoted Job##{job.id} " \
                        "to in_progress for #{settlement.name}")
    end
  end
end
```

### Update perform method:
```ruby
def perform
  Rails.logger.info("JobProcessorWorker: processing jobs")
  process_jobs(Job)
  promote_pending_jobs
end
```

---

## Acceptance Criteria
- [ ] Pending jobs promoted when capacity available
- [ ] FIFO ordering — oldest pending jobs promoted first
- [ ] Capacity correctly calculated from unit job_types
- [ ] start_date and completes_at set correctly on promotion
- [ ] Worker spec passes: 4 examples, 0 failures
- [ ] No regressions in related specs

---

## Commit Instructions
```bash
git add app/workers/job_processor_worker.rb
git commit -m "feat: JobProcessorWorker — add promote_pending_jobs, \
settlement capacity from unit job_types"
```

---

## Completion Report
**Completed by**:
**Completion date**:
**Final test result**: