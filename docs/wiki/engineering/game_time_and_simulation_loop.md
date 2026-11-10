---
title: Game Time and Simulation Loop
category: Engineering
status: DIRECTION — proposed intended flow; owner confirmation pending
last_updated: 2026-11-09
---

# Game Time and Simulation Loop

> **Page status:** `DIRECTION` — this page records a proposed intended flow for review. It is not an implementation specification and does not declare the current loop correct.

The game clock is a shared foundation for simulation systems. Construction, production, resource consumption, craft travel, AI Manager activity, communications, and other time-dependent behavior need to agree on the same game-time progression.

The older design and UI documentation describes a **continuous, speed-controlled simulation while running**, rather than a turn-based game: the player can run, pause, change speed, and make explicit time jumps. This should not be confused with an always-on world that necessarily advances while the player is away. The simulation's running state controls whether game time advances; whether offline wall-clock time should count remains OPEN. Real elapsed time is an input to the active simulation, while the game clock remains the shared timeline. The game-time rate and processing cadence must be tunable independently so the experience remains responsive without making delays feel arbitrary.

---

## DIRECTION — proposed intended flow

### One authoritative game clock

- There should be one authoritative source of the current game time and one coordinated advancement path.
- Wall-clock elapsed time may be used to calculate how much game time has passed while the game is running. Wall-clock time is not itself the game timeline.
- Fractional game time must be retained. The clock must not discard elapsed time simply because a complete game day has not passed.
- Pausing stops game-time advancement. Resuming establishes a fresh timing baseline so paused wall-clock time is not counted.
- A speed change first accounts for elapsed time at the previous speed, then applies the new speed from that point forward.
- Reading the current game time must be read-only. A page load, API poll, or UI refresh must not advance the clock or trigger simulation side effects.

### Coordinated simulation advancement

1. The clock determines the elapsed game-time interval since the last successful advancement.
2. A coordinated simulation runner processes that interval for the systems that need to advance.
3. Each participating system receives a consistent game-time interval and processes it at an appropriate resolution. A system may process continuously, by fractional interval, by hour, by day, or at scheduled event boundaries as its mechanics require.
4. The clock records the successfully processed game-time position so work is neither silently lost nor applied twice.
5. The runner remains scheduled or otherwise available while the game is running, even when the elapsed interval is less than one full game day. It can remain idle while paused.
6. Advancement must be protected against overlapping workers or requests processing the same interval concurrently.

This describes behavior, not a required Rails class, job framework, database schema, or scheduling implementation. Those choices should follow code inspection and testing.

### Keep game-time rate separate from processing cadence

The game-time speed determines how quickly simulated time advances relative to real elapsed time. The processing cadence determines how often the application checks for and processes accumulated work.

These are related but not interchangeable:
- A frequent lightweight check can keep the simulation responsive without forcing large game-time jumps.
- A slower or batched subsystem can still process the correct accumulated interval.
- The game should not need to wait for a whole simulated day before the clock or every subsystem can make progress.
- Speed settings and their labels/rates should be tuned through gameplay testing, not inferred from the current code values.

### Shared timing for gameplay and communications

All time-dependent systems should use the same authoritative game-time basis.

For communications, for example, the game calculates command-arrival and response-arrival ETAs in game time. Pausing the game pauses those countdowns; changing simulation speed changes how quickly the remaining game-time interval elapses in real time. The player sees the route and expected arrival times, not the internal clock or scheduling machinery.

The same principle applies to construction completion, craft transit, resource production/consumption, scheduled events, and AI Manager activity.

---

## OPEN — decisions and tuning

- What game-time speed choices and rates provide the right balance of meaningful delay and player responsiveness?
- Should the simulation advance while the application/server is offline, or should offline time be excluded? This must be explicit rather than an accidental consequence of timestamp handling.
- What is the minimum useful processing interval for each subsystem, and which systems need event-boundary processing rather than periodic ticks?
- How should a delayed or failed worker recover unprocessed elapsed time without duplicate side effects?
- What concurrency/locking approach guarantees only one authoritative advancement of a given interval?
- Which calendar convention is canonical for game time (the current code uses 365-day years)?
- How should manual time jumps interact with scheduled events, subsystem processing, and pending deliveries?
- Are there multiple independent game sessions in scope, or is the current single global GameState a temporary prototype assumption?

No numeric speed curve or processing interval is established by this page.

---

## Historical documentation and extracted intent

The older documentation was reviewed alongside the current code. These documents are frozen references, not competing implementation specifications; where they conflict with current owner direction or code, the conflict is recorded for review rather than silently adopted.

