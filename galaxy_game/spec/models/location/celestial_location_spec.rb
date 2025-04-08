# spec/models/location/celestial_location_spec.rb
require 'rails_helper'

RSpec.describe Location::CelestialLocation, type: :model do
  let(:celestial_body) { create(:celestial_body) }

  describe 'associations' do
    it { is_expected.to belong_to(:celestial_body) }
    it { is_expected.to belong_to(:locationable).optional }
  end

  describe 'validations' do
    subject { build(:celestial_location, celestial_body: celestial_body) } # Ensure celestial_body is associated

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:celestial_body) }

    context 'coordinate format' do
      it 'accepts valid coordinates' do
        location = build(:celestial_location, celestial_body: celestial_body, coordinates: '45.50°N 120.50°W')
        expect(location).to be_valid
      end

      it 'rejects invalid coordinates' do
        location = build(:celestial_location, celestial_body: celestial_body, coordinates: 'invalid')
        expect(location).not_to be_valid
        expect(location.errors[:coordinates]).to include("must be in format '00.00°N/S 00.00°E/W'")
      end
    end

    context 'uniqueness validation' do
      let!(:existing_body) { create(:celestial_body) }
      let!(:another_body) { create(:celestial_body) }
      let!(:existing_location) { create(:celestial_location, celestial_body: existing_body, coordinates: '77.65°N 64.40°W') }
    
      it 'validates that coordinates are case-insensitively unique within the same celestial body' do
        new_location = build(:celestial_location, celestial_body: existing_body, coordinates: '77.65°n 64.40°w')
        expect(new_location.valid?).to be false
        expect(new_location.errors[:coordinates]).to include('has already been taken')
      end
    
      it 'validates that coordinates are unique with the same case within the same celestial body' do
        new_location = build(:celestial_location, celestial_body: existing_body, coordinates: '77.65°N 64.40°W')
        expect(new_location.valid?).to be false
        expect(new_location.errors[:coordinates]).to include('has already been taken')
      end
    
      it 'allows the same coordinates on a different celestial body' do
        new_location = build(:celestial_location, celestial_body: another_body, coordinates: '77.65°N 64.40°W')
        expect(new_location).to be_valid
      end
    
      it 'allows different coordinates on the same celestial body' do
        new_location = build(:celestial_location, celestial_body: existing_body, coordinates: '79.00°N 110.00°W')
        expect(new_location).to be_valid
      end
    end

    it 'is invalid without coordinates' do
      subject.coordinates = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:coordinates]).to include("can't be blank")
    end

    it 'is invalid with blank coordinates' do
      subject.coordinates = ""
      expect(subject).not_to be_valid
      expect(subject.errors[:coordinates]).to include("can't be blank")
    end
  end
end