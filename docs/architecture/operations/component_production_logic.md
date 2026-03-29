# Operations: Component Production Job

## 1. The Production Cycle
This job handles the transformation of raw materials into discrete items based on **Blueprints**.

## 2. Status Enum & State Machine
To pass the `component_production_job_spec`, the following states must be enforced:
- `pending`: Resource check passed; waiting for power/worker assignment.
- `processing`: Active `process_tick` is consuming power and incrementing `progress_percentage`.
- `completed`: Item is moved to local inventory; `production_log` updated.
- `failed`: Interruption due to power loss or hardware failure (CAR-300 breakdown).

## 3. Mandatory Blueprint Alignment
The job must pull requirements directly from the JSON Blueprint (e.g., `3d_printed_ibeam`).
- **Input**: 75kg Regolith, 15kg Al-Alloy.
- **Tool Requirement**: `3d_printer`.
- **Outcome**: 1x `heavy_structural_i_beam`.