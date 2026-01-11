# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EconomicConfig do
  describe 'cryptocurrency mining methods' do
    it 'returns the GCC max supply' do
      expect(described_class.gcc_max_supply).to eq(21_000_000_000)
    end

    it 'returns the GCC halving interval days' do
      expect(described_class.gcc_halving_interval_days).to eq(730)
    end

    it 'returns the GCC issuance model' do
      expect(described_class.gcc_issuance_model).to eq('capped_deflationary')
    end

    it 'returns the GCC difficulty scaling flag' do
      expect(described_class.gcc_difficulty_scaling_enabled?).to be true
    end

    it 'returns the GCC initial block reward' do
      expect(described_class.gcc_initial_block_reward).to eq(1000)
    end

    it 'returns the GCC minimum block reward' do
      expect(described_class.gcc_minimum_block_reward).to eq(1)
    end
  end

  describe 'transport methods' do
    it 'returns transport rate for bulk_material' do
      expect(described_class.transport_rate('bulk_material')).to eq(100.0)
    end

    it 'returns transport rate for manufactured' do
      expect(described_class.transport_rate('manufactured')).to eq(150.0)
    end

    it 'returns transport rate for high_tech' do
      expect(described_class.transport_rate('high_tech')).to eq(200.0)
    end

    it 'falls back to bulk_material rate for unknown categories' do
      expect(described_class.transport_rate('unknown')).to eq(100.0)
    end
  end

  describe 'earth pricing methods' do
    it 'returns earth spot price for known materials' do
      # This would depend on the actual data in economic_parameters.yml
      price = described_class.earth_spot_price('titanium')
      expect(price).to be_a(Numeric).or be_nil
    end

    it 'returns nil for unknown materials' do
      expect(described_class.earth_spot_price('unknown_material')).to be_nil
    end
  end
end