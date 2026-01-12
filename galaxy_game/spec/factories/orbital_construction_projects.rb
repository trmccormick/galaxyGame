FactoryBot.define do
  factory :orbital_construction_project do
    association :station, factory: :base_settlement
    craft_blueprint_id { 'earth_mars_cycler' }
    status { :materials_pending }
    progress_percentage { 0.0 }

    required_materials do
      {
        'ibeam' => 5000,
        'modular_structural_panel_base' => 10000,
        'aluminum_alloy' => 100000,
        'titanium_alloy' => 50000,
        'composite_materials' => 25000,
        'solar_cells' => 5000,
        'ion_thruster_components' => 20
      }
    end

    delivered_materials do
      {
        'ibeam' => 0,
        'modular_structural_panel_base' => 0,
        'aluminum_alloy' => 0,
        'titanium_alloy' => 0,
        'composite_materials' => 0,
        'solar_cells' => 0,
        'ion_thruster_components' => 0
      }
    end

    project_metadata { {} }

    trait :in_progress do
      status { :in_progress }
      construction_started_at { Time.current }
    end

    trait :completed do
      status { :completed }
      progress_percentage { 100.0 }
      completed_at { Time.current }
    end

    trait :gas_giant_cycler do
      craft_blueprint_id { 'gas_giant_cycler' }

      required_materials do
        {
          'ibeam' => 7500,
          'modular_structural_panel_base' => 15000,
          'titanium_alloy' => 150000,
          'composite_materials' => 75000,
          'radiation_shielding_material' => 50000,
          'solar_cells' => 7500,
          'ion_thruster_components' => 30,
          'atmospheric_processor_components' => 10
        }
      end

      delivered_materials do
        {
          'ibeam' => 0,
          'modular_structural_panel_base' => 0,
          'titanium_alloy' => 0,
          'composite_materials' => 0,
          'radiation_shielding_material' => 0,
          'solar_cells' => 0,
          'ion_thruster_components' => 0,
          'atmospheric_processor_components' => 0
        }
      end
    end
  end
end