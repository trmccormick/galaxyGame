# Migration Plan: OrbitalDepot PORO -> ActiveRecord Model
#
# Current State:
# - Temporary PORO: app/models/orbital_depot.rb (simple Hash-based storage)
# - Used by: AIManager::TerraformingManager for rake testing
#
# Future State:
# - Production Model: app/models/settlement/orbital_depot.rb (Settlement subclass)
# - Uses: Inventory system with metadata for persistent gas tracking
# - Benefits: Database persistence, inventory integration, settlement features
#
# Migration Steps:
# ================

## Phase 1: Preparation (COMPLETED)
- [x] Create Settlement::OrbitalDepot model
- [x] Create comprehensive RSpec test suite
- [x] Document API compatibility layer

## Phase 2: Database Setup
- [ ] Create migration for orbital_depot-specific columns (if needed)
      Example:
      ```ruby
      class AddOrbitalDepotFields < ActiveRecord::Migration[7.0]
        def change
          # Add depot-specific fields to base_settlements table
          add_column :base_settlements, :depot_type, :string
          add_column :base_settlements, :orbital_position, :jsonb
          
          # Ensure items table has metadata column (should exist)
          # add_column :items, :metadata, :jsonb unless column_exists?(:items, :metadata)
        end
      end
      ```

- [ ] Create seed data for initial orbital depots
      Example: db/seeds/orbital_depots.rb
      ```ruby
      # Create Mars Orbital Depot at L1 point
      mars = CelestialBodies::Planets::Rocky::TerrestrialPlanet.find_by(name: 'Mars')
      
      mars_depot = Settlement::OrbitalDepot.create!(
        name: 'Mars L1 Orbital Depot',
        settlement_type: 'outpost',
        current_population: 10,
        operational_data: {
          'orbital_position' => 'mars_l1',
          'purpose' => 'terraforming_gas_storage'
        }
      )
      
      # Create location for orbital depot
      Location::CelestialLocation.create!(
        celestial_body: mars,
        latitude: 0.0,
        longitude: 0.0,
        altitude: 20_000_000.0, # Sun-Mars L1 point
        locationable: mars_depot
      )
      
      # Create gas storage units
      Units::BaseUnit.create!(
        attachable: mars_depot,
        unit_type: 'storage',
        name: 'H2 Storage Tank Alpha',
        operational_data: {
          'storage' => {
            'type' => 'gas',
            'capacity' => 1.0e14 # 100 trillion kg capacity
          }
        }
      )
      ```

## Phase 3: TerraformingManager Adapter
- [ ] Create adapter module to support both implementations
      ```ruby
      module AIManager
        module DepotAdapter
          # Factory method to create depot based on type
          def self.create_depot(world_key, world)
            if ENV['USE_AR_DEPOT'] == 'true'
              # Use ActiveRecord model
              Settlement::OrbitalDepot.find_or_create_by!(
                name: "#{world.name} Orbital Depot"
              )
            else
              # Use PORO for testing
              OrbitalDepot.new
            end
          end
          
          # Unified interface
          class DepotWrapper
            def initialize(depot)
              @depot = depot
            end
            
            def add_gas(name, amount, metadata = {})
              if @depot.is_a?(Settlement::OrbitalDepot)
                @depot.add_gas(name, amount, metadata)
              else
                @depot.add_gas(name, amount)
              end
            end
            
            # ... similar wrappers for other methods
          end
        end
      end
      ```

## Phase 4: Update TerraformingManager
- [ ] Modify initialize_depots to use adapter
      ```ruby
      def initialize_depots
        @worlds.each do |key, world|
          depot = AIManager::DepotAdapter.create_depot(key, world)
          @orbital_depots[key] = AIManager::DepotAdapter::DepotWrapper.new(depot)
        end
      end
      ```

## Phase 5: Testing
- [ ] Run existing rake task with PORO (verify no regression)
      ```bash
      rake venus_mars:pipeline
      ```

- [ ] Run RSpec tests for Settlement::OrbitalDepot
      ```bash
      rspec spec/models/settlement/orbital_depot_spec.rb
      ```

- [ ] Test with ActiveRecord depot (requires DB setup)
      ```bash
      USE_AR_DEPOT=true rake venus_mars:pipeline
      ```

## Phase 6: Integration
- [ ] Update documentation
- [ ] Create admin/management interface for orbital depots
- [ ] Add depot visualization in game UI
- [ ] Create depot management commands (inspect, transfer, maintenance)

## Phase 7: Migration Complete
- [ ] Switch default to ActiveRecord model
- [ ] Mark PORO as deprecated
- [ ] Schedule removal of PORO after confirmation period
- [ ] Remove app/models/orbital_depot.rb

## Rollback Plan
If issues arise:
1. Switch back to PORO via environment variable
2. Review and fix Settlement::OrbitalDepot issues
3. Re-test with rake task
4. Iterate on model until stable

## Performance Considerations
- PORO: Fast, in-memory, no DB overhead
- ActiveRecord: Persistent, slower, but realistic for game
- Consider caching depot state during long simulations
- Batch inventory operations when possible

## API Compatibility Matrix
| Method | PORO | Settlement::OrbitalDepot | Notes |
|--------|------|--------------------------|-------|
| `add_gas(name, amount)` | ✓ | ✓ (+ metadata) | AR version adds metadata support |
| `remove_gas(name, amount)` | ✓ | ✓ (+ metadata) | Returns actual amount removed |
| `get_gas(name)` | ✓ | ✓ (+ metadata filter) | AR can filter by metadata |
| `has_gas?(name, amount)` | ✓ | ✓ (+ metadata filter) | AR can check specific batches |
| `total_mass` | ✓ | `total_gas_mass` | Renamed for clarity |
| `summary` | ✓ | `depot_status` | AR version more comprehensive |

## File Structure After Migration
```
app/models/
  orbital_depot.rb                    # DEPRECATED - Remove after migration
  settlement/
    orbital_depot.rb                  # Production model
    
app/services/ai_manager/
  depot_adapter.rb                    # NEW - Adapter for dual support
  terraforming_manager.rb             # UPDATED - Uses adapter
  
spec/models/settlement/
  orbital_depot_spec.rb               # Comprehensive test suite
  
db/seeds/
  orbital_depots.rb                   # Seed data for initial depots
```

## Timeline
- Phase 1-2: 1-2 days (database setup and seeds)
- Phase 3-4: 1 day (adapter and manager updates)
- Phase 5: 1-2 days (comprehensive testing)
- Phase 6-7: 1-2 days (integration and cleanup)

Total: ~1 week for full migration
