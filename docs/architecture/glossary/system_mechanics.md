# Glossary: Core System Mechanics

## Units vs. Structures
- **Units**: Deployable, mobile, or portable assets. Examples: `Units::Robot`, `Units::Habitat` (Inflatable). They are tracked by `unit_id`.
- **Structures**: Permanent, site-specific transformations. Example: `Structures::Worldhouse`. They are tracked by `structure_id`.

## Generic Portability Mandate
- **Rule**: All core hardware IDs must be planet-agnostic. 
- **Standard**: Use `heavy_structural_i_beam` instead of `lunar_i_beam`. 
- **Reasoning**: Physics and engineering requirements are universal; regionality is an environmental attribute assigned at the location level.

## The Seal Integrity Constant
- **Definition**: A binary or percentage-based state of a Worldhouse volume. 
- **Logic**: No atmospheric hydration or thermal regulation is possible until `seal_integrity == 100%`.