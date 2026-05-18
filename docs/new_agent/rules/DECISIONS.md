# Project Galaxy Game: Architectural & Economic Decisions
**Last Updated**: 2026-05-11
**Maintained By**: Session Strategist (Claude)

> This file is the source of truth for all locked decisions.
> No agent may contradict these without explicit human approval.
> All new decisions go here BEFORE any code is written.

---

## Economic Constants

| Rule | Value | Notes |
|---|---|---|
| Currency Peg | 1 USD = 1 GCC (Galaxy Core Credit) | No conversion logic needed |
| SCC Surcharge | 0.5% | Applied to all Trading PLEX transactions |
| Broker Fee | 0.3% | Applied to all Trading PLEX transactions |
| Sales Tax | 3.37% | Applied to all Trading PLEX transactions |
| Lunar Iron Loss Rate | 15% | Applies to iron AND silicate sourcing |
| Manufacturing Logic | Market vs. Build balance | Never hardcode "always buy" or "always build" |

---

## Lunar Industrial Constants

- **Primary resource**: Depleted Regolith (primary mass)
- **Secondary resource**: Iron (additive)
- **Loss rate**: 15% on all early-stage sourcing of iron and silicates
  - 100 units regolith input → 85 units usable output
  - 100 units iron input → 85 units usable output
- **CNT dependency**: Carbon Nanotubes (Venusian import) required for Mk2 Composite parts
- **No conflicts** with 1:1 USD/GCC peg logic

---

## Architecture Decisions

### No Hardcoded Luna Logic
All Luna-specific behavior must be data-driven from `operational_data` or JSON config files.
No Ruby class may contain hardcoded Luna resource values, capacities, or production rates.
If a value is Luna-specific, it belongs in the Luna mission profile JSON, not in code.

### Unit Model Pattern
All unit subclasses follow the Robot/Battery pattern:
- Read everything from `operational_data`
- No `attr_accessor` for config values
- No `initialize` overrides
- No hardcoded unit type lists in BaseUnit
- `job_types` driven by `operational_data`

### Habitat Unit — Locked 2026-05-11
- **Habitat unit has one job**: expose `population_capacity` from `operational_data`
- Population capacity = how many people can sleep here (beds)
- **PopulationManagement concern belongs on Settlement and Craft — NOT Habitat**
- Remove all `Resource.consume` / `Resource.produce` calls from Habitat — dead code
- Remove all population management logic from Habitat — delegate to concern on Settlement
- Basic needs (food, water, O2 consumption / CO2, wastewater, biowaste production)
  are defined in game constants and calculated by services that adjust inventory
- Habitat does not calculate or adjust inventory directly

### .old File Convention — Locked 2026-05-11
Files renamed to `.old` are mid-refactor placeholders — not intentional deletions.
When a `.old` file exists without a corresponding `.rb`:
- Restore from `.old` as the starting point
- Rewrite to follow Robot/Battery pattern
- Once rewritten and specs pass, delete the `.old` file
- Never leave `.old` files in place after task completion

### Population & Life Support Model — Locked 2026-05-11
Basic needs defined in game constants, not in unit classes:
- **Consumption per person per day**: food, water, O2
- **Waste per person per day**: CO2, wastewater, biowaste
- Services calculate and adjust settlement inventory
- Habitat contributes `population_capacity` only
- PopulationManagement concern lives on Settlement and Craft

### Job Model (Manufacturing)
- `Job` = manufacturing (ISRU, smelting, components) — timer-based, 5 mandatory fields
- `ConstructionJob` = surface construction (crater domes, shell printing) — permanent separate model
- Job unification plan: CANCELLED (2026-05-03)
- `output_type` on Job: nullable column, not required

### Job Lifecycle
```
Created     → status: :pending, start_date: nil, completes_at: nil
Slot opens  → status: :in_progress, start_date: Time.current, completes_at: start_date + production_time
Completes   → output added to inventory, status: :ready_to_claim
Cancelled   → materials returned (if before start), status: :cancelled
```

