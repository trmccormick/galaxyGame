# spec/models/structures/converted_base_spec.rb

require 'rails_helper'

RSpec.describe Structures::ConvertedBase, type: :model do
  let(:converted_base) { build(:converted_base) }

  before do
    asteroid = double('asteroid',
      composition_type: :metallic,
      estimated_mineral_value: 1_000_000,
      typical_rotation_period: 0.05,
      respond_to?: true
    )
    allow(converted_base).to receive(:host_body).and_return(asteroid)
  end

  describe '#construction_materials' do
    it 'returns correct materials for carbonaceous host' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', composition_type: :carbonaceous, respond_to?: true))
      expect(converted_base.construction_materials).to eq({ local: [:carbon, :silicates], multiplier: 1.2 })
    end

    it 'returns correct materials for metallic host' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', composition_type: :metallic, respond_to?: true))
      expect(converted_base.construction_materials).to eq({ local: [:iron, :nickel, :rare_earths], multiplier: 2.5 })
    end

    it 'returns correct materials for silicaceous host' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', composition_type: :silicaceous, respond_to?: true))
      expect(converted_base.construction_materials).to eq({ local: [:silica, :oxygen], multiplier: 1.5 })
    end

    it 'returns regolith for unknown host type' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', composition_type: :unknown, respond_to?: true))
      expect(converted_base.construction_materials).to eq({ local: [:regolith], multiplier: 1.0 })
    end
  end

  describe '#shielding_rating' do
    it 'returns 0 if host_body does not respond to estimated_mineral_value' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', respond_to?: false))
      expect(converted_base.shielding_rating).to eq(0)
    end

    it 'returns 0 if estimated_mineral_value is nil' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', respond_to?: true, estimated_mineral_value: nil))
      expect(converted_base.shielding_rating).to eq(0)
    end

    it 'returns mineral value divided by 1_000_000 if present' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', respond_to?: true, estimated_mineral_value: 5_000_000))
      expect(converted_base.shielding_rating).to eq(5_000_000 / 1_000_000)
    end
  end

  describe '#rotation_stress_factor' do
    it 'returns 1.0 if host body has no typical_rotation_period' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', respond_to?: false))
      expect(converted_base.rotation_stress_factor).to eq(1.0)
    end

    it 'returns 2.5 for fast rotation' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', respond_to?: true, typical_rotation_period: 0.05))
      expect(converted_base.rotation_stress_factor).to eq(2.5)
    end

    it 'returns 1.2 for moderate rotation' do
      allow(converted_base).to receive(:host_body).and_return(double('asteroid', respond_to?: true, typical_rotation_period: 0.2))
      expect(converted_base.rotation_stress_factor).to eq(1.2)
    end
  end

  describe '#habitat_capacity' do
    it 'returns 0 with no units' do
      allow(converted_base).to receive_message_chain(:base_units, :sum).and_return(0)
      expect(converted_base.habitat_capacity).to eq(0)
    end
  end
end
