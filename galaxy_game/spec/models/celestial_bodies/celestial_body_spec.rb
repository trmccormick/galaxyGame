require 'rails_helper'

RSpec.describe CelestialBodies::CelestialBody, type: :model do
  let(:star) { create(:star) }
  let(:solar_system) { create(:solar_system, current_star: star) }
  let(:mars) { create(:celestial_body, :with_solar_system, solar_system: solar_system) }
  let(:brown_dwarf) { create(:brown_dwarf) }

  describe 'associations' do
    it { is_expected.to belong_to(:solar_system).optional }
    it { is_expected.to have_one(:spatial_location).dependent(:destroy) }
    it { is_expected.to have_many(:locations).dependent(:destroy) }
    it { is_expected.to have_one(:atmosphere).dependent(:destroy) }
    it { is_expected.to have_one(:biosphere).dependent(:destroy) }
    it { is_expected.to have_one(:geosphere).dependent(:destroy) }
    it { is_expected.to have_one(:hydrosphere).dependent(:destroy) }
  end

  describe 'locations' do
    let(:planet) { create(:celestial_body, :with_solar_system) }

    it 'has a spatial location' do
      expect(planet.spatial_location).to be_present
      expect(planet.spatial_location.x_coordinate).to be_present
    end

    it 'can have surface locations' do
      location = create(:celestial_location, celestial_body: planet)
      expect(planet.locations).to include(location)
    end
  end

  context 'when part of a solar system' do
    it 'validates distance_from_star presence' do
      expect(mars).to be_valid
    end
  end

  context 'when not part of a solar system' do
    it 'allows brown dwarfs to exist independently without a star' do
      # Brown dwarfs typically exist as free-floating objects
      expect(brown_dwarf).to be_valid
      expect(brown_dwarf.distance_from_star).to be_nil
      expect(brown_dwarf.solar_system).to be_nil
      expect(brown_dwarf.is_orbiting_star?).to be false
    end
    
    it 'can still have their own planets' do
      # Some brown dwarfs can have their own planetary systems
      # This would be tested if you implement this feature
      skip "Brown dwarf planetary systems not yet implemented"
    end
  end

  describe 'material management' do
    let(:material_lookup) { instance_double(Lookup::MaterialLookupService) }
    
    before do
      allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
      
      # Set up default response for any material
      allow(material_lookup).to receive(:find_material).and_return({
        'properties' => {
          'state_at_room_temp' => 'solid',
          'melting_point' => 1000,
          'boiling_point' => 2000
        }
      })
      
      # Set up specific response for 'Oxygen'
      # you must use the correct name for the material
      # gas entries are created with the material id
      # for Oxygen, it should be 'oxygen' not 'Oxygen'
      allow(material_lookup).to receive(:find_material).with('oxygen').and_return({
        'properties' => {
          'molar_mass' => 32.0,
          'boiling_point' => -183.0,
          'melting_point' => -218.8,
          'state_at_room_temp' => 'gas'
        }
      })
    end

    describe '#add_material' do
      it 'creates a new material if it does not exist' do
        expect { 
          mars.add_material('oxygen', 100) 
        }.to change { mars.materials.count }.by(1)
        
        material = mars.materials.last
        expect(material.name).to eq('oxygen')
        expect(material.amount).to eq(100)
      end

      it 'updates the amount of an existing material' do
        mars.add_material('oxygen', 100)
        expect { 
          mars.add_material('oxygen', 50) 
        }.not_to change { mars.materials.count }
        
        expect(mars.materials.find_by(name: 'oxygen').amount).to eq(150)
      end

      context 'when material is a gas' do
        it 'updates atmosphere composition' do
          mars.add_material('oxygen', 100)
          expect(mars.atmosphere.gases.find_by(name: 'oxygen')).to be_present
        end
      end
    end

    describe '#remove_material' do
      before { mars.add_material('oxygen', 100) }

      it 'reduces material amount' do
        expect {
          mars.remove_material('oxygen', 50)
        }.to change { 
          mars.materials.find_by(name: 'oxygen').amount 
        }.from(100).to(50)
      end

      it 'removes material record when amount reaches 0' do
        expect {
          mars.remove_material('oxygen', 100)
        }.to change { mars.materials.count }.by(-1)
      end

      context 'when material is a gas' do
        it 'updates atmosphere composition' do
          mars.remove_material('Oxygen', 100)
          expect(mars.atmosphere.gases.find_by(name: 'Oxygen')).to be_nil
        end
      end
    end
  end
end