# spec/models/base_unit_spec.rb
require 'rails_helper'

RSpec.describe Units::BaseUnit, type: :model do
  let(:available_resources) { { "Power" => 200, "steel" => 50 } }
  let(:unit) { create(:base_unit) }

  it 'can be built with sufficient resources' do
    expect(available_resources["steel"]).to eq(50)
    expect(unit.can_be_built?(available_resources)).to be_truthy
  end

  it 'builds unit and deducts resources' do
    expect(available_resources["steel"]).to eq(50) # Before consuming 10   
    unit.build_unit(available_resources)
    expect(available_resources["steel"]).to eq(40) # After consuming 10
  end

  it 'consumes resources' do
    expect(available_resources["steel"]).to eq(50) # Before consuming 10
    expect(unit.consume_resources(available_resources)).to be_truthy
    expect(available_resources["steel"]).to eq(40) # After consuming 10
  end

  it 'operates successfully' do 
    unit.build_unit(available_resources)
    expect(available_resources["steel"]).to eq(40) # After consuming 10 during build
    unit.operate(available_resources)
    expect(available_resources["steel"]).to eq(30) # After consuming 10
  end
end

