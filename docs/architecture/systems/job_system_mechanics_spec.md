# Job System Mechanics Spec
**Location**: `docs/job_system_mechanics_spec.md`
**Status**: Canonical — required reading before touching any job system code
**Written**: 2026-04-21
**Authority**: Session Strategist + architecture decisions locked 2026-04-20

> This document is the source of truth for how jobs work in the game.
> If code contradicts this document, the code is wrong.
> If a spec contradicts this document, the spec is wrong.
> Do not change this document during an implementation task — flag the conflict and escalate.

---

## Overview — Three Job Categories

The game has three categories of production work. They are not interchangeable.

| Category | Model | Who Uses It | Key Difference |
|---|---|---|---|
| Small manufacturing | `Job` | Players, NPCs, corporations | Timer-based, claim on completion |
| Surface construction | `ConstructionJob` | Settlements | Progress-tracked, can pause |
| Orbital/large construction | `OrbitalConstructionProject` | Orbital shipyards | Material-gated, percentage progress |

This spec covers Category 1 and Category 2 in detail.
Category 3 (`OrbitalConstructionProject`) is already correctly modeled — do not change it.

---

## Category 1 — Small Manufacturing Jobs (`Job` model)

### What a Small Job Is

A small job is any blueprint execution that produces a discrete output in a fixed time.
The player submits materials and a blueprint, waits for a timer, then claims the output.
There is no partial completion. There is no progress bar mid-job. The job either completes
or it doesn't.

Examples: smelting ore into ingots, assembling a component from parts, processing
raw materials into refined goods, fabricating a unit from components.

### Player Flow — Start to Finish

**1. Submission**

The player selects a blueprint they own and a settlement facility that can run it.
The game checks:
- Player owns or has access to the blueprint
- The facility at the settlement supports this job type
- Required materials are present in the player's inventory or settlement storage

Materials are consumed immediately at submission. The player cannot cancel and
recover materials once submitted. The job record is created with `status: :in_progress`
and `completes_at` set to `Time.current + duration`. Duration comes from the blueprint.
`completes_at` is set once and never changes.

**2. Timer Running**

Nothing happens during this phase from the player's perspective.
The `JobProcessorWorker` runs on a schedule (Sidekiq). Each time it runs, it queries:

```ruby
Job.in_progress.where('completes_at <= ?', Time.current)
```

For each job returned, it calls `job.complete!` which transitions status to
`ready_to_claim`. The worker does not deliver outputs. The worker does not notify
the player. It only flips the status bit.

**3. Ready to Claim**

The job is now `ready_to_claim`. The output exists conceptually but has not been
delivered to any inventory. The player sees the job in their UI as claimable.

**4. Player Claims**

The player presses a claim action in the UI. The game:
- Verifies the job is `ready_to_claim`
- Verifies the claimant owns the job
- Delivers `output_quantity` of `output_type` to the player's inventory
- Updates the job: `status: :claimed`, `claimed_at: Time.current`

Output delivery is the caller's responsibility — the `Job` model does not know
about inventories. The controller or service that handles the claim action must
deliver the output and then call `job.claim!(claimant)`.

**5. Done**

The job record remains in the database as a historical record.
No automatic cleanup. Archive strategy is a future concern.

---

### NPC Flow — Differences from Player

NPCs run the same job lifecycle with two differences:

**Blueprint access**: NPCs do not need to own a blueprint. They have implicit
access to any blueprint appropriate to their role and settlement type.

**Auto-claim**: NPCs do not wait for a UI action. The AI Manager polls for
`ready_to_claim` jobs owned by NPCs and auto-claims them, delivering outputs
to the NPC's or corporation's inventory automatically. The AI Manager handles
this — it is not the worker's responsibility.

Everything else is identical: materials consumed at submission, `completes_at`
set once, worker flips to `ready_to_claim`, outputs delivered at claim time.

---

### Job Ownership

Jobs belong to the entity that submitted them — a player, an NPC, or a corporation.
Ownership is polymorphic. Settlement is recorded as facility context (where the job
runs) but the job belongs to the owner, not the settlement.

A player cannot claim another player's job. An NPC cannot claim a player's job.
Ownership is checked at claim time.

---

### Job Types (enum values on `Job` model)

| job_type | Description |
|---|---|
| `material_processing` | Raw material → refined material |
| `component_production` | Components → assembled component |
| `smelting` | Ore → metal ingot |
| `unit_assembly` | Components → functional unit |
| `resource_processing` | Resource extraction processing |
| `environment_processing` | Atmospheric/environmental processing |

All six share identical runtime behavior. The `job_type` field exists for
filtering, display, and future routing — not for behavioral branching.

---

### Status Lifecycle

