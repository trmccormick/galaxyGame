require 'rails_helper'

RSpec.describe Manufacturing::AssemblyService, type: :service do
  let(:player) { create(:player) }
  let(:settlement) { create(:base_settlement, owner: player) }
  let(:blueprint) { create(:blueprint, name: 'test_structure', player: player) }

  let(:blueprint_data) do
    {
      'id' => 'test_structure',
      'name' => 'Test Structure',
      'category' => 'structures',
      'required_materials' => {
        'steel' => { 'amount' => 10 },
        'concrete' => { 'amount' => 5 }
      },
      'production_data' => {
        'build_time_hours' => 24
      }
    }
  end

  before do
    # Mock the blueprint lookup service
    allow_any_instance_of(Lookup::BlueprintLookupService).to receive(:find_blueprint)
      .with('test_structure').and_return(blueprint_data)

    # Mock the market service to return prices
    allow(Market::NpcPriceCalculator).to receive(:calculate_ask).with(anything, anything).and_return(10.0)

    # Create settlement inventory with some materials
    settlement.inventory.items.create!(name: 'steel', amount: 10, owner: player)
    # Note: concrete is missing, so it should be identified as missing
  end

  describe '.start_assembly' do
    context 'with all materials available' do
      before do
        settlement.inventory.items.create!(name: 'concrete', amount: 5, owner: player)
      end

      it 'creates an assembly job successfully' do
        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(result.success?).to be true
        expect(result.job).to be_persisted
        expect(result.tenant_fee).to eq(10 + 24 + 2) # Base 10 + 24 hours + 2 materials
        expect(result.missing_materials).to be_empty
      end

      it 'charges the tenant fee' do
        gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
        player.account.update!(balance: 1000)
        settlement.account.update!(balance: 1000)
        initial_player_balance = player.account.balance
        initial_settlement_balance = settlement.account.balance

        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(player.account.reload.balance).to eq(initial_player_balance)
        expect(settlement.account.reload.balance).to eq(initial_settlement_balance)
      end
    end

    context 'with missing materials and buy_missing = false' do
      it 'fails and reports missing materials' do
        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(result.success?).to be false
        expect(result.missing_materials).to include('concrete')
        expect(result.errors).to include(/Missing materials/)
      end
    end

    context 'with missing materials and buy_missing = true' do
      it 'buys missing materials and creates job' do
        # Give player enough money
        gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
        player.account.update!(balance: 1000)
        settlement.account.update!(balance: 1000)

        # Mock the market service
        allow(Market::NpcPriceCalculator).to receive(:calculate_ask).with(anything, 'concrete').and_return(10.0)

        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: true
        )

        expect(result.success?).to be true
        expect(result.job).to be_persisted
        expect(result.material_costs['concrete']).to be > 0
      end

      it 'fails if cannot afford material costs' do
        # Player has no money
        gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
        player.account.update!(balance: 0)

        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: true
        )

        expect(result.success?).to be false
        expect(result.errors).to include(/Cannot afford/)
      end
    end

    context 'with insufficient funds for tenant fee' do
      before do
        settlement.inventory.items.create!(name: 'concrete', amount: 5, owner: player)
        # Set player balance to 0
        gcc_currency = Financial::Currency.find_by!(symbol: 'GCC')
        player.account.update!(balance: 0)
      end

      it 'fails with insufficient funds error' do
        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(result.success?).to be false
        expect(result.errors).to include(/Cannot afford tenant fee/)
      end
    end

    context 'with invalid blueprint' do
      it 'fails with invalid blueprint error' do
        result = described_class.start_assembly(
          blueprint: "not_a_blueprint",
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(result.success?).to be false
        expect(result.errors).to include(/Invalid blueprint/)
      end
    end

    context 'with invalid settlement' do
      it 'fails with invalid settlement error' do
        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: "not_a_settlement",
          requester: player,
          buy_missing: false
        )

        expect(result.success?).to be false
        expect(result.errors).to include(/Invalid settlement/)
      end
    end
  end

  describe 'job type determination' do
    context 'for unit blueprints' do
      let(:unit_blueprint_data) do
        blueprint_data.merge('category' => 'units')
      end

      before do
        allow_any_instance_of(Lookup::BlueprintLookupService).to receive(:find_blueprint)
          .with('test_structure').and_return(unit_blueprint_data)
        settlement.inventory.items.create!(name: 'concrete', amount: 5, owner: player)
      end

      it 'creates a UnitAssemblyJob' do
        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(result.job).to be_a(UnitAssemblyJob)
      end
    end

    context 'for structure blueprints' do
      before do
        settlement.inventory.items.create!(name: 'concrete', amount: 5, owner: player)
      end

      it 'creates a ConstructionJob' do
        result = described_class.start_assembly(
          blueprint: blueprint,
          settlement: settlement,
          requester: player,
          buy_missing: false
        )

        expect(result.job).to be_a(ConstructionJob)
      end
    end
  end
end