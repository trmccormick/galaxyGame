# spec/models/location/spatial_location_spec.rb
require 'rails_helper'

RSpec.describe Location::SpatialLocation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:spatial_context).optional }
    it { is_expected.to belong_to(:locationable).optional }
  end

  describe 'validations' do
    subject { build(:spatial_location) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:x_coordinate) }
    it { is_expected.to validate_presence_of(:y_coordinate) }
    it { is_expected.to validate_presence_of(:z_coordinate) }
    
    it { is_expected.to validate_numericality_of(:x_coordinate) }
    it { is_expected.to validate_numericality_of(:y_coordinate) }
    it { is_expected.to validate_numericality_of(:z_coordinate) }

    it 'validates uniqueness of 3D position' do
      create(:spatial_location, x_coordinate: 1, y_coordinate: 2, z_coordinate: 3)
      duplicate = build(:spatial_location, x_coordinate: 1, y_coordinate: 2, z_coordinate: 3)
      expect(duplicate).not_to be_valid
    end

    it 'validates uniqueness of 3D position within same spatial context' do
      solar_system = create(:solar_system)
      create(:spatial_location, 
             x_coordinate: 1, 
             y_coordinate: 2, 
             z_coordinate: 3,
             spatial_context: solar_system)
      
      duplicate = build(:spatial_location,
                       x_coordinate: 1,
                       y_coordinate: 2,
                       z_coordinate: 3,
                       spatial_context: solar_system)
                       
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:x_coordinate]).to include('position must be unique within the spatial context')
    end

    it 'allows same coordinates in different spatial contexts' do
      system1 = create(:solar_system)
      system2 = create(:solar_system)
      
      create(:spatial_location,
             x_coordinate: 1,
             y_coordinate: 2,
             z_coordinate: 3,
             spatial_context: system1)
             
      location2 = build(:spatial_location,
                       x_coordinate: 1,
                       y_coordinate: 2,
                       z_coordinate: 3,
                       spatial_context: system2)
                       
      expect(location2).to be_valid
    end
  end

  describe '#update_location' do
    let(:spatial_location) { create(:spatial_location) }
    
    it 'updates coordinates' do
      new_coords = {
        x_coordinate: 100.0,
        y_coordinate: 200.0,
        z_coordinate: 300.0
      }
      
      expect(spatial_location.update_location(new_coords)).to be true
      expect(spatial_location.reload.x_coordinate).to eq(100.0)
      expect(spatial_location.reload.y_coordinate).to eq(200.0)
      expect(spatial_location.reload.z_coordinate).to eq(300.0)
    end
  end

  describe '#distance_to' do
    let(:location1) { create(:spatial_location, x_coordinate: 0, y_coordinate: 0, z_coordinate: 0) }
    let(:location2) { create(:spatial_location, x_coordinate: 3, y_coordinate: 4, z_coordinate: 0) }
    
    it 'calculates 3D distance between locations' do
      expect(location1.distance_to(location2)).to eq(5.0)
    end
  end
end
