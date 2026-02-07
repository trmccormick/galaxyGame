FactoryBot.define do
  factory :base_structure, class: 'Structures::BaseStructure' do
    sequence(:name) { |n| "Structure #{n}" }
    structure_name { "test_structure" }
    structure_type { "test_type" }
    current_population { 0 }
    association :settlement, factory: :base_settlement
    association :owner, factory: :player
    
    # UPDATED: Use connection_systems template structure
    operational_data do
      {
        "connection_systems" => {
          "power_distribution" => {"status" => "offline", "efficiency" => 85}
        },
        "container_capacity" => {
          "unit_slots" => [
            {"type" => "energy", "count" => 1},
            {"type" => "computers", "count" => 1}
          ],
          "module_slots" => [
            {"type" => "power", "count" => 1}
          ]
        },
        "operational_modes" => {
          "current_mode" => "standby",
          "available_modes" => [
            {"name" => "standby", "power_draw" => 250.0, "staff_required" => 2},
            {"name" => "production", "power_draw" => 2500.0, "staff_required" => 10}
          ]
        }
      }
    end

    # REMOVE the after(:build) block with allow_any_instance_of
    # That's what's causing the error
  end

  trait :operational do
    operational_data do
      {
        "connection_systems" => {
          "power_distribution" => {"status" => "online", "efficiency" => 85}
        },
        "container_capacity" => {
          "unit_slots" => [
            {"type" => "energy", "count" => 1},
            {"type" => "computers", "count" => 1}
          ],
          "module_slots" => [
            {"type" => "power", "count" => 1}
          ]
        },
        "operational_modes" => {
          "current_mode" => "production",
          "available_modes" => [
            {"name" => "standby", "power_draw" => 250.0, "staff_required" => 2},
            {"name" => "production", "power_draw" => 2500.0, "staff_required" => 10}
          ]
        }
      }
    end

    after(:create) do |structure|
      # Add required units for operational status
      create(:unit, :power, attachable: structure)
      create(:unit, :computer, attachable: structure)
    end
  end

  trait :non_operational do
    operational_data do
      {
        "connection_systems" => {
          "power_distribution" => {"status" => "offline", "efficiency" => 85}
        },
        "container_capacity" => {
          "unit_slots" => [
            {"type" => "energy", "count" => 1},
            {"type" => "computers", "count" => 1}
          ],
          "module_slots" => [
            {"type" => "power", "count" => 1}
          ]
        },
        "operational_modes" => {
          "current_mode" => "standby",
          "available_modes" => [
            {"name" => "standby", "power_draw" => 250.0, "staff_required" => 2},
            {"name" => "production", "power_draw" => 2500.0, "staff_required" => 10}
          ]
        }
      }
    end
  end

  trait :with_inventory do
    after(:create) do |structure|
      create(:inventory, inventoryable: structure)
    end
  end

  trait :test_nuclear_facility do
    name { "Test Nuclear Facility" }
    structure_name { "nuclear_fuel_reprocessing_facility" }
    structure_type { "facility" }
    
    operational_data do
      {
        "template" => "structure_operational_data",
        "id" => "nuclear_fuel_reprocessing_facility",
        "name" => "Nuclear Fuel Reprocessing Facility",
        "structure_type" => "facility",
        "category" => "resource_processing",
        "subcategory" => "fuel_processing",
        
        "operational_status" => { 
          "status" => "offline", 
          "condition" => 100, 
          "degradation_rate" => 0.05 
        },
        
        # ✅ FIX: Use connection_systems instead of systems
        "connection_systems" => {
          "power_distribution" => {
            "status" => "offline", 
            "efficiency" => 85,
            "capacity_kw" => 2500
          },
          "uranium_enrichment" => {
            "status" => "not_installed", 
            "efficiency" => 0
          },
          "fuel_liquefaction" => {
            "status" => "not_installed", 
            "efficiency" => 0
          }
        },
        
        # ✅ FIX: Use container_capacity instead of unit_slots/module_slots
        "container_capacity" => {
          "unit_slots" => [
            {"type" => "production/refineries", "count" => 4},
            {"type" => "energy", "count" => 2},
            {"type" => "computers", "count" => 1}
          ],
          "module_slots" => [
            {"type" => "power", "count" => 1},
            {"type" => "computer", "count" => 1}
          ]
        },
        
        "physical_properties" => {
          "length_m" => 50,
          "width_m" => 30,
          "height_m" => 10,
          "volume_m3" => 15000,
          "empty_mass_kg" => 125000,
          "structural_integrity" => 100
        },
        
        "operational_modes" => {
          "current_mode" => "standby",
          "available_modes" => [
            {"name" => "standby", "power_draw" => 250.0, "staff_required" => 2},
            {"name" => "production", "power_draw" => 2500.0, "staff_required" => 10}
          ]
        },
        
        # ✅ KEEP: For building recommended units/modules
        "recommended_units" => [
          {"id" => "uranium_enrichment_centrifuge", "count" => 2, "type" => "production/refineries"}
        ],
        "recommended_modules" => [
          {"id" => "efficiency_optimizer", "count" => 1, "type" => "power"}
        ]
      }
    end
  end

  factory :depot_tank, parent: :base_structure do
    structure_type { 'depot_tank' }
    operational_data do
      {
        "structure_type" => "depot_tank",
        "gas_storage" => {},
        "capacity" => 10000,
        "connection_systems" => {
          "power_distribution" => {"status" => "online", "efficiency" => 85}
        }
      }
    end
  end
end