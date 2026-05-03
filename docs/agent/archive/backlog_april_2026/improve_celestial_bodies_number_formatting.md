# Improve Number Formatting in Admin Celestial Bodies View

## Problem Description
The admin celestial bodies index view at `/admin/celestial_bodies` displays mass values as very large raw numbers (e.g., 5.990955850120839e+19 kg), which are difficult to read. Temperature values could also benefit from better rounding/formatting.

## Current Implementation
- **Mass**: Uses `number_to_human(body.mass, units: { unit: 'kg', thousand: 'k', million: 'M', billion: 'B', trillion: 'T' })` but this doesn't handle astronomical scales well
- **Temperature**: Uses `body.temperature.round(1)` which shows one decimal place

## Proposed Solution
1. **Mass Formatting**: 
   - Use scientific notation for very large numbers (e.g., "5.99 × 10¹⁹ kg")
   - Or use appropriate astronomical units (e.g., Earth masses, solar masses for larger bodies)
   - Consider helper method for consistent formatting across the app

2. **Temperature Formatting**:
   - Round to 0 or 1 decimal places based on magnitude
   - Consider showing in Kelvin for scientific accuracy
   - Add unit indicators (K or °C)

## Files to Modify
- `galaxy_game/app/views/admin/celestial_bodies/index.html.erb` (lines ~404-405 for mass, ~409-410 for temperature)
- Potentially add helper methods in `galaxy_game/app/helpers/application_helper.rb`

## Acceptance Criteria
- Mass values display in readable scientific notation
- Temperature values are appropriately rounded
- Formatting is consistent across similar views
- No performance impact on page load

## Priority
Medium - UI/UX improvement for admin interface

## Estimated Effort
2-4 hours (including testing and potential helper method creation)

## Related Issues
- Similar formatting issues may exist in other admin views (monitor.html.erb, solar_systems/show.html.erb)
- Consider global helper for astronomical number formatting