### Durable design direction found

- `docs/agent/tasks/TASK_OVERVIEW.md` describes a planning-complete discussion of time acceleration and game pacing for a real-time strategy game. Its stated questions include the real-time meaning of a game day, balancing progress speed with player agency, and time scales for contracts, construction, and events. The tracker also characterizes the game as continuous rather than turn-based, with concurrent AI behavior, information management, attention management, and notifications as implications.
- `docs/developer/ui_enhancements.md` describes five speed levels (1x–5x), run/pause controls, explicit time jumps (+1 day through +1 year), and a 30fps animation loop. It also describes data polling while the simulation is running. This supports separating display/render cadence from simulation/game-time advancement.
- `docs/developer/TERRAFORMING_SIMULATION.md` describes terraforming as gradual, time-based progression over months and years, requiring sustained resource investment. This reinforces that subsystems must receive coherent elapsed game-time intervals rather than merely updating a display clock.
- `docs/developer/UI_IMPLEMENTATION.md` contains an earlier browser-side `requestAnimationFrame` controller and example speed choices of 1x/10x/100x/1000x. Those are historical prototype examples, not a confirmed current balance specification or backend architecture.
- The referenced `time_speed_mechanics_discussion.md` and `realtime_vs_turnbased_differences.md` are named in the old task tracker as planning references, and the time-mechanics task is marked `PLANNING COMPLETE`. The referenced source documents were not present at the paths checked in the current repository tree, so their detailed conclusions could not be verified. Do not infer that their open questions were resolved merely from the tracker label.

### Synthesis and boundaries

The durable direction is a continuously advancing simulation when running, with player-controlled pause, selectable acceleration, and explicit time jumps. This is not the same as requiring offline progression. The old documentation does not settle whether elapsed wall-clock time while the game/server is offline should be applied on return.

The old UI examples also mix client-side clock advancement, rendering cadence, server polling, and persistence. They are useful evidence of historical intent and prototype evolution, but they must not be treated as a current design contract. The current code needs to establish one authoritative game-time progression and ensure visual polling cannot independently consume elapsed time that simulation systems have not processed.

The exact speed curve, the player-facing pacing of delays, and offline progression remain OPEN. The current five backend speed values are code facts only, not approved balance targets.

---

## VERIFIED AGAINST CODE — snapshot reviewed 2026-11-09

**Scope:** Static source inspection of the current `galaxyGame` default-branch snapshot (code references at commit `fbf7b72`). No code was changed and no runtime test was executed as part of this documentation pass.

- `GameState` stores year, fractional day, running state, speed, and `last_updated_at`. Its current speed mapping is 300, 120, 60, 30, and 10 real seconds per game day for speed values 1 through 5. These are current code values, **not approved target balance values**.
- `GameState#update_time!` calculates fractional elapsed game days, advances the stored clock, and resets `last_updated_at`.
- `GameSimulationJob` calculates elapsed time but converts it to whole game days with `.to_i`. It returns before scheduling its next run when no whole day is available. It also returns when the game is paused, before scheduling another run.
- The initializer schedules one initial `GameSimulationJob` run after startup. The job schedules its next run only after it processes at least one whole day. This makes continued scheduling dependent on the job reaching that point.
- `Game#advance_by_days` processes settlements, manufacturing jobs, and free deployed craft, then persists the new game time. Its current caller supplies whole days from `GameSimulationJob`.
- `GameController#index`, `#get_time`, and `#state` call `update_time!` when running. These request paths can move the stored clock and reset its timestamp without running the corresponding `Game` subsystem processing.
- `set_speed` changes the speed value without first settling elapsed time at the old speed. `toggle_running!` sets a new timestamp when starting, but does not first settle elapsed time when stopping.
- A separate `GameSimulation` service also exists. It advances the clock and calls celestial-body simulation, while the current background job calls `Game`. Its intended status and callers need to be established before either path is changed or removed.

These observations indicate a mismatch between clock updates and simulation processing, fractional-time handling, and background-job continuation. They are findings for review, not a proposed patch.

---

## Related Pages

| Page | Relationship |
|------|--------------|
| [Interstellar Communications](interstellar_communications.md) | Command and response ETAs use the shared game-time basis |
| [AI Manager](../services/ai_manager.md) | Autonomous operations and scheduled decisions depend on simulation advancement |
| [Logistics and hauling](../logistics/logistics_and_hauling.md) | Transport and delivery progress depend on game time |
