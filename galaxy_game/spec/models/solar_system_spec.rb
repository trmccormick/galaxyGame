require 'rails_helper'

RSpec.describe SolarSystem, type: :model do
  let(:star) { FactoryBot.create(:star) }
  let(:solar_system) { FactoryBot.create(:solar_system, current_star: star) }

  describe 'associations' do
    it { should belong_to(:current_star).class_name('Star').optional }
    it { should have_many(:celestial_bodies) }
    it { should have_many(:terrestrial_planets) }
    it { should have_many(:gas_giants) }
    it { should have_many(:ice_giants) }
    it { should have_many(:moons) }
    it { should have_many(:dwarf_planets) }
  end

  describe 'callbacks' do
    # it 'sets initial star to "Sun" after creation if no star is provided' do
    #   solar_system = create(:solar_system)
    #   expect(solar_system.current_star.name).to eq('Sun')
    # end

    it 'does not change the star if one is provided' do
      solar_system
      expect(solar_system.current_star.name).to eq('Sol')
    end
  end

  describe '#load_star' do
    it 'loads or updates the star with given parameters' do
      solar_system.load_star(name: 'Proxima Centauri', type_of_star: 'M-type', age: 4.85)
      expect(solar_system.current_star.name).to eq('Proxima Centauri')
    end
  end

  describe '#load_terrestrial_planet' do
    it 'loads or updates a terrestrial planet' do
      solar_system
      params = attributes_for(:terrestrial_planet, name: 'Earth')
      solar_system.load_terrestrial_planet(params)
      planet = solar_system.terrestrial_planets.find_by(name: 'Earth')
      expect(planet).to be_present
      expect(planet.size).to eq(1.0)
    end
  end

#   describe '#load_gas_giant' do
#     it 'loads or updates a gas giant' do
#       params = attributes_for(:gas_giant, name: 'Jupiter')
#       solar_system.load_gas_giant(params)
#       gas_giant = solar_system.gas_giants.find_by(name: 'Jupiter')
#       expect(gas_giant.name).to eq('Jupiter')
#       expect(gas_giant.mass).to eq(1.898e27)
#     end
#   end

#   describe '#load_ice_giant' do
#     it 'loads or updates an ice giant' do
#       params = attributes_for(:ice_giant, name: 'Neptune')
#       solar_system.load_ice_giant(params)
#       ice_giant = solar_system.ice_giants.find_by(name: 'Neptune')
#       expect(ice_giant.name).to eq('Neptune')
#       expect(ice_giant.mass).to eq(1.024e26)
#     end
#   end

#   describe '#load_moon' do
#     it 'loads or updates a moon' do
#       params = attributes_for(:moon, name: 'Moon')
#       solar_system.load_moon(params)
#       moon = solar_system.moons.find_by(name: 'Moon')
#       expect(moon.name).to eq('Moon')
#       expect(moon.mass).to eq(7.342e22)
#     end
#   end

#   describe '#load_dwarf_planet' do
#     it 'loads or updates a dwarf planet' do
#       params = attributes_for(:dwarf_planet, name: 'Pluto')
#       solar_system.load_dwarf_planet(params)
#       dwarf_planet = solar_system.dwarf_planets.find_by(name: 'Pluto')
#       expect(dwarf_planet.name).to eq('Pluto')
#       expect(dwarf_planet.mass).to eq(1.309e22)
#     end
#   end

#   describe '#total_mass' do
#     it 'calculates total mass of all planets and dwarf planets' do
#       create(:terrestrial_planet, solar_system: solar_system)
#       create(:gas_giant, solar_system: solar_system)
#       create(:ice_giant, solar_system: solar_system)
#       create(:dwarf_planet, solar_system: solar_system)

#       total_mass = solar_system.total_mass
#       expected_mass = 5.972e24 + 1.898e27 + 1.024e26 + 1.309e22
#       expect(total_mass).to eq(expected_mass)
#     end
#   end
end

describe '#habitable_zone?' do
  let(:star) { FactoryBot.create(:star, mass: 1.0) }
  let(:solar_system) { FactoryBot.create(:solar_system, current_star: star) }
  let(:planet) { FactoryBot.create(:terrestrial_planet, solar_system: solar_system, orbital_period: 365) }

  it 'returns true if the planet is in the habitable zone' do
    expect(solar_system.habitable_zone?(planet)).to be true
  end

  it 'returns false if the planet is outside the habitable zone' do
    planet.update(orbital_period: 1000)
    expect(solar_system.habitable_zone?(planet)).to be false
  end

  it 'returns false if the star is not present' do
    solar_system.update(current_star: nil)
    expect(solar_system.habitable_zone?(planet)).to be false
  end

  it 'returns false if the planet does not have an orbital period' do
    planet.update(orbital_period: nil)
    expect(solar_system.habitable_zone?(planet)).to be false
  end
end