# Hydrosphere State Distribution Fallback and Documentation Update

## Problem

Many existing and generated star system JSON files use different formats for `hydrosphere_attributes.state_distribution` (array of objects vs. object). Some use mass fraction instead of surface coverage percent, causing monitor and simulation inconsistencies.

## Solution

- Implement a fallback in the code to support both array and object forms for `state_distribution`.
- Enforce and document that `state_distribution["liquid"]` must always be **surface coverage percent** (not mass fraction).
- Update `/docs/architecture/hydrosphere_system.md` and related docs to clarify the correct format and meaning.
- Optionally, review and migrate all generated JSON files to the new object format with correct surface coverage values.
- Consider updating the system generator to always output the correct format.

## Acceptance Criteria

- All code paths that read `state_distribution` work with both array and object forms.
- Documentation clearly states the required format and meaning.
- No monitor or simulation breakage for legacy or new data.
- (Optional) All generated star system JSON files use the correct format.

## References
- See `/docs/architecture/hydrosphere_system.md` for updated guidance.
- Related code: `SystemBuilderService#create_hydrosphere`, monitor.js, terrain analysis services.
