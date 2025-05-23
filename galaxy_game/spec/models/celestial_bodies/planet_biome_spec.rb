# spec/models/celestial_bodies/planet_biome_spec.rb
require 'rails_helper'

module CelestialBodies # Wrap the RSpec.describe in the module
  RSpec.describe PlanetBiome, type: :model do
    # Define factories for associated models
    let(:celestial_body) { create(:celestial_body) }
    # Use the explicit factory name for Biosphere
    let(:biosphere) { create(:biosphere, celestial_body: celestial_body) }
    # Biome is a top-level model, so its factory name is just :biome
    let(:biome) { create(:biome) }

    # Subject for the spec, correctly associating with a biosphere
    subject {
      described_class.new(
        biome: biome,
        biosphere: biosphere
      )
    }

    describe 'associations' do
      it { should belong_to(:biome) }
      # Correct association: PlanetBiome belongs to Biosphere (namespaced)
      it { should belong_to(:biosphere).class_name('CelestialBodies::Spheres::Biosphere') }
    end

    describe 'validations' do
      it "is valid with valid attributes" do
        expect(subject).to be_valid
      end

      it "is not valid without a biome" do
        subject.biome = nil
        expect(subject).to_not be_valid
      end

      it "is not valid without a biosphere" do
        subject.biosphere = nil
        expect(subject).to_not be_valid
      end

      it { should validate_uniqueness_of(:biome_id).scoped_to(:biosphere_id) }
    end

    describe 'jsonb properties' do
      # Test that the store_accessor attributes can be set and retrieved
      it 'can set and retrieve area_percentage' do
        subject.area_percentage = 75.5
        expect(subject.area_percentage).to eq(75.5)
      end

      it 'can set and retrieve vegetation_cover' do
        subject.vegetation_cover = 0.8
        expect(subject.vegetation_cover).to eq(0.8)
      end

      # UPDATED: Changed to use moisture_level instead of water_level
      it 'can set and retrieve moisture_level' do
        subject.moisture_level = 0.6
        expect(subject.moisture_level).to eq(0.6)
      end

      it 'can set and retrieve latitude' do
        subject.latitude = 30.0
        expect(subject.latitude).to eq(30.0)
      end

      it 'can set and retrieve biodiversity' do
        subject.biodiversity = 0.9
        expect(subject.biodiversity).to eq(0.9)
      end

      # Test backward compatibility (still important to test)
      it 'supports deprecated water_level with warning' do
        expect(ActiveSupport::Deprecation).to receive(:warn).with("water_level= is deprecated, use moisture_level= instead")
        expect(ActiveSupport::Deprecation).to receive(:warn).with("water_level is deprecated, use moisture_level instead")
        
        subject.water_level = 0.6
        expect(subject.water_level).to eq(0.6)
        expect(subject.moisture_level).to eq(0.6) # Also test that it sets the correct underlying value
      end

      # Test default values set by after_initialize
      describe 'default values for properties' do
        let(:new_planet_biome) {
          described_class.new(
            biome: biome,
            biosphere: biosphere
          )
        }

        it 'defaults area_percentage to 0.0' do
          expect(new_planet_biome.area_percentage).to eq(0.0)
        end

        it 'defaults vegetation_cover to 0.0' do
          expect(new_planet_biome.vegetation_cover).to eq(0.0)
        end

        # UPDATED: Changed to use moisture_level instead of water_level
        it 'defaults moisture_level to 0.0' do
          expect(new_planet_biome.moisture_level).to eq(0.0)
        end

        it 'defaults latitude to 0.0' do
          expect(new_planet_biome.latitude).to eq(0.0)
        end

        it 'defaults biodiversity to 0.0' do
          expect(new_planet_biome.biodiversity).to eq(0.0)
        end
      end
    end

    describe 'callbacks' do
      # Assuming biosphere.calculate_biodiversity_index and biosphere.save are implemented
      it 'updates biosphere biodiversity after creation' do
        expect(biosphere).to receive(:calculate_biodiversity_index)
        expect(biosphere).to receive(:save)
        # Use the explicit factory name for CelestialBodies::PlanetBiome
        create(:celestial_bodies_planet_biome, biome: biome, biosphere: biosphere)
      end

      it 'updates biosphere biodiversity after destruction' do
        # Use the explicit factory name for CelestialBodies::PlanetBiome
        planet_biome = create(:celestial_bodies_planet_biome, biome: biome, biosphere: biosphere)
        expect(biosphere).to receive(:calculate_biodiversity_index)
        expect(biosphere).to receive(:save)
        planet_biome.destroy
      end
    end

    it "has access to celestial_body through biosphere" do
      planet_biome = create(:celestial_bodies_planet_biome, biosphere: biosphere)
      expect(planet_biome.celestial_body).to eq(biosphere.celestial_body)
    end
  end
end