# spec/models/gas_spec.rb
require 'rails_helper'

RSpec.describe Gas, type: :model do
  # let(:material) { create(:material) }
  let(:celestial_body) { create(:celestial_body) }
  # let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body) }  # Using the factory correctly

  # it "is valid with valid attributes" do
  #   gas = build(:gas, material: material, atmosphere: atmosphere)
  #   expect(gas).to be_valid
  # end

  it "is not valid without a name" do
    gas = celestial_body.atmosphere.gases.build(name: nil)
    expect(gas).not_to be_valid
  end

  # it "is not valid without a material" do
  #   gas = build(:gas, material: nil, atmosphere: atmosphere)
  #   expect(gas).not_to be_valid
  # end

  # it "is not valid without an atmosphere" do
  #   gas = build(:gas, atmosphere: nil, material: material)
  #   expect(gas).not_to be_valid
  # end

  it "is not valid with a negative percentage" do
    gas = celestial_body.atmosphere.gases.build(percentage: -1.0)
    expect(gas).not_to be_valid
  end

  it "belongs to a material" do
    celestial_body.atmosphere.gases.create(name: "Oxygen", percentage: 21.0)
    celestial_body.save!

    puts celestial_body.gases.inspect

    # check atmosphere to see if it has a gas with the same name
    expect(celestial_body.atmosphere.gases.exists?(name: "Oxygen")).to be true

    # puts celestial_body.materials.inspect

    # check celestial_body to see if it has a material with the same name
    # expect(celestial_body.materials.exists?(name: gas.name)).to be true
  end

  # it "belongs to an atmosphere" do
  #   gas = create(:gas, material: material, atmosphere: atmosphere)
  #   expect(gas.atmosphere).to eq(atmosphere)
  # end
end

