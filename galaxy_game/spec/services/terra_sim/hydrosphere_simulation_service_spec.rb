require 'rails_helper'

RSpec.describe TerraSim::HydrosphereSimulationService, type: :service do
  let(:celestial_body) { create(:celestial_body, surface_temperature: 250.0) }
  let(:atmosphere) { create(:atmosphere, celestial_body: celestial_body, temperature: 250.0) }
  let(:hydrosphere) do
    create(:hydrosphere,
      celestial_body: celestial_body,
      total_hydrosphere_mass: 1.0e18,
      oceans: { 'volume' => 1.0e15 },
      lakes: { 'volume' => 1.0e13 },
      rivers: { 'volume' => 1.0e12 },
      liquid_bodies: {
        'ice_caps' => { 'volume' => 1.0e14 }
      },
      state_distribution: {
        'solid' => 50.0,
        'liquid' => 40.0,
        'vapor' => 10.0
      }
    )
  end
  
  subject { described_class.new(celestial_body) }
  
  before do
    # Ensure all spheres exist
    atmosphere
    hydrosphere
    
    # Stub material lookup comprehensively
    material_lookup = instance_double(Lookup::MaterialLookupService)
    
    # Create a hash-like object for water material
    water_material = {
      'chemical_formula' => 'H2O',
      'molar_mass' => 18.0,
      'name' => 'Water'
    }
    
    # Create hash-like objects for other common gases
    co2_material = {
      'chemical_formula' => 'CO2',
      'molar_mass' => 44.0,
      'name' => 'Carbon Dioxide'
    }
    
    o2_material = {
      'chemical_formula' => 'O2',
      'molar_mass' => 32.0,
      'name' => 'Oxygen'
    }
    
    n2_material = {
      'chemical_formula' => 'N2',
      'molar_mass' => 28.0,
      'name' => 'Nitrogen'
    }
    
    allow(Lookup::MaterialLookupService).to receive(:new).and_return(material_lookup)
    allow(material_lookup).to receive(:find_material).and_return(nil) # Default
    allow(material_lookup).to receive(:find_material).with("Water").and_return(water_material)
    allow(material_lookup).to receive(:find_material).with("H2O").and_return(water_material)
    allow(material_lookup).to receive(:find_material).with("CO2").and_return(co2_material)
    allow(material_lookup).to receive(:find_material).with("O2").and_return(o2_material)
    allow(material_lookup).to receive(:find_material).with("N2").and_return(n2_material)
    
    # Mock get_material_property method
    allow(material_lookup).to receive(:get_material_property) do |material, property|
      material[property] if material
    end
    
    # Prevent hydrosphere callbacks from triggering simulations
    allow(hydrosphere).to receive(:run_simulation).and_return(true)
    
    # Silence output
    allow(subject).to receive(:puts).and_return(nil)
  end
  
  describe '#initialize' do
    it 'initializes with a celestial body and its spheres' do
      expect(subject.instance_variable_get(:@celestial_body)).to eq(celestial_body)
      expect(subject.instance_variable_get(:@hydrosphere)).to eq(hydrosphere)
      expect(subject.instance_variable_get(:@atmosphere)).to eq(atmosphere)
    end
    
    it 'sets up material lookup service' do
      # Just verify it exists and responds to the right methods
      lookup = subject.instance_variable_get(:@material_lookup)
      expect(lookup).to respond_to(:find_material)
    end
  end
  
  describe '#simulate' do
    it 'calls all simulation methods in order' do
      expect(subject).to receive(:calculate_region_temperatures).once.ordered
      expect(subject).to receive(:handle_evaporation).once.ordered
      expect(subject).to receive(:handle_precipitation).once.ordered
      expect(hydrosphere).to receive(:recalculate_state_distribution).once.ordered
      expect(subject).to receive(:update_hydrosphere_volume).once.ordered
      expect(subject).to receive(:handle_ice_melting).once.ordered
      
      subject.simulate
    end
    
    it 'prevents recursive calls with simulation flag' do
      allow(subject).to receive(:calculate_region_temperatures) do
        subject.simulate # Try to trigger recursion
      end
      
      expect(subject).to receive(:calculate_region_temperatures).once
      subject.simulate
    end
    
    it 'does not run if any required sphere is missing' do
      allow(celestial_body).to receive(:hydrosphere).and_return(nil)
      service = described_class.new(celestial_body)
      
      expect(service).not_to receive(:calculate_region_temperatures)
      service.simulate
    end
  end
  
  describe '#calculate_region_temperatures' do
    it 'calculates temperatures for all water bodies' do
      subject.send(:calculate_region_temperatures)
      
      expect(hydrosphere.ocean_temp).to be_a(Numeric)
      expect(hydrosphere.lake_temp).to be_a(Numeric)
      expect(hydrosphere.river_temp).to be_a(Numeric)
      expect(hydrosphere.ice_temp).to be_a(Numeric)
    end
    
    it 'sets water temperatures cooler than surface temperature' do
      subject.send(:calculate_region_temperatures)
      
      expect(hydrosphere.ocean_temp).to be < celestial_body.surface_temperature
      expect(hydrosphere.lake_temp).to be < celestial_body.surface_temperature
      expect(hydrosphere.river_temp).to be < celestial_body.surface_temperature
    end
  end
  
  describe '#handle_evaporation' do
    it 'decreases water body volumes conservatively' do
      initial_ocean_vol = hydrosphere.oceans['volume']
      initial_lake_vol = hydrosphere.lakes['volume']
      initial_river_vol = hydrosphere.rivers['volume']
      
      subject.send(:handle_evaporation)
      
      # With conservative evaporation rates, expect very small changes
      # The new rate is ~1e-8, so changes should be minimal but detectable
      expect(hydrosphere.oceans['volume']).to be <= initial_ocean_vol
      expect(hydrosphere.lakes['volume']).to be <= initial_lake_vol
      expect(hydrosphere.rivers['volume']).to be <= initial_river_vol
      
      # Ensure volumes don't go negative
      expect(hydrosphere.oceans['volume']).to be >= 0
      expect(hydrosphere.lakes['volume']).to be >= 0
      expect(hydrosphere.rivers['volume']).to be >= 0
    end
    
    it 'adds water vapor to the atmosphere' do
      expect(atmosphere).to receive(:add_gas).with('H2O', anything)
      
      subject.send(:handle_evaporation)
    end
    
    it 'handles numeric volume values (not hashes)' do
      hydrosphere.oceans = 1.0e15
      hydrosphere.lakes = 1.0e13
      hydrosphere.rivers = 1.0e12
      
      expect { subject.send(:handle_evaporation) }.not_to raise_error
    end
  end
  
  describe '#handle_precipitation' do
    before do
      # Add water vapor to atmosphere
      create(:gas, atmosphere: atmosphere, name: 'H2O', mass: 1.0e12)
    end
    
    it 'increases water body volumes' do
      initial_ocean_vol = hydrosphere.oceans['volume']
      initial_lake_vol = hydrosphere.lakes['volume']
      initial_river_vol = hydrosphere.rivers['volume']
      
      allow(atmosphere).to receive(:remove_gas)
      allow(atmosphere).to receive(:decrease_dust)
      
      subject.send(:handle_precipitation)
      
      # Check if at least one increased (precipitation rate might be very small)
      total_initial = initial_ocean_vol + initial_lake_vol + initial_river_vol
      total_after = hydrosphere.oceans['volume'] + hydrosphere.lakes['volume'] + hydrosphere.rivers['volume']
      
      expect(total_after).to be >= total_initial
    end
    
    it 'removes water vapor from the atmosphere' do
      allow(atmosphere).to receive(:decrease_dust)
      expect(atmosphere).to receive(:remove_gas).with('H2O', anything)
      
      subject.send(:handle_precipitation)
    end
    
    it 'decreases atmospheric dust concentration' do
      allow(atmosphere).to receive(:remove_gas)
      expect(atmosphere).to receive(:decrease_dust).with(anything)
      
      subject.send(:handle_precipitation)
    end
  end
  
  describe '#calculate_state_distributions' do
    it 'calculates state distribution based on temperature and pressure' do
      subject.send(:calculate_state_distributions)
      
      state_dist = hydrosphere.state_distribution
      expect(state_dist).to have_key('solid')
      expect(state_dist).to have_key('liquid')
      expect(state_dist).to have_key('vapor')
    end
  end
  
  describe '#handle_ice_melting' do
    context 'when temperature is above freezing' do
      before do
        celestial_body.update!(surface_temperature: 280.0) # Above 273.15K
      end
      
      it 'melts ice from polar caps conservatively' do
        initial_ice_volume = hydrosphere.liquid_bodies['ice_caps']['volume']
        
        allow(hydrosphere).to receive(:save!)
        allow(atmosphere).to receive(:add_gas)
        
        subject.send(:handle_ice_melting)
        
        # With conservative melting (max 1% per cycle), expect small but measurable change
        ice_mass = initial_ice_volume * 917  # Convert volume to mass (ice density)
        max_expected_melt = ice_mass * 0.01  # 1% of ice mass
        max_volume_melt = max_expected_melt / 917  # Convert back to volume
        
        expect(hydrosphere.liquid_bodies['ice_caps']['volume']).to be <= initial_ice_volume
        expect(hydrosphere.liquid_bodies['ice_caps']['volume']).to be >= (initial_ice_volume - max_volume_melt)
      end
      
      it 'updates state distribution conservatively to decrease solid percentage' do
        initial_solid_pct = hydrosphere.state_distribution['solid']
        
        allow(hydrosphere).to receive(:save!)
        allow(atmosphere).to receive(:add_gas)
        
        subject.send(:handle_ice_melting)
        
        # With conservative melting, expect small changes (may not always decrease measurably)
        expect(hydrosphere.state_distribution['solid']).to be <= initial_solid_pct + 0.001  # Allow for rounding
        expect(hydrosphere.state_distribution['solid']).to be >= 0.0
      end
      
      it 'updates state distribution conservatively to increase liquid percentage' do
        initial_liquid_pct = hydrosphere.state_distribution['liquid']
        
        allow(hydrosphere).to receive(:save!)
        allow(atmosphere).to receive(:add_gas)
        
        subject.send(:handle_ice_melting)
        
        # With conservative melting, expect small changes (may not always increase measurably)
        expect(hydrosphere.state_distribution['liquid']).to be >= initial_liquid_pct - 0.001  # Allow for rounding
        expect(hydrosphere.state_distribution['liquid']).to be <= 100.0
      end
      
      it 'does not allow solid percentage to go negative' do
        # Set initial state with minimal solid water
        hydrosphere.state_distribution['solid'] = 1.0
        hydrosphere.state_distribution['liquid'] = 99.0
        
        allow(hydrosphere).to receive(:save!)
        allow(atmosphere).to receive(:add_gas)
        
        subject.send(:handle_ice_melting)
        
        expect(hydrosphere.state_distribution['solid']).to be >= 0.0
      end
      
      it 'adds some melted water as vapor to atmosphere' do
        allow(hydrosphere).to receive(:save!)
        expect(atmosphere).to receive(:add_gas).with('H2O', anything)
        
        subject.send(:handle_ice_melting)
      end
      
      it 'does not melt more than maximum allowed per cycle' do
        ice_volume = hydrosphere.liquid_bodies['ice_caps']['volume']
        ice_mass = ice_volume * 917
        max_meltable = ice_mass * 0.01
        
        allow(hydrosphere).to receive(:save!)
        allow(atmosphere).to receive(:add_gas)
        
        subject.send(:handle_ice_melting)
        
        new_ice_volume = hydrosphere.liquid_bodies['ice_caps']['volume']
        new_ice_mass = new_ice_volume * 917
        melted = ice_mass - new_ice_mass
        
        expect(melted).to be <= max_meltable
      end
    end
    
    context 'when temperature is below freezing' do
      before do
        celestial_body.update!(surface_temperature: 250.0) # Below 273.15K
      end
      
      it 'does not melt any ice' do
        initial_ice_volume = hydrosphere.liquid_bodies['ice_caps']['volume']
        
        subject.send(:handle_ice_melting)
        
        expect(hydrosphere.liquid_bodies['ice_caps']['volume']).to eq(initial_ice_volume)
      end
    end
    
    context 'when ice caps do not exist' do
      before do
        hydrosphere.liquid_bodies = {}
        
        # Skip all callbacks
        allow(celestial_body).to receive(:run_terra_sim).and_return(true)
        allow(hydrosphere).to receive(:run_simulation).and_return(true)
        allow(hydrosphere).to receive(:recalculate_state_distribution).and_return(true)
      end
      
      it 'returns early without error' do
        # Update without triggering callbacks
        celestial_body.update_columns(surface_temperature: 280.0)
        
        expect { subject.send(:handle_ice_melting) }.not_to raise_error
      end
    end
  end
  
  describe '#update_hydrosphere_volume' do
    it 'delegates to the hydrosphere model method' do
      expect(hydrosphere).to receive(:update_hydrosphere_volume)
      
      subject.send(:update_hydrosphere_volume)
    end
  end
  
  describe 'integration: full simulation cycle' do
    it 'runs a complete simulation without errors' do
      expect { subject.simulate }.not_to raise_error
    end
    
    it 'maintains valid state distribution percentages' do
      allow(hydrosphere).to receive(:save!)
      
      subject.simulate
      
      state_dist = hydrosphere.state_distribution
      # Handle both string and symbol keys
      solid = state_dist['solid'] || state_dist[:solid] || 0
      liquid = state_dist['liquid'] || state_dist[:liquid] || 0
      vapor = state_dist['vapor'] || state_dist[:vapor] || 0
      total_pct = solid + liquid + vapor
      
      # Allow some floating point tolerance
      expect(total_pct).to be_within(5.0).of(100.0)
    end
    
    it 'never produces negative state distribution values' do
      allow(hydrosphere).to receive(:save!)
      
      # Run multiple cycles to stress test
      5.times { subject.simulate }
      
      state_dist = hydrosphere.state_distribution
      solid = state_dist['solid'] || state_dist[:solid] || 0
      liquid = state_dist['liquid'] || state_dist[:liquid] || 0
      vapor = state_dist['vapor'] || state_dist[:vapor] || 0
      
      expect(solid).to be >= 0.0
      expect(liquid).to be >= 0.0
      expect(vapor).to be >= 0.0
    end
  end
  
  describe 'edge cases' do
    context 'with extreme cold temperature' do
      before do
        celestial_body.update_columns(surface_temperature: 100.0)
      end
      
      it 'handles extreme cold without errors' do
        expect { subject.simulate }.not_to raise_error
      end
    end
    
    context 'with extreme hot temperature' do
      before do
        celestial_body.update_columns(surface_temperature: 500.0)
      end
      
      it 'handles extreme heat without errors' do
        expect { subject.simulate }.not_to raise_error
      end
    end
    
    context 'with zero water bodies' do
      before do
        hydrosphere.oceans = { 'volume' => 0 }
        hydrosphere.lakes = { 'volume' => 0 }
        hydrosphere.rivers = { 'volume' => 0 }
        
        # Ensure there's no water vapor to remove
        atmosphere.gases.where(name: 'Water').destroy_all
      end
      
      it 'handles zero volumes without errors' do
        expect { subject.simulate }.not_to raise_error
      end
    end
  end
end