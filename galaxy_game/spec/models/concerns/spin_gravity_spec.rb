require 'rails_helper'

# We use a dummy class to test the concern in isolation 
# without needing a full database record.
class SpinGravityTestModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include SpinGravity
  
  attribute :diameter_m, :float
  attribute :rotation_rpm, :float
  
  # Mocking the location relationship
  attr_accessor :location
  
  def save!; true; end # Stub for testing
end

RSpec.describe SpinGravity do
  let(:test_model) { SpinGravityTestModel.new(diameter_m: 100.0) }
  let(:microgravity_location) { instance_double('Location::CelestialLocation', gravity_g: 0.005) }
  let(:planetary_location) { instance_double('Location::CelestialLocation', gravity_g: 1.0) }

  describe '#needs_spin_gravity?' do
    it 'returns true when the location is in microgravity' do
      test_model.location = microgravity_location
      expect(test_model.needs_spin_gravity?).to be true
    end

    it 'returns false when on a planetary surface' do
      test_model.location = planetary_location
      expect(test_model.needs_spin_gravity?).to be false
    end
  end

  describe '#artificial_gravity_g' do
    before { test_model.location = microgravity_location }

    it 'calculates ~1.0g for a 100m diameter station at ~4.23 RPM' do
      test_model.rotation_rpm = 4.23
      # Math: (4.23 * PI/30)^2 * 50 / 9.81 ≈ 1.0
      expect(test_model.artificial_gravity_g).to be_within(0.05).of(1.0)
    end

    it 'returns 0 if rotation is 0' do
      test_model.rotation_rpm = 0
      expect(test_model.artificial_gravity_g).to eq(0)
    end

    it 'returns 0 if diameter is 0 or missing' do
      test_model.diameter_m = 0
      test_model.rotation_rpm = 5.0
      expect(test_model.artificial_gravity_g).to eq(0)
    end
  end

  describe '#spin_for_gravity' do
    before { test_model.location = microgravity_location }

    it 'sets the correct RPM to achieve target G' do
      test_model.spin_for_gravity(target_g: 0.95)
      # For 100m diameter, 0.95g should be roughly 4.12 RPM
      expect(test_model.rotation_rpm).to be_within(0.1).of(4.12)
    end

    it 'does nothing if the location does not need spin' do
      test_model.location = planetary_location
      test_model.rotation_rpm = 0
      test_model.spin_for_gravity(target_g: 0.95)
      expect(test_model.rotation_rpm).to eq(0)
    end
  end
end