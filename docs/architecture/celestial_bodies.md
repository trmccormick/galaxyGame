# Celestial Bodies Architecture

## BaseFeature Static Data System

### Overview
The `CelestialBodies::Features::BaseFeature` model implements a hierarchical data retrieval system for geological features (lava tubes, skylights, etc.).

### Static Data Priority
The `static_data` method follows this priority order:

1. **Database Column**: If the `static_data` JSONB column contains data, return it directly
2. **Lookup Service Fallback**: If column is empty, query `Lookup::PlanetaryGeologicalFeatureLookupService` for external data

### Implementation Details
```ruby
def static_data
  return super if super.present? # Database column takes precedence
  @static_data ||= begin
    return nil unless celestial_body
    Lookup::PlanetaryGeologicalFeatureLookupService
      .new(celestial_body)
      .find_by_id(feature_id)
  end
end
```

### Factory Behavior
- **General Use**: `:lava_tube_feature` factory sets `static_data` column with default values for testing and seeding
- **Lookup Testing**: When testing lookup service integration, explicitly set `static_data: nil` in factory calls to force fallback behavior

### Testing Patterns
```ruby
# Test database column priority
let(:feature) { create(:lava_tube_feature) } # Uses factory's static_data

# Test lookup service fallback  
let(:feature) { create(:lava_tube_feature, static_data: nil) } # Forces lookup
```

### Data Sources
- **Database**: Stored in `adapted_features.static_data` JSONB column
- **Lookup Service**: External service providing feature metadata based on `feature_id` and celestial body context

### Schema
```sql
CREATE TABLE adapted_features (
  -- ... other columns
  static_data jsonb,
  -- ... 
);
```

This design allows features to have either pre-configured data or dynamically loaded data from external services.