### Data Paths
- Always use `GalaxyGame::Paths` constants — never `Rails.root.join` directly
- JSON operational data lives in `data/json-data/`
- Sphere data is strictly separated — geosphere stores only ground-accessible volatiles

---

## Development Hardware Topology

### Current State (2026-05-15 — confirmed via curl)
| Node | IP | Role | Runs |
|---|---|---|---|
| Intel Mac | — | Primary dev, orchestration | VS Code, Continue, git |
| M4 Mac | 10.6.186.161 | Model serving (sleep when lid closed) | Codestral, Qwen2.5-14B, Qwen2.5-7B, DeepSeek-16B, Nomic Embed |
| Windows (Ryzen 7) | 10.6.186.50 | Model serving (128GB RAM, always on) | Qwen2.5-32B, Qwen3.5-9B, Qwen3-30B, Qwen2.5-3B, Llama-8B, Qwen2.5-1.5B, Nomic Embed |
| Pi 4 | — | Infrastructure | Samba shares, Docker (game stack capable) |

### Confirmed Model Roster

#### M4 Mac (10.6.186.161)
| Model | Role |
|---|---|
| `codestral:latest` | Architecture reasoning, synthesis reports |
| `qwen2.5-coder:14b` | Multi-file implementation with context |
| `qwen2.5-coder:7b` | Medium complexity targeted edits |
| `deepseek-coder-v2:16b` | Logic verification, second opinion |
| `nomic-embed-text:latest` | RAG indexing — always on |

#### Windows Ryzen 7 (10.6.186.50)
| Model | Role |
|---|---|
| `qwen2.5-coder:32b` | Primary worker — heavy implementation |
| `qwen3.5:9b` | Reasoning and logic tasks |
| `qwen3-coder:30b` | Fallback only — tool calls unreliable (MoE architecture) |
| `qwen2.5-coder:3b` | Fast single-file edits |
| `llama3.1:8b` | General chat fallback only |
| `qwen2.5-coder:1.5b` | Tab autocomplete — always on |
| `nomic-embed-text:latest` | RAG indexing — always on |

### Local Model Routing (Updated 2026-05-15)
| Task Type | Model | Node |
|---|---|---|
| Architecture / synthesis reports | Codestral | M4 |
| Multi-file implementation | Qwen2.5-Coder 14B | M4 |
| Medium targeted edits | Qwen2.5-Coder 7B | M4 |
| Logic verification | DeepSeek-Coder 16B | M4 |
| Heavy implementation | Qwen2.5-Coder 32B | Windows (primary) |
| Reasoning / logic tasks | Qwen3.5 9B | Windows |
| Fast single-file edits | Qwen2.5-Coder 3B | Windows |
| RAG / codebase indexing | Nomic Embed | Both nodes (always-on) |
| Tab autocomplete | Qwen2.5-Coder 1.5B | Windows (always-on) |
| Fallback chat | Llama 3.1 8B | Windows (if others unavailable) |
| DO NOT USE for analysis | Qwen3-Coder 30B | Tool calls broken — MoE arch |

### Cloud Agent Rules
- **GPT-4.1**: Primary implementation agent. All 0x tasks. Free tier.
- **Haiku 4.5**: 0.33x — implementation, spec fixes, handoffs. Weekly limit applies.
- **Grok**: RETIRED 2026-05-15.
- **Claude**: Planning and strategy only. Never implementation. Premium — use at gates only.
- **Perplexity/Gemini**: Manual strategist fallback when Claude unavailable.

### Testing Principle — Locked 2026-05-15
Integration specs use real JSON data and real service calls.
Stubs only for external dependencies.
Never stub internal lookup services in integration specs.
If JSON changes, the test must catch it.

---

## May–June 2026 Schedule
- Vacation (no development): May 20–27
- Post-vacation premium review: May 28–31
- GitHub Copilot weekly reset: May 17 at 8pm
- June workflow shift: Copilot changes take effect — update AGENT_ROUTING.md when confirmed
- Monthly goal: Luna settled ✅, ISRU producing ✅, AI Manager settles Luna via TaskExecutionEngineV2 ✅
