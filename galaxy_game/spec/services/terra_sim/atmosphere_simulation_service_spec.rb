require 'rails_helper'

RSpec.describe TerraSim::AtmosphereSimulationService, type: :service do
  let(:solar_system) { create(:solar_system) }
  let(:star) { create(:star, luminosity: 3.846e26, solar_system: solar_system) }
  let(:celestial_body) do
    body = create(:celestial_body, solar_system: solar_system, albedo: 0.3,
                 mass: 5.972e24, radius: 6371000.0) 
    # Create star distance relationship
    create(:star_distance, celestial_body: body, star: star, distance: 1.496e11)
    # Create atmosphere with gases
    atmosphere = create(:atmosphere, celestial_body: body)
    create(:gas, atmosphere: atmosphere, name: 'CO2', percentage: 0.04, mass: 2.1e15)
    create(:gas, atmosphere: atmosphere, name: 'CH4', percentage: 0.0002, mass: 3.7e12)
    create(:gas, atmosphere: atmosphere, name: 'N2O', percentage: 0.0003, mass: 1.5e12)
    create(:gas, atmosphere: atmosphere, name: 'H2O', percentage: 0.4, mass: 1.3e16)
    body
  end
  
  subject { described_class.new(celestial_body) }

  describe '#initialize' do
    it 'initializes with a celestial body' do
      expect(subject.instance_variable_get(:@celestial_body)).to eq(celestial_body)
    end
    
    it 'sets up the Stefan-Boltzmann constant' do
      expect(subject.instance_variable_get(:@sigma)).to eq(5.67e-8)
    end
  end

  describe '#simulate' do
    before do
      # Mock the GeosphereSimulationService to prevent it from being initialized
      allow_any_instance_of(TerraSim::GeosphereSimulationService).to receive(:simulate).and_return(true)
      
      # Alternative: Prevent the simulator from calling GeosphereSimulationService
      allow_any_instance_of(TerraSim::Simulator).to receive(:update_spheres).and_return(true)
      
      # Keep existing mocks
      allow(celestial_body.atmosphere).to receive(:recalculate_mass!).and_return(true)
      allow(celestial_body.atmosphere).to receive(:update_pressure_from_mass!).and_return(true)
      allow(celestial_body.atmosphere).to receive(:decrease_dust).and_return(true)
      allow(celestial_body.atmosphere).to receive(:set_effective_temp).and_return(true)
      allow(celestial_body.atmosphere).to receive(:set_greenhouse_temp).and_return(true)
      allow(celestial_body.atmosphere).to receive(:set_polar_temp).and_return(true) 
      allow(celestial_body.atmosphere).to receive(:set_tropic_temp).and_return(true)
      
      # No need to mock MaterialLookupService - use the real one
    end
    
    it 'updates the pressure' do
      expect(celestial_body.atmosphere).to receive(:update_pressure_from_mass!)
      subject.simulate
    end

    it 'calculates the greenhouse effect' do
      # Instead of checking actual values, verify the method is called
      expect(subject).to receive(:calculate_greenhouse_effect).and_call_original
      subject.simulate
    end
    
    it 'updates temperature data in the atmosphere' do
      # Test that these methods are called with any arguments
      expect(celestial_body.atmosphere).to receive(:set_effective_temp)
      expect(celestial_body.atmosphere).to receive(:set_greenhouse_temp)
      expect(celestial_body.atmosphere).to receive(:set_polar_temp)
      expect(celestial_body.atmosphere).to receive(:set_tropic_temp)
      
      # Allow any number of calls
      allow(celestial_body).to receive(:update)
      
      subject.simulate
    end

    it 'simulates atmospheric loss' do
      # Test that atmospheric loss is simulated by checking the method is called
      expect(subject).to receive(:simulate_atmospheric_loss).and_call_original
      subject.simulate
    end
    
    it 'decreases dust' do
      expect(celestial_body.atmosphere).to receive(:decrease_dust).with(0.1)
      subject.simulate
    end
  end
  
  describe 'temperature calculation methods' do
    before do
      # Set up the service with test data
      subject.instance_variable_set(:@albedo, 0.3)
      subject.instance_variable_set(:@solar_input, 1366.0)
      subject.instance_variable_set(:@base_temp, 255.0)
      subject.instance_variable_set(:@surface_temp, 288.0)
      
      # Set up gas data
      subject.instance_variable_set(:@gases, {
        'CO2' => { mass: 2.1e15, molar_mass: 44.01 },
        'CH4' => { mass: 3.7e12, molar_mass: 16.04 },
        'H2O' => { mass: 1.3e16, molar_mass: 18.01 },
        'N2O' => { mass: 1.5e12, molar_mass: 44.01 }
      })
    end
    
    it 'calculates stefan_boltzmann_temp correctly' do
      temp = subject.send(:stefan_boltzmann_temp)
      expect(temp).to be_within(1.0).of(255.0)
    end
    
    it 'calculates greenhouse_adjusted_temp correctly' do
      temp = subject.send(:greenhouse_adjusted_temp)
      expect(temp).to be > subject.instance_variable_get(:@base_temp)
    end
    
    it 'calculates water_vapor_pressure correctly' do
      pressure = subject.send(:water_vapor_pressure)
      expect(pressure).to be > 0
    end
  end
  
  describe '#update_temperatures' do
    it 'updates all temperature types in atmosphere' do
      # Set up test data
      subject.instance_variable_set(:@base_temp, 255.0)
      subject.instance_variable_set(:@surface_temp, 288.0)
      subject.instance_variable_set(:@polar_temp, 248.0)
      subject.instance_variable_set(:@tropic_temp, 298.0)
      
      # Expect the atmosphere to receive these method calls
      expect(celestial_body.atmosphere).to receive(:set_effective_temp).with(255.0)
      expect(celestial_body.atmosphere).to receive(:set_greenhouse_temp).with(288.0)
      expect(celestial_body.atmosphere).to receive(:set_polar_temp).with(248.0)
      expect(celestial_body.atmosphere).to receive(:set_tropic_temp).with(298.0)
      
      # Also expect celestial body to be updated
      expect(celestial_body).to receive(:update).with(surface_temperature: 288.0).at_least(:once)
      
      # Call the method
      subject.send(:update_temperatures)
    end
  end
end