```
in_progress → ready_to_claim → claimed
                             ↘ failed (worker error only)
```

- `in_progress`: Job submitted, timer running
- `ready_to_claim`: Worker has flipped it, awaiting player/NPC claim action
- `claimed`: Output delivered, job complete
- `failed`: Worker encountered an unrecoverable error — logged, not retried automatically

There is no `cancelled` status. Once submitted, materials are gone.
Cancellation logic is a Phase 2 concern if needed.

---

### What the Worker Does and Does Not Do

**Does:**
- Query `Job.ready_to_process` (in_progress where completes_at <= now)
- Call `complete!` on each — flips to `ready_to_claim`
- Log errors per job without stopping the batch
- Call `advance!` on in-progress `ConstructionJob` records

**Does not:**
- Deliver outputs to inventories
- Notify players
- Handle NPC auto-claim
- Process `OrbitalConstructionProject` (Phase 2)
- Accept any arguments — `perform` takes no parameters

The worker is time-based, not tick-based. It does not receive `hours_elapsed`.
It runs, checks the clock, processes what's due, exits.

---

## Category 2 — Surface Construction Jobs (`ConstructionJob` model)

### What a Construction Job Is

A construction job represents physical construction work at a settlement surface —
building a dome, covering a crater section, printing a habitat shell, sealing a
structure. These jobs are larger, longer-running, and can pause.

### Key Differences from Small Jobs

**Progress tracking**: Construction jobs track percentage completion, not just
a binary timer. The worker calls `advance!` on each in-progress construction job,
which increments progress based on elapsed time and available resources.

**Pause/resume**: Large construction jobs can pause if materials run short
mid-construction. The job status can go from `in_progress` back to a paused state
if the settlement runs out of required materials. Small jobs cannot pause — once
submitted, they run to completion regardless.

**No claim step**: Construction jobs do not have a claim action. When complete,
the structure is built — the settlement is updated directly. There is no output
delivered to an inventory.

**Settlement-owned**: Construction jobs belong to the settlement, not an individual
player or NPC.

### Job Types on `ConstructionJob`

```ruby
enum job_type: {
  crater_dome_construction: 0,
  skylight_cover: 1,
  access_point_conversion: 2,
  habitat_expansion: 3,
  structure_upgrade: 4,
  shell_printing: 5,   # added 2026-04-20
  seal_printing: 6     # added 2026-04-20
}
```

`shell_printing` and `seal_printing` are construction-category jobs. They are
handled by `ConstructionJob`, not by standalone `ShellPrintingJob` or
`SealPrintingJob` models. Those standalone models are legacy and are being retired.

### Shell Printing — Design Detail

Shell printing is geometry-driven construction, not blueprint manufacturing.
The agent pattern of treating it as "regolith → shell item" is wrong.

**What it actually is**: An inflatable habitat is deployed. The system measures
the inflatable's dimensions, calculates the required shell volume, and prints a
protective shell around it using local regolith feedstock. The player or NPC
chooses a target thickness — thicker shells provide better protection but consume
more regolith and take longer. Blueprint specifies a default thickness; player
overrides it based on world conditions (a Luna shell may need different thickness
than a Mars shell or an asteroid settlement).

**Inputs** (stored as `ConstructionJob` attributes — not JSON, not a blueprint recipe):
- `inflatable_id` — references the inflatable unit; dimensions come from its blueprint
- `target_thickness_mm` (decimal) — player/NPC choice, defaults to blueprint value,
  overridable per world conditions; drives protection rating and material volume
- `regolith_source_settlement_id` — local ground source

**Feedstock — any regolith stage accepted**:

Shell printing does not require a specific regolith type. The ISRU pipeline produces:
```
raw_regolith (world crust, composition from world properties)
    ↓ TEU — Thermal Electric Unit (bakes out easy volatiles, stores them)
processed_regolith
    ↓ PVE — Planetary Volatiles Extraction (removes oxides)
depleted_regolith
```
Shell printing accepts `raw_regolith`, `processed_regolith`, or `depleted_regolith` —
whichever is locally available. Feedstock quantity is calculated from inflatable
dimensions × `target_thickness_mm` at submission time, not taken from the blueprint.

**Structural components** (I-Beams, reinforcement rings): blueprint-fixed quantity.
These do not scale with thickness — they are structural, not volumetric.

**Output**: `protection_rating` calculated from actual `target_thickness_mm` ×
material quality of regolith used. Not an inventory item. The shell is part of
the structure, not something claimed.

**Note on blueprint JSON**: Existing blueprints may reference `inert_regolith_waste`
as a material. This is an incorrect agent-generated label. The correct taxonomy is
`raw_regolith` / `processed_regolith` / `depleted_regolith`. Blueprint JSON cleanup
is a separate backlog task — do not fix during the job model task.

