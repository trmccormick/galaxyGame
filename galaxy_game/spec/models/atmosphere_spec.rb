require 'rails_helper'

RSpec.describe Atmosphere, type: :model do
  let(:mars) { create(:celestial_body) }
  
  # subject(:atmosphere) { Atmosphere.new(celestial_body: celestial_body, oceans: 1000, lakes: 500, rivers: 200, ice: 300) }
  
  # let(:oxygen) do
  #   instance_double("Gas", name: "Oxygen", percentage: 21.0, moles: 1.0, add_to_atmosphere: nil)
  # end
  
  # let(:nitrogen) do
  #   instance_double("Gas", name: "Nitrogen", percentage: 78.0, moles: 1.0, add_to_atmosphere: nil)
  # end

  # let(:carbon_dioxide) do
  #   instance_double("Gas", name: "CO2", percentage: 0.04, moles: 0.001, add_to_atmosphere: nil)
  # end

  # let(:atmosphere) { Atmosphere.new(gases: [oxygen, nitrogen], pressure: 1, temperature: 300) }

  describe 'initialization' do
    it 'creates an atmosphere with given gases and attributes' do
      atmosphere_composition = { "Carbon Dioxide" => 95, "Nitrogen" => 2.8, "Argon" => 2.0, "Oxygen" => 0.174, "Carbon Monoxide" => 0.0747, "Water Vapor" => 0.03 }
      pressure = 0.00636
      total_atmospheric_mass = 2.5e16

      atmosphere = Atmosphere.new(celestial_body: :mars, temperature: 300, pressure: pressure, atmosphere_composition: atmosphere_composition, total_atmospheric_mass: total_atmospheric_mass)
      expect(atmosphere.gases).to include("Oxygen", "Nitrogen")
      expect(atmosphere.pressure).to eq(0.00636)
      expect(atmosphere.temperature).to eq(300)

      puts mars.materials.inspect
    end
  end

  # describe '#add_gas' do
  #   it 'adds a new gas to the atmosphere' do
  #     atmosphere.add_gas(carbon_dioxide)
  #     expect(atmosphere.gases).to include(carbon_dioxide)
  #     expect(atmosphere.pressure).to be > 1 # Check if pressure has changed
  #   end

  #   it 'updates the percentage of an existing gas' do
  #     existing_oxygen = atmosphere.gases.find { |g| g.name == "Oxygen" }
  #     initial_percentage = existing_oxygen.percentage
  #     new_oxygen = instance_double("Gas", name: "Oxygen", percentage: 5.0, moles: 0.5, add_to_atmosphere: nil)

  #     atmosphere.add_gas(new_oxygen)
  #     updated_oxygen = atmosphere.gases.find { |g| g.name == "Oxygen" }

  #     expect(updated_oxygen.percentage).to eq(initial_percentage + 5.0)
  #   end
  # end

  # describe '#remove_gas' do
  #   it 'removes a gas from the atmosphere by name' do
  #     atmosphere.remove_gas("Oxygen")
  #     expect(atmosphere.gases.find { |g| g.name == "Oxygen" }).to be_nil
  #     expect(atmosphere.pressure).to be < 1 # Check if pressure has decreased
  #   end
  # end

  # describe '#calculate_pressure' do
  #   it 'calculates the overall atmospheric pressure based on gases' do
  #     initial_pressure = atmosphere.pressure
  #     atmosphere.add_gas(carbon_dioxide)
  #     expect(atmosphere.pressure).to be > initial_pressure
  #   end
  # end

  # describe '#to_s' do
  #   it 'returns a string representation of the atmosphere' do
  #     expect(atmosphere.to_s).to include("Atmosphere: Gases - [Oxygen: 21.0%, Nitrogen: 78.0%]")
  #     expect(atmosphere.to_s).to include("Pressure - 1 atm, Temperature - 300K")
  #   end
  # end
end
