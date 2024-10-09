# spec/models/unit_spec.rb
require 'rails_helper'

RSpec.describe Units::BaseUnit, type: :model do
  let(:colony) { create(:colony) }
  let(:unit) { build(:base_unit, owner: colony, material_list: { 'steel' => 5, 'water' => 10 }) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(unit).to be_valid
    end

    it 'is not valid without a name' do
      unit.name = nil
      expect(unit).to_not be_valid
    end
  end

  describe '#can_be_built?' do
    it 'returns true if enough resources are available' do
      available_resources = { 'steel' => 10, 'water' => 20 }
      expect(unit.can_be_built?(available_resources)).to be_truthy
    end

    it 'returns false if not enough resources are available' do
      available_resources = { 'steel' => 2, 'water' => 5 }
      expect(unit.can_be_built?(available_resources)).to be_falsey
    end
  end

  describe '#build_unit' do
    it 'deducts materials from available resources' do
      available_resources = { 'steel' => 10, 'water' => 20 }
      unit.build_unit(available_resources)
      expect(available_resources).to eq({ 'steel' => 5, 'water' => 10 })
    end
  end

  describe '#consume_resources' do
    it 'consumes resources successfully' do
      available_resources = { 'steel' => 10, 'water' => 20 }
      expect(unit.consume_resources(available_resources)).to be_truthy
      expect(available_resources).to eq({ 'steel' => 5, 'water' => 10 })
    end

    it 'fails if not enough resources are available' do
      available_resources = { 'steel' => 3, 'water' => 20 }
      expect(unit.consume_resources(available_resources)).to be_falsey
    end
  end
end
