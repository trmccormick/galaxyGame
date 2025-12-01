require 'rails_helper'

RSpec.describe CelestialBodies::BrownDwarf, type: :model do
  let(:brown_dwarf) { create(:brown_dwarf) }
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:orbiting_brown_dwarf) { create(:brown_dwarf, solar_system: solar_system) }

  describe 'validations' do
    it 'is valid with default attributes' do
      expect(brown_dwarf).to be_valid
    end

    it 'allows nil orbital_period' do
      brown_dwarf.orbital_period = nil
      expect(brown_dwarf).to be_valid
    end

    it 'validates orbital_period is greater than or equal to 0 when present' do
      brown_dwarf.orbital_period = -1
      expect(brown_dwarf).not_to be_valid
      
      brown_dwarf.orbital_period = 0
      expect(brown_dwarf).to be_valid
      
      brown_dwarf.orbital_period = 100
      expect(brown_dwarf).to be_valid
    end
  end

  describe 'default attributes' do
    it 'sets default spectral type' do
      expect(brown_dwarf.spectral_type).to be_in(['L', 'T', 'Y'])
    end

    it 'sets default luminosity' do
      expect(brown_dwarf.luminosity).to be_between(0.00001, 0.001)
    end

    it 'sets default effective temperature' do
      expect(brown_dwarf.effective_temperature).to be_between(300, 2500)
    end
  end

  describe '#is_star?' do
    it 'returns false' do
      expect(brown_dwarf.is_star?).to be false
    end
  end

  describe '#is_orbiting_star?' do
    it 'returns false for isolated brown dwarfs' do
      isolated_brown_dwarf = create(:brown_dwarf, solar_system: nil)
      expect(isolated_brown_dwarf.is_orbiting_star?).to be false
    end

    it 'returns true for brown dwarfs in a solar system' do
      expect(orbiting_brown_dwarf.is_orbiting_star?).to be true
    end
  end

  describe '#distance_from_star' do
    it 'returns nil for isolated brown dwarfs' do
      expect(brown_dwarf.distance_from_star).to be_nil
    end

    context 'when part of a solar system' do
      it 'delegates to super when orbiting a star' do
        # We need to set up the star distances for this brown dwarf
        orbiting_brown_dwarf.star_distances.create!(
          star: solar_system.current_star,
          distance: 150000000
        )
        
        expect(orbiting_brown_dwarf.distance_from_star).to eq(150000000)
      end

      it 'returns nil when no star distances exist' do
        expect(orbiting_brown_dwarf.distance_from_star).to be_nil
      end
    end
  end

  describe 'physical properties' do
    it 'has appropriate mass for a brown dwarf' do
      # Brown dwarfs range from ~13 Jupiter masses to 80 Jupiter masses
      # (~1.2e28 kg to ~8e28 kg)
      mass_in_kg = brown_dwarf.mass_kg
      expect(mass_in_kg).to be_between(1.0e28, 8.0e28)
    end

    it 'has appropriate surface temperature for a brown dwarf' do
      # Brown dwarfs are cooler than the smallest stars
      expect(brown_dwarf.surface_temperature).to be < 2500
    end
  end

  describe 'atmospheric and other properties' do
    it 'can have an atmosphere' do
      # Create the atmosphere first
      atmo = brown_dwarf.create_atmosphere!(
        pressure: 50000,  # 0.5 bar, typical for a gas giant
        total_atmospheric_mass: 1.0e21
      )
      
      # Then add gases to it
      atmo.add_gas('H2', 1.0e20)
      atmo.add_gas('He', 1.5e19)
      
      # Reload to get updated percentages
      atmo.reload
      
      # Check the atmosphere and gases
      expect(brown_dwarf.atmosphere).to eq(atmo)
      expect(brown_dwarf.atmosphere.gases.count).to eq(2)
      expect(brown_dwarf.atmosphere.gases.find_by(name: 'H2')).to be_present
      expect(brown_dwarf.atmosphere.gases.find_by(name: 'He')).to be_present
      
      # Check that H2 is the dominant gas
      h2_percentage = brown_dwarf.atmosphere.gases.find_by(name: 'H2').percentage
      he_percentage = brown_dwarf.atmosphere.gases.find_by(name: 'He').percentage
      expect(h2_percentage).to be > he_percentage
    end
  end

  describe 'habitable zones' do
    it 'has a limited habitable zone' do
      # Brown dwarfs generally don't support habitable planets, but
      # this could be a custom method you implement
      skip "Habitable zone calculations not yet implemented for brown dwarfs"
    end
  end

  describe 'relationships with planets' do
    it 'can have orbiting planets' do
      # Test that planets can orbit a brown dwarf
      skip "Brown dwarf planetary systems not yet implemented"
    end
  end
end