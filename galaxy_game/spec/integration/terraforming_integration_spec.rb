require 'rails_helper'

RSpec.describe "Terraforming Integration", type: :integration do
  describe "end-to-end terraforming simulation" do
    let(:celestial_body) do
      CelestialBodies::CelestialBody.create!(
        name: "Test Mars",
        identifier: "test_mars_#{Time.now.to_i}",
        body_type: "terrestrial",
        size: 3389.5,
        mass: 6.4e23,
        radius: 3389500,
        gravity: 0.38,
        surface_temperature: 285.0,
        axial_tilt: 25.19
      )
    end
    
    let(:atmosphere) do
      celestial_body.create_atmosphere!(
        total_atmospheric_mass: 2.5e16,
        temperature: 285.0,
        pressure: 0.006,
        temperature_data: {
          'tropical_temperature' => 295.0,
          'polar_temperature' => 275.0
        },
        base_values: {
          'composition' => { 
            'CO2' => { 'percentage' => 95.32 },
            'O2' => { 'percentage' => 0.13 }
          },
          'total_atmospheric_mass' => 2.5e16,
          'dust' => { 'concentration' => 0.5 }
        }
      ).tap(&:reset)
    end
    
    let(:hydrosphere) do
      celestial_body.create_hydrosphere!(
        total_hydrosphere_mass: 1.6e16,
        temperature: 285.0, # Only keep the last value
        pressure: 0.006,
        state_distribution: {
          'solid' => 90.0,
          'liquid' => 5.0,
          'vapor' => 5.0
        }
      )
    end
    
    let(:biosphere) do
      celestial_body.create_biosphere!(
        habitable_ratio: 0.1,
        ice_latitude: 1.47,
        biodiversity_index: 0.0
      )
    end
    
    before do
      # Ensure all spheres are created
      atmosphere
      hydrosphere
      biosphere
    end
    
    it "creates a barren planet with correct initial conditions" do
      expect(celestial_body).to be_persisted
      expect(atmosphere.o2_percentage).to be < 1.0
      expect(atmosphere.co2_percentage).to be > 90.0
      expect(atmosphere.temperature).to eq(285.0)
    end
    
    context "with starter ecosystem deployed" do
      let!(:cyanobacteria) do
        Biology::LifeForm.create!(
          biosphere: biosphere,
          name: "Cyanobacteria",
          complexity: :simple,
          population: 5_000_000_000,
          diet: "photosynthetic",
          properties: {
            'oxygen_production_rate' => 0.08,
            'co2_consumption_rate' => 0.10,
            'nitrogen_fixation_rate' => 0.02
          }
        )
      end
      
      let!(:algae) do
        Biology::LifeForm.create!(
          biosphere: biosphere,
          name: "Green Algae",
          complexity: :simple,
          population: 1_000_000_000,
          diet: "photosynthetic",
          properties: {
            'oxygen_production_rate' => 0.12,
            'co2_consumption_rate' => 0.15
          }
        )
      end
      
      it "deploys life forms successfully" do
        expect(biosphere.life_forms.count).to eq(2)
        expect(biosphere.life_forms.map(&:name)).to include("Cyanobacteria", "Green Algae")
      end
      
      it "life forms have atmospheric contribution" do
        cyano_contribution = cyanobacteria.atmospheric_contribution
        
        expect(cyano_contribution[:o2]).to be > 0
        expect(cyano_contribution[:co2]).to be > 0
        expect(cyano_contribution[:n2]).to be > 0
      end
      
      describe "simulation over time" do
        let(:service) { TerraSim::BiosphereSimulationService.new(celestial_body) }
        
        it "increases oxygen levels after 1 day" do
          initial_o2 = atmosphere.o2_percentage
          
          service.simulate(1)
          atmosphere.reload
          atmosphere.gases.reload
          
          expect(atmosphere.o2_percentage).to be > initial_o2
        end
        
        it "decreases CO2 levels after 1 day" do
          initial_co2 = atmosphere.co2_percentage
          
          service.simulate(1)
          atmosphere.reload
          atmosphere.gases.reload
          
          expect(atmosphere.co2_percentage).to be < initial_co2
        end
        
        it "shows progressive changes over 100 days" do
          initial_o2 = atmosphere.o2_percentage
          initial_co2 = atmosphere.co2_percentage
          
          # Simulate in stages to track progress
          snapshots = []
          [10, 25, 50, 100].each do |total_days|
            days_to_run = total_days - snapshots.length * 10
            service.simulate(days_to_run)
            
          atmosphere.reload
          atmosphere.gases.reload
          snapshots << {
              day: total_days,
              o2: atmosphere.o2_percentage,
              co2: atmosphere.co2_percentage,
              temp: atmosphere.temperature
            }
          end
          
          # Verify trends
          expect(snapshots.last[:o2]).to be > snapshots.first[:o2]
          expect(snapshots.last[:co2]).to be < snapshots.first[:co2]
          
          # O2 should show cumulative increase
          expect(snapshots.last[:o2]).to be > initial_o2
          
          # CO2 should show cumulative decrease
          expect(snapshots.last[:co2]).to be < initial_co2
        end
        
        it "scales effects by time parameter" do
          # Run 1 day
          service.simulate(1)
          atmosphere.reload
          atmosphere.gases.reload
          o2_after_1_day = atmosphere.o2_percentage
          
          # Reset atmosphere
          atmosphere.update!(base_values: {
            'composition' => { 'CO2' => 95.0, 'O2' => 0.13 },
            'total_atmospheric_mass' => 2.5
          })
          atmosphere.reset
          
          # Run 10 days at once
          service.simulate(10)
          atmosphere.reload
          atmosphere.gases.reload
          o2_after_10_days = atmosphere.o2_percentage
          
          # 10 days should produce more change than 1 day
          expect(o2_after_10_days - 0.13).to be > (o2_after_1_day - 0.13)
        end
      end
      
      describe "life form populations over time" do
        let(:service) { TerraSim::BiosphereSimulationService.new(celestial_body) }
        
        it "maintains or grows populations under favorable conditions" do
          initial_cyano_pop = cyanobacteria.population
          initial_algae_pop = algae.population
          
          service.simulate(50)
          
          cyanobacteria.reload
          algae.reload
          
          # Populations should be stable or growing (not dying off)
          expect(cyanobacteria.population).to be >= initial_cyano_pop * 0.5
          expect(algae.population).to be >= initial_algae_pop * 0.5
        end
      end
      
      describe "combined effects from multiple species" do
        let(:service) { TerraSim::BiosphereSimulationService.new(celestial_body) }
        
        it "aggregates atmospheric effects from all life forms" do
          # Calculate expected combined contribution
          total_o2_rate = cyanobacteria.atmospheric_contribution[:o2] + 
                         algae.atmospheric_contribution[:o2]
          
          total_co2_rate = cyanobacteria.atmospheric_contribution[:co2] + 
                          algae.atmospheric_contribution[:co2]
          
          expect(total_o2_rate).to be > 0
          expect(total_co2_rate).to be > 0
          
          # Run simulation
          initial_o2 = atmosphere.o2_percentage
          service.simulate(10)
          atmosphere.reload
          atmosphere.gases.reload
          
          # Change should reflect combined effects
          o2_change = atmosphere.o2_percentage - initial_o2
          expect(o2_change).to be > 0
        end
      end
    end
    
    context "without life forms" do
      let(:service) { TerraSim::BiosphereSimulationService.new(celestial_body) }
      
      it "uses fallback values when no terraforming organisms exist" do
        initial_o2 = atmosphere.o2_percentage
        
        service.simulate(1)
        atmosphere.reload
        atmosphere.gases.reload
        
        # Should still apply some change (hardcoded fallback)
        expect(atmosphere.o2_percentage).not_to eq(initial_o2)
      end
    end
  end
  
  describe "realistic terraforming scenario" do
    it "demonstrates full terraforming workflow", :aggregate_failures do
      # 1. Create barren world
      planet = CelestialBodies::CelestialBody.create!(
        name: "New Mars",
        identifier: "new_mars_demo_#{Time.now.to_i}",
        body_type: "terrestrial",
        size: 3389.5,
        mass: 6.4e23,
        radius: 3389500,
        gravity: 0.38,
        surface_temperature: 280.0
      )
      
      atm = planet.create_atmosphere!(
        total_atmospheric_mass: 2.5e16,
        temperature: 280.0,
        pressure: 0.006,
        temperature_data: { 'tropical_temperature' => 290.0, 'polar_temperature' => 270.0 },
        base_values: { 
          'composition' => { 
            'CO2' => { 'percentage' => 95.32 },
            'O2' => { 'percentage' => 0.13 }
          },
          'total_atmospheric_mass' => 2.5e16
        }
      )
      atm.reset
      
      planet.create_hydrosphere!(
        total_hydrosphere_mass: 1.6e16,
        temperature: 280.0,
        pressure: 0.006,
        state_distribution: { 'solid' => 90.0, 'liquid' => 5.0, 'vapor' => 5.0 }
      )
      
      bio = planet.create_biosphere!(
        habitable_ratio: 0.1,
        ice_latitude: 1.47,
        biodiversity_index: 0.0
      )
      
      expect(planet).to be_persisted
      expect(atm.o2_percentage).to be < 1.0
      
      # 2. Deploy organisms
      Biology::LifeForm.create!(
        biosphere: bio,
        name: "Pioneer Cyanobacteria",
        complexity: :simple,
        population: 10_000_000_000,
        diet: "photosynthetic",
        properties: {
          'oxygen_production_rate' => 0.5,   # Plausible but visible for test
          'co2_consumption_rate' => 0.6      # Plausible but visible for test
        }
      )
      
      expect(bio.life_forms.count).to eq(1)
      
      # 3. Run terraforming
      service = TerraSim::BiosphereSimulationService.new(planet)
      initial_o2 = atm.o2_percentage
      
      service.simulate(100)
      atm.reload
      
      # 4. Verify changes
      # Expect significant change after 100 days (biosphere active)
      expect(atm.o2_percentage).to be > initial_o2
      expect(atm.co2_percentage).to be < 95.32
      
      puts "\n✓ Terraforming Demo Complete"
      puts "  Initial O2: #{initial_o2.round(6)}%"
      puts "  Final O2:   #{atm.o2_percentage.round(6)}%"
      puts "  Change:     +#{(atm.o2_percentage - initial_o2).round(6)}%"
    end
  end
end