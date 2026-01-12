class MockCraftLookupService
  def initialize
    @mock_crafts = {
      'mars_rover' => {
        'name' => 'Mars Rover',
        'type' => 'rover',
        'capacity' => { 'cargo_mass' => 100.0 },
        'consumables' => { 'energy' => 20.0 },
        'input_resources' => [{ 'id' => 'energy', 'amount' => 20.0 }],
        'output_resources' => [{ 'id' => 'survey_data', 'amount' => 1.0 }],
        'maintenance' => {
          'time_to_repair' => 150,
          'repair_cost_gcc' => 300,
          'materials_needed_for_repair' => [
            { 'id' => 'aluminum', 'amount' => 20.0 },
            { 'id' => 'sensors', 'amount' => 5.0 }
          ]
        },
        'deployment' => {
          'deployment_locations' => ['lunar_surface'],
          'deployment_time' => 200
        },
        'research_required' => 'Robotic Exploration Technology'
      },
      'lunar_lander' => {
        'name' => 'Lunar Lander',
        'type' => 'lander',
        'capacity' => { 'payload_mass' => 10000.0 },
        'consumables' => { 'fuel' => 8000.0 },
        'input_resources' => [{ 'id' => 'fuel', 'amount' => 8000.0 }],
        'output_resources' => [],
        'waste_heat' => 500,
        'maintenance_materials' => [
          { 'id' => 'titanium_alloy', 'amount' => 500.0 },
          { 'id' => 'electronics', 'amount' => 100.0 }
        ],
        'byproducts' => {
          'waste' => [
            { 'id' => 'spent_fuel', 'amount' => 8000.0, 'description' => 'Residuals from fuel consumption.' }
          ],
          'recyclable' => []
        },
        'ports' => {
          'internal' => 1,
          'external' => 1
        },
        'max_rigs' => 1,
        'deployment' => {
          'deployment_locations' => ['lunar_surface'],
          'deployment_time' => 200
        },
        'research_required' => 'Lunar Exploration Technology'
      },
      'starship' => {
        'name' => 'Starship',
        'type' => 'spaceship',
        'capacity' => { 'payload_mass' => 100000.0, 'passenger_capacity' => 1000 },
        'consumables' => { 'methane' => 100000.0, 'oxygen' => 200000.0, 'energy' => 200.0 },
        'input_resources' => [
          { 'id' => 'methane', 'amount' => 100000.0 },
          { 'id' => 'oxygen', 'amount' => 200000.0 },
          { 'id' => 'energy', 'amount' => 200.0 }
        ],
        'output_resources' => [{ 'id' => 'starship_structure', 'amount' => 100000.0 }],
        'waste_heat' => 1000,
        'maintenance_materials' => [
          { 'id' => 'stainless_steel', 'amount' => 1000.0 },
          { 'id' => 'electronics', 'amount' => 200.0 }
        ],
        'byproducts' => [{
          'waste' => [
            { 'id' => 'spent_methane', 'amount' => 100000.0, 'description' => 'Residuals from methane consumption.' },
            { 'id' => 'spent_oxygen', 'amount' => 200000.0, 'description' => 'Residuals from oxygen consumption.' }
          ],
          'recyclable' => []}
        ],
        'ports' => {
          'internal' => 5,
          'external' => 5
        },
        'max_rigs' => 5,
        'deployment' => {
          'deployment_locations' => ['mars_surface', 'lunar_surface'],
          'deployment_time' => 1000
        },
        'research_required' => 'Advanced Spacecraft Technology'
      }
    }
  end

  def find_craft(craft_name, craft_type)
    key = craft_name.downcase.tr(' ', '_')
    craft = @mock_crafts[key]
    return craft if craft && craft['type'] == craft_type.downcase
    return nil
  end
end
