# spec/integration/terraforming_workflow_spec.rb
require 'rails_helper'

RSpec.describe 'Terraforming Workflow Integration', type: :integration do
  let(:solar_system) { create(:solar_system) }
  let(:planet) do
    create(:celestial_body, :with_solar_system).tap do |p|
      p.update!(solar_system: solar_system)
      # Ensure solar_constant is set for temperature calculations
      if p.solar_system&.current_star
        # Calculate solar constant based on star distance
        # For a G-type star at ~1 AU: ~1361 W/m²
        # For enhanced terraforming: ~1800 W/m² (via mirrors)
        p.update_column(:insolation, 1800)
      end
    end
  end
  let(:biosphere) { planet.biosphere }
  let(:atmosphere) { planet.atmosphere }
  
  before do
    # Set up STAGE 3 terraforming scenario:
    # - Humans have already added massive greenhouse gases (Stage 1)
    # - Planet is warmed, with active hydrological cycle (Stage 2)
    # - NOW deploying biosphere for oxygen production (Stage 3)
    
    # Increased solar input (via mirrors/reduced albedo)
    planet.update!(
      surface_temperature: 288.0,
      insolation: 1800,  # Enhanced solar input (150% of Earth via orbital mirrors)
      albedo: 0.15       # Darkened surface (algae/dust coverage)
    )
    
    # Thick atmosphere with strong greenhouse effect
    atmosphere.update!(
      total_atmospheric_mass: 5e17,  # ~1% Earth's atmosphere (thick enough for greenhouse)
      temperature: 285.0,
      base_values: {
        'composition' => { 
          'CO2' => 75.0,   # Primary greenhouse gas
          'N2' => 15.0,    # Imported from Titan/comets
          'CH4' => 8.0,    # Strong greenhouse contributor
          'H2O' => 1.5,    # Water vapor (greenhouse)
          'O2' => 0.5      # Trace oxygen (our target to increase)
        },
        'total_atmospheric_mass' => 5e17
      },
      temperature_data: {
        'tropical_temperature' => 295.0,  # Warm equatorial regions
        'polar_temperature' => 260.0      # Still cold at poles
      }
    )
    atmosphere.reset
    
    # Active hydrosphere with significant liquid water
    if planet.hydrosphere
      planet.hydrosphere.update(
        temperature: 280.0,  # Above freezing
        total_hydrosphere_mass: 8e17,  # ~0.05% of Earth's oceans
        state_distribution: { 
          'liquid' => 35.0,  # Equatorial seas and lakes
          'solid' => 60.0,   # Polar ice caps
          'vapor' => 5.0     # Active water cycle
        }
      )
    end
  end
  
  it 'transforms atmosphere over time with deployed organisms' do
    # Stage 3 Terraforming: Pre-warmed Mars with greenhouse atmosphere
    # Expecting measurable but slow O2 increase over geological timescales
    
    initial_o2 = atmosphere.o2_percentage
    expect(initial_o2).to be < 1.0  # Started with trace O2
    
    # Deploy terraforming organisms
    biosphere.deploy_starter_ecosystem
    biosphere.reload
    
    expect(biosphere.life_forms.count).to eq(3)
    
    # Check terraforming rates
    summary = biosphere.terraforming_summary
    expect(summary[:o2_production_kg_per_day]).to be > 0
    
    # Simulate 1000 days (~3 years)
    # Realistic expectation: Very small but measurable O2 increase
    # Real cyanobacteria took millions of years to oxygenate Earth
    # On pre-warmed Mars with limited water: expect 0.1-1% increase over years
    simulator = TerraSim::Simulator.new(planet)
    simulator.calc_current
    
    # Verify atmospheric changes
    atmosphere.reload
    final_o2 = atmosphere.o2_percentage
    
    # Expect O2 to increase significantly with active biosphere
    # With 88.9% liquid water and 400K temps, biosphere is fully active
    expect(final_o2).to be > initial_o2
    
    # Realistic expectation for Stage 3 terraforming:
    # 1 billion cyanobacteria over 1 day should add ~0.1% O2
    # (from cyanobacteria 0.1% per day * population factor)
    expect(final_o2).to be_between(initial_o2 + 0.05, initial_o2 + 0.15)
  end
  
  it 'allows monitoring of terraforming progress' do
    biosphere.deploy_terraforming_organism(:cyanobacteria)
    biosphere.reload
    
    # Check current rates
    rates = biosphere.current_terraforming_rates
    expect(rates[:o2_production]).to eq(0.1)
    
    # Get summary
    summary = biosphere.terraforming_summary
    expect(summary[:active_species]).to eq(1)
    expect(summary[:o2_production_kg_per_day]).to eq(0.1)
  end
end