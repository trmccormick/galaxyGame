# spec/models/settlement/n_p_c_colony_spec.rb
require 'rails_helper'

RSpec.describe Settlement::NPCColony, type: :model do
  let(:initial_resources) { { food: 100, water: 200, energy: 300 } }
  let(:npc_colony) { Settlement::NPCColony.create(name: "AI Colony", population_capacity: 100, funds: 1000) }
  let(:unit_params) { { name: "Mining Facility", unit_type: "Facility", capacity: 10000, energy_cost: 50, production_rate: 200 } }

  before do
    npc_colony.update(initial_resources: initial_resources)
  end

  it 'can build a unit' do
    npc_colony.build_unit(unit_params)
    expect(npc_colony.base_units.count).to eq(1)  # Check if the unit is built
    expect(npc_colony.base_units.first.name).to eq("Mining Facility")
  end

  it 'can establish trade routes' do
    other_colony = Settlement::NPCColony.create(name: "Trade Colony", population_capacity: 100, funds: 1000)
    npc_colony.establish_trade_route(other_colony)
    expect(npc_colony.trade_routes).to include(other_colony)
  end

  it 'can perform autonomous tasks' do
    expect { npc_colony.perform_autonomous_tasks }.to output(/AI Colony is exploring new resources or potential expansion./).to_stdout
  end

  it 'calculates total population across settlements' do
    # Create the colony first
    npc_colony.save!

    # Then create settlements that belong to it
    city = create(:city, name: "City 1", current_population: 50, colony: npc_colony)
    settlement = create(:settlement, name: "Settlement 1", current_population: 25, colony: npc_colony)

    expect(npc_colony.total_population).to eq(75)
  end
end

