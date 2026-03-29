# Intent: Base Rig (The Industrial Engine)

## 1. Role Definition
A `BaseRig` is a specialized **Unit** (not a Structure) designed for high-volume resource extraction or material fabrication. It represents the "Heavy Machinery" of the Work Camp.

## 2. Functional Logic
- **Polymorphic Nature**: Rigs must support various `operational_data` profiles (e.g., Extraction, Refining, 3D Printing).
- **The Power Constraint**: Rigs are the primary consumers of the `lunar_precursor_power_grid`. Operation is gated by `power_consumption_kw`.
- **Placement**: Rigs are deployed onto a site to enable Phase 1 (Work Camp) and are eventually integrated into the permanent Phase 2 (Settlement) infrastructure.

## 3. Maintenance
Unlike simpler units, Rigs require specific "Tooling" components to switch production modes (e.g., swapping a Drill Head for a 3D Print Nozzle).