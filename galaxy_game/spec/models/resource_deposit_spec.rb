require 'rails_helper'

describe ResourceDeposit, type: :model do
  let(:deposit_spawner) { double('DepositSpawner') }
  let(:feature) { create(:adapted_feature) }
  let(:depositable) { feature.celestial_body }

  context 'when spawned by survey event' do
    subject(:deposit) do
      # Simulate DepositSpawner creating the deposit
      ResourceDeposit.new(
        depositable: depositable,
        feature: feature,
        material_name: 'water_ice',
        initial_mass_kg: 1000.0,
        current_mass_kg: 1000.0,
        extraction_difficulty: 1.0,
        depletion_curve: 'linear',
        status: :undiscovered
      )
    end

    it 'is valid with all required fields and one location' do
      expect(deposit).to be_valid
    end

    it 'defaults to status undiscovered' do
      expect(deposit.status).to eq('undiscovered')
    end

    it 'is invalid if more than one location is set' do
      deposit.celestial_location_id = create(:celestial_location).id
      expect(deposit).not_to be_valid
      expect(deposit.errors[:base]).to include('Exactly one location (feature, celestial_location, or spatial_location) must be set')
    end

    it 'is invalid if no location is set' do
      deposit.feature = nil
      expect(deposit).not_to be_valid
      expect(deposit.errors[:base]).to include('Exactly one location (feature, celestial_location, or spatial_location) must be set')
    end

    it 'is invalid if current_mass_kg > initial_mass_kg' do
      deposit.current_mass_kg = 2000.0
      expect(deposit).not_to be_valid
      expect(deposit.errors[:current_mass_kg]).to include('cannot exceed initial_mass_kg')
    end
  end

  context 'factory' do
    it 'raises if used directly' do
      expect {
        create(:resource_deposit)
      }.to raise_error(/must be created via DepositSpawner/)
    end
  end
end
