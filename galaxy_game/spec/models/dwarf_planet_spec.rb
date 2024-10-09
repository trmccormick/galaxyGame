require 'rails_helper'

RSpec.describe CelestialBodies::DwarfPlanet, type: :model do
  let(:dwarf_planet) do
    DwarfPlanet.create!(
      name: "Pluto",
      size: 0.18,
      gravity: 0.62,
      density: 1.86,
      orbital_period: 90560,
      mass: 1.303e22, # Example mass in kg
      radius: 1.19e6, # Example radius in meters
      gas_quantities: { "Nitrogen" => 8000, "Methane" => 1000 },
      temperature: 44.0 # Example temperature
    )
  end

  describe '#calculate_surface_conditions' do
    it 'calculates surface conditions specific to dwarf planets' do
      dwarf_planet.calculate_surface_conditions
      # Add expectations based on surface conditions calculation
    end
  end

  describe '#update_biomes' do
    it 'updates biomes specific to dwarf planets' do
      dwarf_planet.temperature = 50 # Example temperature for Pluto
      dwarf_planet.calculate_total_pressure
      dwarf_planet.update_biomes
      expect(dwarf_planet.biomes).to include('Icy Plains')
    end
  end
end
