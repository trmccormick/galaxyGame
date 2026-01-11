require 'rails_helper'

RSpec.describe Pressurization::BasePressurizationService do
  let(:volume) { 100.0 } # 100 cubic meters
  let(:available_gases) do
    {
      oxygen: 50.0,    # 50 kg of oxygen
      nitrogen: 150.0,  # 150 kg of nitrogen
      argon: 5.0        # 5 kg of argon
    }
  end
  
  let(:service) { described_class.new(volume, available_gases) }
  
  describe '#initialize' do
    it 'sets up the service with default values' do
      expect(service.instance_variable_get(:@volume)).to eq(volume)
      expect(service.instance_variable_get(:@available_gases)).to eq(available_gases)
      expect(service.instance_variable_get(:@current_pressure)).to eq(0)
    end
    
    it 'allows custom options' do
      custom_service = described_class.new(
        volume, 
        available_gases, 
        target_pressure: 80_000,
        temperature: 273.15,
        current_pressure: 10_000
      )
      
      expect(custom_service.instance_variable_get(:@target_pressure)).to eq(80_000)
      expect(custom_service.instance_variable_get(:@temperature)).to eq(273.15)
      expect(custom_service.instance_variable_get(:@current_pressure)).to eq(10_000)
    end
  end
  
  describe '#calculate_total_moles' do
    it 'calculates moles based on ideal gas law' do
      # PV = nRT => n = PV/RT
      expected_moles = (101_325 * 100) / (8.31446 * 288.15)
      expect(service.calculate_total_moles).to be_within(0.1).of(expected_moles)
    end
  end
  
  describe '#calculate_needed_gases' do
    it 'calculates the mass of each gas needed' do
      result = service.calculate_needed_gases
      
      # Check that keys exist
      expect(result).to have_key('oxygen')
      expect(result).to have_key('nitrogen')
      expect(result).to have_key('argon')
      
      # Check that values are positive
      expect(result['oxygen']).to be > 0
      expect(result['nitrogen']).to be > 0
      expect(result['argon']).to be > 0
      
      # Check that the mass ratio matches the mix (weighted by molar mass)
      total = result.values.sum
      expect(result['oxygen'] / total).to be_within(0.01).of(0.232)
      expect(result['nitrogen'] / total).to be_within(0.01).of(0.754)
      expect(result['argon'] / total).to be_within(0.01).of(0.014)
    end
  end
  
  describe '#calculate_achievable_pressure' do
    context 'with sufficient gases' do
      it 'returns the target pressure' do
        # Give plenty of gas
        service.instance_variable_set(:@available_gases, {
          oxygen: 500.0,
          nitrogen: 1500.0,
          argon: 50.0
        })
        
        expect(service.calculate_achievable_pressure).to eq(101_325)
      end
    end
    
    context 'with insufficient gases' do
      it 'returns a reduced pressure based on the limiting gas' do
        # Make oxygen the limiting factor (20% of needed)
        needed = service.calculate_needed_gases
        service.instance_variable_set(:@available_gases, {
          oxygen: needed['oxygen'] * 0.2,
          nitrogen: needed['nitrogen'] * 0.8,
          argon: needed['argon'] * 0.5
        })
        
        expect(service.calculate_achievable_pressure).to be_within(100).of(101_325 * 0.2)
      end
    end
  end
  
  describe '#pressurize' do
    it 'returns a success result with full pressure when gases are sufficient' do
      # Give plenty of gas
      service.instance_variable_set(:@available_gases, {
        oxygen: 500.0,
        nitrogen: 1500.0,
        argon: 50.0
      })
      
      result = service.pressurize
      
      expect(result[:success]).to be true
      expect(result[:achieved_pressure]).to eq(101_325)
      expect(result[:used_gases]).to have_key('oxygen')
      expect(result[:used_gases]).to have_key('nitrogen')
      expect(result[:used_gases]).to have_key('argon')
    end
    
    it 'deducts the used gases from available gases' do
      # Clone the original gases
      original_gases = available_gases.dup
      
      service.pressurize
      
      # Check that gases were used
      expect(service.instance_variable_get(:@available_gases)[:oxygen]).to be < original_gases[:oxygen]
      expect(service.instance_variable_get(:@available_gases)[:nitrogen]).to be < original_gases[:nitrogen]
      expect(service.instance_variable_get(:@available_gases)[:argon]).to be < original_gases[:argon]
    end
    
    it 'returns partial success with reduced pressure when gases are insufficient' do
      # Make oxygen the limiting factor (20% of needed)
      needed = service.calculate_needed_gases
      service.instance_variable_set(:@available_gases, {
        oxygen: needed['oxygen'] * 0.2,
        nitrogen: needed['nitrogen'] * 0.8,
        argon: needed['argon'] * 0.5
      })
      
      result = service.pressurize
      
      expect(result[:success]).to be false
      expect(result[:achieved_pressure]).to be_within(100).of(101_325 * 0.2)
    end
  end
end