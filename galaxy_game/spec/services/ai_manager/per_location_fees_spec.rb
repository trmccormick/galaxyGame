require 'rails_helper'

RSpec.describe 'Per-Location Market Fee Management', type: :model do
  let(:luna_settlement) { create(:base_settlement, name: 'Lunar Base') }
  let(:orbital_station) { create(:orbital_settlement, name: 'L1 Depot') }

  describe '#broker_fee_type accessor' do
    it 'returns nil by default' do
      expect(luna_settlement.broker_fee_type).to be_nil
    end

    it 'persists via setter' do
      luna_settlement.broker_fee_type = 'percentage'
      expect(luna_settlement.broker_fee_type).to eq('percentage')
      luna_settlement.save!
      luna_settlement.reload
      expect(luna_settlement.broker_fee_type).to eq('percentage')
    end
  end

  describe '#broker_fee_value accessor' do
    it 'returns nil by default' do
      expect(luna_settlement.broker_fee_value).to be_nil
    end

    it 'persists via setter' do
      luna_settlement.broker_fee_value = 5.0
      expect(luna_settlement.broker_fee_value).to eq(5.0)
      luna_settlement.save!
      luna_settlement.reload
      expect(luna_settlement.broker_fee_value).to eq(5.0)
    end
  end

  describe '#transaction_fee_type accessor' do
    it 'returns nil by default' do
      expect(luna_settlement.transaction_fee_type).to be_nil
    end

    it 'persists via setter' do
      luna_settlement.transaction_fee_type = 'fixed'
      expect(luna_settlement.transaction_fee_type).to eq('fixed')
      luna_settlement.save!
      luna_settlement.reload
      expect(luna_settlement.transaction_fee_type).to eq('fixed')
    end
  end

  describe '#transaction_fee_value accessor' do
    it 'returns nil by default' do
      expect(luna_settlement.transaction_fee_value).to be_nil
    end

    it 'persists via setter' do
      luna_settlement.transaction_fee_value = 100.0
      expect(luna_settlement.transaction_fee_value).to eq(100.0)
      luna_settlement.save!
      luna_settlement.reload
      expect(luna_settlement.transaction_fee_value).to eq(100.0)
    end
  end

  describe '#order_duration_min accessor' do
    it 'returns nil by default' do
      expect(luna_settlement.order_duration_min).to be_nil
    end

    it 'persists via setter' do
      luna_settlement.order_duration_min = 2
      expect(luna_settlement.order_duration_min).to eq(2)
      luna_settlement.save!
      luna_settlement.reload
      expect(luna_settlement.order_duration_min).to eq(2)
    end
  end

  describe '#order_duration_max accessor' do
    it 'returns nil by default' do
      expect(luna_settlement.order_duration_max).to be_nil
    end

    it 'persists via setter' do
      luna_settlement.order_duration_max = 48
      expect(luna_settlement.order_duration_max).to eq(48)
      luna_settlement.save!
      luna_settlement.reload
      expect(luna_settlement.order_duration_max).to eq(48)
    end
  end

  describe '#calculate_broker_fee' do
    it 'calculates percentage-based broker fee' do
      luna_settlement.broker_fee_type = 'percentage'
      luna_settlement.broker_fee_value = 5.0

      expect(luna_settlement.calculate_broker_fee(1000)).to eq(50.0)
    end

    it 'calculates fixed broker fee' do
      luna_settlement.broker_fee_type = 'fixed'
      luna_settlement.broker_fee_value = 100.0

      expect(luna_settlement.calculate_broker_fee(1000)).to eq(100.0)
    end

    it 'returns 0 for nil fee configuration' do
      luna_settlement.broker_fee_type = nil
      luna_settlement.broker_fee_value = nil

      expect(luna_settlement.calculate_broker_fee(1000)).to eq(0.0)
    end

    it 'returns 0 when only type is set but not value' do
      luna_settlement.broker_fee_type = 'percentage'
      luna_settlement.broker_fee_value = nil

      expect(luna_settlement.calculate_broker_fee(1000)).to eq(0.0)
    end

    it 'returns 0 for unknown fee type' do
      luna_settlement.broker_fee_type = 'unknown'
      luna_settlement.broker_fee_value = 5.0

      expect(luna_settlement.calculate_broker_fee(1000)).to eq(0.0)
    end

    it 'handles zero amount' do
      luna_settlement.broker_fee_type = 'percentage'
      luna_settlement.broker_fee_value = 5.0

      expect(luna_settlement.calculate_broker_fee(0)).to eq(0.0)
    end

    it 'rounds correctly for percentage calculation' do
      luna_settlement.broker_fee_type = 'percentage'
      luna_settlement.broker_fee_value = 3.5

      expect(luna_settlement.calculate_broker_fee(1234)).to eq(43.19)
    end
  end

  describe '#calculate_transaction_fee' do
    it 'calculates percentage-based transaction fee' do
      luna_settlement.transaction_fee_type = 'percentage'
      luna_settlement.transaction_fee_value = 2.0

      expect(luna_settlement.calculate_transaction_fee(1000)).to eq(20.0)
    end

    it 'calculates fixed transaction fee' do
      luna_settlement.transaction_fee_type = 'fixed'
      luna_settlement.transaction_fee_value = 50.0

      expect(luna_settlement.calculate_transaction_fee(1000)).to eq(50.0)
    end

    it 'returns 0 for nil fee configuration' do
      luna_settlement.transaction_fee_type = nil
      luna_settlement.transaction_fee_value = nil

      expect(luna_settlement.calculate_transaction_fee(1000)).to eq(0.0)
    end

    it 'handles zero amount' do
      luna_settlement.transaction_fee_type = 'percentage'
      luna_settlement.transaction_fee_value = 2.0

      expect(luna_settlement.calculate_transaction_fee(0)).to eq(0.0)
    end
  end

  describe '#default_fee_configuration' do
    it 'returns sensible defaults' do
      config = luna_settlement.default_fee_configuration

      expect(config[:broker_fee_type]).to eq('percentage')
      expect(config[:broker_fee_value]).to eq(5.0)
      expect(config[:transaction_fee_type]).to eq('percentage')
      expect(config[:transaction_fee_value]).to eq(2.0)
      expect(config[:order_duration_min]).to eq(1)
      expect(config[:order_duration_max]).to eq(72)
    end
  end

  describe '#apply_default_fees!' do
    it 'applies default configuration and persists' do
      luna_settlement.apply_default_fees!
      luna_settlement.reload

      expect(luna_settlement.broker_fee_type).to eq('percentage')
      expect(luna_settlement.broker_fee_value).to eq(5.0)
      expect(luna_settlement.transaction_fee_type).to eq('percentage')
      expect(luna_settlement.transaction_fee_value).to eq(2.0)
      expect(luna_settlement.order_duration_min).to eq(1)
      expect(luna_settlement.order_duration_max).to eq(72)
    end

    it 'overwrites existing fee configuration' do
      luna_settlement.broker_fee_type = 'fixed'
      luna_settlement.broker_fee_value = 999.0
      luna_settlement.apply_default_fees!
      luna_settlement.reload

      expect(luna_settlement.broker_fee_type).to eq('percentage')
      expect(luna_settlement.broker_fee_value).to eq(5.0)
    end
  end

  describe 'OrbitalSettlement inherits fee methods' do
    it 'has calculate_broker_fee available' do
      orbital_station.broker_fee_type = 'percentage'
      orbital_station.broker_fee_value = 10.0

      expect(orbital_station.calculate_broker_fee(500)).to eq(50.0)
    end

    it 'has calculate_transaction_fee available' do
      orbital_station.transaction_fee_type = 'fixed'
      orbital_station.transaction_fee_value = 200.0

      expect(orbital_station.calculate_transaction_fee(1000)).to eq(200.0)
    end

    it 'can apply default fees' do
      orbital_station.apply_default_fees!
      orbital_station.reload

      expect(orbital_station.broker_fee_type).to eq('percentage')
      expect(orbital_station.broker_fee_value).to eq(5.0)
    end
  end

  describe 'Per-location fee variation' do
    it 'allows different fees for different settlements' do
      luna_settlement.broker_fee_type = 'percentage'
      luna_settlement.broker_fee_value = 3.0

      orbital_station.broker_fee_type = 'fixed'
      orbital_station.broker_fee_value = 200.0

      expect(luna_settlement.calculate_broker_fee(1000)).to eq(30.0)
      expect(orbital_station.calculate_broker_fee(1000)).to eq(200.0)
    end
  end
end
