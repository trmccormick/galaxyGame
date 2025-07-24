require 'rails_helper'

RSpec.describe CelestialBodies::CelestialBody, type: :model do
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:mars) { create(:terrestrial_planet, :mars, solar_system: solar_system) }

  describe 'associations' do
    it { is_expected.to belong_to(:solar_system).optional }
    it { is_expected.to have_one(:spatial_location).dependent(:destroy) }
    it { is_expected.to have_many(:locations).dependent(:destroy) }
    it { is_expected.to have_one(:atmosphere).dependent(:destroy) }
    it { is_expected.to have_one(:biosphere).dependent(:destroy) }
    it { is_expected.to have_one(:geosphere).dependent(:destroy) }
    it { is_expected.to have_one(:hydrosphere).dependent(:destroy) }
  end

  describe 'material management' do
    describe '#add_material' do
      it 'creates or updates material properly' do
        expect { mars.add_material('oxygen', 100) }.to change { mars.materials.count }.by(1)
        expect { mars.add_material('oxygen', 50) }.not_to change { mars.materials.count }
        expect(mars.materials.find_by(name: 'oxygen').amount).to eq(150)
      end

      it 'updates atmosphere gases if material is a gas' do
        mars.add_material('oxygen', 100)
        expect(mars.atmosphere.gases.find_by(name: 'O2')).to be_present
      end
    end

    describe '#remove_material' do
      before { mars.add_material('oxygen', 100) }

      it 'reduces material amount and deletes if zero' do
        mars.remove_material('oxygen', 50)
        expect(mars.materials.find_by(name: 'oxygen').amount).to eq(50)
        mars.remove_material('oxygen', 50)
        expect(mars.materials.find_by(name: 'oxygen')).to be_nil
      end

      it 'updates atmosphere gases accordingly' do
        mars.remove_material('oxygen', 100)
        expect(mars.atmosphere.gases.find_by(name: 'O2')).to be_nil
      end
    end
  end

  describe 'calculated properties' do
    let(:planet) { build(:celestial_body, radius: 6371000.0, mass: '5.97e24') }

    it 'calculates surface_area correctly' do
      expected_area = 4 * Math::PI * (planet.radius ** 2)
      expect(planet.surface_area).to be_within(0.1).of(expected_area)
    end

    it 'calculates volume correctly' do
      expected_volume = (4.0 / 3.0) * Math::PI * (planet.radius ** 3)
      expect(planet.volume).to be_within(0.1).of(expected_volume)
    end

    it 'calculates escape_velocity correctly' do
      g = GameConstants::GRAVITATIONAL_CONSTANT
      expected_velocity = Math.sqrt(2 * g * planet.mass.to_f / planet.radius)
      expect(planet.send(:calculate_escape_velocity)).to be_within(0.001).of(expected_velocity)
    end
  end

  describe '#distance_from_star' do
    it 'returns nil if no star distance' do
      planet = create(:terrestrial_planet, solar_system: nil)
      expect(planet.distance_from_star).to be_nil
    end

    it 'returns distance when star_distances present' do
      star_distance = double('StarDistance', distance: 150_000_000, star: star)
      allow(mars).to receive(:star_distances).and_return([star_distance])
      expect(mars.star_distances.first.distance).to eq(150_000_000)
    end
  end

  describe '#is_moon' do
    it 'returns false for normal celestial bodies' do
      expect(mars.is_moon).to be_falsey
    end

    it 'returns true if type is moon' do
      allow(mars).to receive(:type).and_return('CelestialBodies::Moon')
      expect(mars.is_moon).to be_truthy
    end
  end

  describe 'properties JSONB accessors' do
    it 'can read and write last_simulated_at' do
      mars.last_simulated_at = Time.now.utc
      mars.save!
      expect(mars.last_simulated_at).to be_a(Time)
    end
  end

  describe '#planet_class?' do
    it 'returns true for a planet type' do
      allow(mars).to receive(:type).and_return('CelestialBodies::Planets::Rocky::TerrestrialPlanet')
      expect(mars.planet_class?).to be true
    end

    it 'returns false for nil type' do
      allow(mars).to receive(:type).and_return(nil)
      expect(mars.planet_class?).to be false
    end

    it 'returns false for non-planet type' do
      allow(mars).to receive(:type).and_return('CelestialBodies::Moon')
      expect(mars.planet_class?).to be false
    end
  end

  describe '#should_simulate?' do
    it 'returns false if not active' do
      allow(mars).to receive(:active?).and_return(false)
      expect(mars.should_simulate?).to be false
    end

    it 'returns false if radius is too small' do
      allow(mars).to receive(:radius).and_return(500)
      expect(mars.should_simulate?).to be false
    end

    it 'returns true for planet_class? or is_moon' do
      allow(mars).to receive(:active?).and_return(true)
      allow(mars).to receive(:radius).and_return(6371000)
      allow(mars).to receive(:planet_class?).and_return(true)
      expect(mars.should_simulate?).to be true
    end

    it 'returns true if force_simulate property is set' do
      allow(mars).to receive(:active?).and_return(true)
      allow(mars).to receive(:radius).and_return(6371000)
      allow(mars).to receive(:planet_class?).and_return(false)
      allow(mars).to receive(:is_moon).and_return(false)
      allow(mars).to receive(:properties).and_return({ 'force_simulate' => true })
      expect(mars.should_simulate?).to be true
    end
  end
end
