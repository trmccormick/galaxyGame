require 'rails_helper'

RSpec.describe CelestialBodies::Atmosphere, type: :model do
  let(:star) { FactoryBot.create(:star) }
  let(:solar_system) { FactoryBot.create(:solar_system, current_star: star) }
  let(:mars) { FactoryBot.create(:celestial_body, :with_solar_system, solar_system: solar_system) }

  let(:atmosphere_composition) do
    {
      "CO2" => { 
        "percentage" => 95.32, 
        "molar_mass" => 44.01, 
        "melting_point" => -56.6, 
        "boiling_point" => -78.5, 
        "vapor_point" => -78.5 
      },
      "N2" => { 
        "percentage" => 2.7, 
        "molar_mass" => 28.01, 
        "melting_point" => -210.0, 
        "boiling_point" => -195.8, 
        "vapor_point" => -195.8 
      },
      "Ar" => { 
        "percentage" => 1.6, 
        "molar_mass" => 39.95, 
        "melting_point" => -189.3, 
        "boiling_point" => -185.8, 
        "vapor_point" => -185.8 
      }
    }
  end

  let(:oxygen) { mars.atmosphere.gases.build(name: "O2", mass: 21.0, molar_mass: 32.0) }
  let(:oxygen_material) do 
    mars.materials.build(
      name: "O2", 
      amount: 21.0, 
      state: "gas", 
      molar_mass: 32.00, 
      melting_point: -218.79, 
      boiling_point: -182.96, 
      vapor_point: -182.96
    )
  end

  describe 'initialization' do
    it 'creates an atmosphere with given gases and attributes' do
      expect(mars).to be_valid
      expect(mars.name).to eq("Mars")
      puts mars.atmosphere.inspect
      expect(mars.atmosphere).to be_valid
      expect(mars.atmosphere.temperature).to eq(mars.surface_temperature)
      expect(mars.atmosphere.pressure).to eq(0)
      expect(mars.atmosphere.total_atmospheric_mass).to eq(0)
      expect(mars.atmosphere.atmosphere_composition).to eq({})
    end

    it 'updates default atmosphere with provided information' do
      mars.atmosphere.update!(
        atmosphere_composition: {
          "CO2" => { "molar_mass" => 44.01, "percentage" => 95.32 },
          "N2" => { "molar_mass" => 28.01, "percentage" => 2.7 },
          "Ar" => { "molar_mass" => 39.95, "percentage" => 1.6 }
        },
        pressure: 0.006,
        total_atmospheric_mass: 2.5e16
      )
    
      # Normalize the keys to symbols for comparison
      updated_composition = mars.atmosphere.atmosphere_composition.transform_keys(&:to_sym)
    
      expect(updated_composition).to eq({
        CO2: { "molar_mass" => 44.01, "percentage" => 95.32 },
        N2: { "molar_mass" => 28.01, "percentage" => 2.7 },
        Ar: { "molar_mass" => 39.95, "percentage" => 1.6 }
      })
      expect(mars.atmosphere.pressure).to eq(0.006)
      expect(mars.atmosphere.total_atmospheric_mass).to eq(2.5e16)
    end
  end

  describe '#reset_gases' do
    before do
      # Setting up the atmosphere composition directly on mars
      mars.atmosphere.update!(
        temperature: mars.surface_temperature,
        pressure: 0.00636,
        total_atmospheric_mass: 2.5e16,
        atmosphere_composition: atmosphere_composition
      )

      # Ensure reset_gases is called before each test
      mars.atmosphere.reset
    end

    it 'creates gases based on the atmosphere_composition' do
      gases = mars.atmosphere.gases

      # Check the gases count matches the atmosphere_composition keys
      expect(gases.count).to eq(3)

      # Validate the attributes for each gas
      co2 = gases.find_by(name: "CO2")
      expect(co2.percentage).to eq(95.32)
      expect(co2.molar_mass).to eq(44.01)
      expect(co2.ppm).to be_within(0.01).of(953_200)
      expect(co2.mass).to be_within(1e13).of(2.383e16)

      n2 = gases.find_by(name: "N2")
      expect(n2.percentage).to eq(2.7)
      expect(n2.molar_mass).to eq(28.01)
      expect(n2.ppm).to be_within(0.01).of(27_000)
      expect(n2.mass).to be_within(1e13).of(6.75e14)

      ar = gases.find_by(name: "Ar")
      expect(ar.percentage).to eq(1.6)
      expect(ar.molar_mass).to eq(39.95)
      expect(ar.ppm).to be_within(0.01).of(16_000)
      expect(ar.mass).to be_within(1e13).of(4e14)
    end

    it 'clears existing gases and resets with a new composition' do
      # Verify initial atmosphere gases count based on the initial setup
      expect(mars.atmosphere.gases.count).to eq(3)
    
      # Change atmosphere composition to a new set of gases
      new_atmosphere_composition = {
        "O2" => { "percentage" => 21.0, "molar_mass" => 32.00 },
        "N2" => { "percentage" => 78.0, "molar_mass" => 28.01 },
        "CO2" => { "percentage" => 0.04, "molar_mass" => 44.01 }
      }
    
      # Update atmosphere composition
      mars.atmosphere.update!(atmosphere_composition: new_atmosphere_composition)
    
      # Reload the atmosphere to ensure changes are applied
      mars.reload
    
      # Call reset method to update the gases according to the new composition
      mars.atmosphere.reset
    
      # Reload gases after reset
      mars.atmosphere.gases.reload
    
      # Verify that the gases count remains the same
      expect(mars.atmosphere.gases.count).to eq(3)
    
      # Verify that the gases have been updated with the new composition
      new_gases = mars.atmosphere.gases.pluck(:name, :percentage)
    
      expect(new_gases).to match_array([
        ['O2', 21.0],
        ['N2', 78.0],
        ['CO2', 0.04]
      ])
    end
  end

  # describe '#add_gas' do
  #   it 'adds gas and recalculates percentages using total_atmospheric_mass' do
  #     mars.atmosphere.add_gas(oxygen)
  #     expect(mars.atmosphere.total_atmospheric_mass).to eq(21.0)
  #     expect(mars.atmosphere.gases.find_by(name: "O2").percentage).to eq(100.0)
  #   end
  # end

  describe '#remove_gas' do
    it 'removes gas and updates total atmospheric mass' do
      mars.atmosphere.update!(
        atmosphere_composition: {
          "CO2" => { "percentage" => 100.0, "molar_mass" => 44.01, "melting_point" => -56.6, "boiling_point" => -78.5, "vapor_pressure" => 5.73e6 },
        },
        pressure: 0,
        total_atmospheric_mass: 30.0
      )

      mars.atmosphere.reset

      puts mars.atmosphere.inspect

      mars.atmosphere.remove_gas("CO2", 10.0)

      expect(mars.atmosphere.gases.find_by(name: "CO2").mass).to eq(20.0)
      expect(mars.atmosphere.gases.find_by(name: "CO2").percentage).to eq(100.0)
      expect(mars.atmosphere.total_atmospheric_mass).to eq(20.0)
    end

    # it 'removes gas and updates total atmospheric mass' do
    #   mars.atmosphere.update!(
    #     atmosphere_composition: { 
    #       "CO2" => { percentage: 95.32, molar_mass: 44.01, melting_point: -56.6, boiling_point: -78.5, vapor_pressure: 5.73e6 }, 
    #       "N2" => { percentage: 2.7, molar_mass: 28.01, melting_point: -210.0, boiling_point: -195.8, vapor_pressure: 0 }, 
    #       "Ar" => { percentage: 1.6, molar_mass: 39.95, melting_point: -189.3, boiling_point: -185.8, vapor_pressure: 0 } 
    #     }, 
    #     pressure: 0.006,
    #     total_atmospheric_mass: 2.5e16
    #   )

    #   mars.atmosphere.reset

    #   # Get mars co2 gas
    #   co2 = mars.atmosphere.gases.find_by(name: "CO2")
    #   co2_mass = co2.mass

    #   expect(co2.percentage).to eq(95.32)

    #   # Remove half of the CO2 mass
    #   mars.atmosphere.remove_gas("CO2", co2_mass / 2)

    #   co2 = mars.atmosphere.gases.find_by(name: "CO2")
    #   puts co2.inspect

    #   expect(co2.mass).to eq(co2_mass / 2)
    #   # expect(co2.percentage).to be_within(0.01).of(95.32 * (1.25e16 - (co2_mass / 2)) / (2.5e16 - (co2_mass / 2)))
    #   # expect(mars.atmosphere.total_atmospheric_mass).to eq(2.5e16 - (co2_mass / 2))
    # end
    
    # it 'removes gas completely and updates total mass' do
    #   mars.atmosphere.remove_gas("O2", 21.0)
    #   expect(atmosphere.total_atmospheric_mass).to eq(0)
    #   expect(atmosphere.gases.find_by(name: "O2")).to be_nil
    # end
  end

  # describe '#add_material' do
  #   it 'updates the corresponding material when adding gas' do
  #     mars.atmosphere.add_gas(oxygen)
  #     expect(celestial_body.materials.find_by(name: "O2").amount).to eq(21.0)
  #   end 
  # end

  # describe '#remove_gas' do
  #   before do
  #     mars.atmosphere.add_gas(Gas.new(name: "O2", mass: 21.0))
  #     mars.atmosphere.add_gas(Gas.new(name: "CO2", mass: 5.0))
  #   end

  #   it 'removes the specified mass of an existing gas and recalculates percentages' do
  #     existing_oxygen = mars.atmosphere.gases.find { |gas| gas.name == "O2" }
  #     expect(existing_oxygen.mass).to eq(21.0)

  #     # Remove 5.0 units of O2
  #     mars.atmosphere.remove_gas("O2", 5.0)
  #     updated_oxygen = mars.atmosphere.gases.find { |gas| gas.name == "O2" }

  #     # Check that the mass has been updated
  #     expect(updated_oxygen.mass).to eq(16.0)

  #     # Recalculate expected percentage
  #     total_mass = mars.atmosphere.total_mass
  #     expect(updated_oxygen.percentage).to eq((updated_oxygen.mass / total_mass) * 100)
  #   end

  #   it 'raises an error if trying to remove more mass than exists' do
  #     expect {
  #       mars.atmosphere.remove_gas("O2", 22.0)
  #     }.to raise_error("Cannot remove more mass than exists for O2")
  #   end

  #   it 'removes the gas completely if the mass goes to zero' do
  #     mars.atmosphere.remove_gas("O2", 21.0)
  #     expect(mars.atmosphere.gases.find { |gas| gas.name == "O2" }).to be_nil
  #   end

  #   it 'raises an error if the gas does not exist' do
  #     expect {
  #       mars.atmosphere.remove_gas("H2", 5.0)
  #     }.to raise_error("Gas H2 does not exist in the atmosphere")
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
  #     expected_string = "Atmosphere: Gases - [Oxygen: 21.0%, Nitrogen: 78.0%], Pressure - 1 atm, Temperature - 300K"
  #     expect(atmosphere.to_s).to include(expected_string)
  #   end
  # end
end