**Workflow sequence**:
1. Deploy inflatable
2. Extract volatiles from regolith via TEU/PVE (separate jobs or prereq check)
3. Print shell (this `ConstructionJob`)
4. Pressurize (downstream step, not this job)

### Seal Printing — Design Detail

Seal printing is the same geometry-driven construction pattern applied to
skylights, access ports, and micro-leak repairs.

**Inputs** (same pattern as shell printing):
- `structure_port_id` — references the skylight, port, or structure being sealed
- `target_thickness_mm` — player/NPC choice, defaults to blueprint value,
  overridable per world conditions
- `regolith_source_settlement_id` — same local regolith source

**Feedstock**: Same as shell printing — any regolith stage accepted
(`raw_regolith`, `processed_regolith`, `depleted_regolith`). Quantity calculated
from port/structure dimensions × `target_thickness_mm` at submission.

**Output**: `protection_rating` from actual thickness × material quality. Structural, not inventory.

### New Columns Required on `construction_jobs` Table

Both job types require a migration to add these columns:

```ruby
add_column :construction_jobs, :inflatable_id, :integer
add_column :construction_jobs, :structure_port_id, :integer
add_column :construction_jobs, :target_thickness_mm, :decimal, precision: 8, scale: 2
add_column :construction_jobs, :regolith_source_settlement_id, :integer
add_index :construction_jobs, :inflatable_id
add_index :construction_jobs, :structure_port_id
```

`inflatable_id` is used by shell printing jobs.
`structure_port_id` is used by seal printing jobs.
Both are nullable — existing construction job types do not use them.

### Worker Interaction

The worker calls `advance!` on every `ConstructionJob` where `status: :in_progress`.
`advance!` is defined on the `ConstructionJob` model and handles progress
increment, material consumption, and pause logic internally.

---

## Common Mistakes — Do Not Repeat

These errors were made during the 2026-04-20 session and cost significant time:

**Wrong**: Treating `hours_elapsed` as a worker argument.
`perform` takes no arguments. Time is derived from `Time.current` vs `completes_at`.

**Wrong**: Using 9 separate job models for small manufacturing.
All small jobs use the unified `Job` model with a `job_type` enum.

**Wrong**: Querying job completion via `game.advance_by_days` or `game.process_jobs`.
`game.rb` no longer has `process_jobs`. Completion is worker-driven, time-based.

**Wrong**: Assuming `ShellPrintingJob` and `SealPrintingJob` are their own models.
They are `ConstructionJob` records with `job_type: :shell_printing` and `job_type: :seal_printing`.

**Wrong**: Modeling shell/seal printing as "regolith → shell item" manufacturing.
Shell printing is geometry-driven: inflatable dimensions + `target_thickness_mm` → `protection_rating`.
Inputs are `ConstructionJob` attributes, not a blueprint recipe. Output is structural, not inventory.

**Wrong**: Delivering outputs inside `Job#complete!`.
`complete!` only flips status. Output delivery is the caller's responsibility at claim time.

**Wrong**: Specs that test job completion by checking inventory after `advance_by_days`.
Test job completion by calling the worker directly or by creating a job with
`completes_at` in the past and calling `job.complete!`.

---

## Quick Reference — Correct Test Patterns

### Testing that the worker completes an overdue job
```ruby
job = create(:job, :overdue)  # completes_at in the past, status: in_progress
JobProcessorWorker.new.perform
expect(job.reload.status).to eq('ready_to_claim')
```

### Testing that a job is not yet complete
```ruby
job = create(:job, status: :in_progress, completes_at: 1.hour.from_now)
JobProcessorWorker.new.perform
expect(job.reload.status).to eq('in_progress')
```

### Testing claim output delivery (caller responsibility)
```ruby
job = create(:job, :ready_to_claim, output_type: 'iron_plate', output_quantity: 10)
# Caller delivers output, then:
job.claim!(player)
expect(job.reload.status).to eq('claimed')
expect(job.claimed_at).to be_present
```

### Testing construction job advancement
```ruby
job = create(:construction_job, status: :in_progress)
expect(job).to receive(:advance!)
JobProcessorWorker.new.perform
```

---

## Pending Work — Not Yet Implemented

The following are out of scope until the unified `Job` model is stable:

- NPC auto-claim in AI Manager
- Player claim UI action and controller
- Job queue priority routing by owner type
- Material delivery gating for large construction jobs
- `OrbitalConstructionProject` advancement in the worker (Phase 2)
- Job cancellation and material recovery
- Historical job archival and cleanup

Do not implement any of the above during the unified Job model task.
Flag them as follow-up tasks in the completion report.
