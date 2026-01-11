require 'rails_helper'

RSpec.describe StarSim::SystemGeneratorService, type: :service do
  # This only mocks what's necessary
  before do
    # Ensure the StarSystemLookupService finds SOL system
    allow_any_instance_of(Lookup::StarSystemLookupService).to receive(:system_exists?).and_return(false)
    allow_any_instance_of(Lookup::StarSystemLookupService).to receive(:system_exists?).with("SOL").and_return(true)
    
    # Provide mock data for SOL
    allow_any_instance_of(Lookup::StarSystemLookupService).to receive(:fetch).with("SOL").and_return(
      {
        "galaxy" => { "name" => "Milky Way", "identifier" => "MILKY-WAY" },
        "solar_system" => { "name" => "Sol", "identifier" => "SOL" },
        "stars" => [
          {
            "name" => "Sun",
            "identifier" => "SUN-01",
            "type" => "G2V",
            "mass" => 1.0,
            "radius" => 6.96e8,
            "luminosity" => 1.0,
            "temperature" => 5778
          }
        ],
        "celestial_bodies" => {
          "terrestrial_planets" => [
            {
              "name" => "Earth",
              "identifier" => "EARTH-01",
              "type" => "terrestrial", 
              "mass" => 1.0,
              "radius" => 6.37e6,
              "gravity" => 1.0
            }
          ]
        }
      }
    )
    
    # Skip file operations
    allow(File).to receive(:open).and_return(true)
    allow(FileUtils).to receive(:mkdir_p).and_return(true)
  end

  let(:galaxy) { Galaxy.create!(name: "Test Galaxy", identifier: "TEST-GALAXY") }
  
  let(:solar_system) do
    # Mock the ensure_initial_star method before creating the system
    allow_any_instance_of(SolarSystem).to receive(:ensure_initial_star)
    
    system = SolarSystem.new(name: "Empty System", identifier: "EMPTY", galaxy: galaxy)
    
    # Bypass validation-related callbacks if they exist
    if system.respond_to?(:set_initial_star)
      system.define_singleton_method(:set_initial_star) { nil }
    end
    
    if system.respond_to?(:validate_star_presence)
      system.define_singleton_method(:validate_star_presence) { true }
    end
    
    system.save(validate: false)
    system
  end

  describe '#generate!' do
    context 'when generating a random system' do
      before do
        # Mock the ProceduralGenerator with our test data
        seed_data = {
          "galaxy" => { "name" => "Test Galaxy", "identifier" => "TEST-GALAXY" },
          "solar_system" => { "name" => "Test System", "identifier" => "TEST-SYSTEM" },
          "stars" => [
            {
              "name" => "Test Star",
              "identifier" => "TEST-STAR",
              "type" => "G2V",
              "mass" => 1.0,
              "radius" => 6.96e8,
              "luminosity" => 1.0,
              "temperature" => 5778
            }
          ],
          "celestial_bodies" => {
            "terrestrial_planets" => [
              {
                "name" => "Test Planet 1",
                "identifier" => "TEST-PLANET-1",
                "type" => "terrestrial",
                "mass" => 1.0,
                "radius" => 6.37e6,
                "gravity" => 1.0
              },
              {
                "name" => "Test Planet 2",
                "identifier" => "TEST-PLANET-2",
                "type" => "terrestrial",
                "mass" => 0.8,
                "radius" => 5.0e6,
                "gravity" => 0.8
              }
            ]
          }
        }
        
        allow_any_instance_of(StarSim::ProceduralGenerator).to receive(:generate_system_seed).and_return(seed_data)
        
        # Mock the SystemBuilderService to skip actual building
        # We'll let the fallback method handle it
        allow_any_instance_of(StarSim::SystemBuilderService).to receive(:build!).and_raise("Not implemented")
        
        # Create the generator service and run it
        StarSim::SystemGeneratorService.new(solar_system).generate!(
          num_stars: 1, 
          num_planets: 2
        )
        
        # Reload the system
        solar_system.reload
      end

      it 'creates the specified number of stars' do
        expect(solar_system.stars.count).to eq(1)
      end

      it 'creates celestial bodies' do
        # We might have more than exactly 2 if other services add more
        expect(solar_system.celestial_bodies.count).to be >= 2
      end

      it 'updates the solar system name and identifier' do
        expect(solar_system.name).to eq("Test System")
        expect(solar_system.identifier).to eq("TEST-SYSTEM")
      end
    end
    
    context 'with a predefined system' do
      let(:sol_system) do
        # Create a system with the SOL identifier that our lookup service recognizes
        system = SolarSystem.new(name: "Sol", identifier: "SOL", galaxy: galaxy)
        
        # Bypass validation-related callbacks
        if system.respond_to?(:set_initial_star)
          system.define_singleton_method(:set_initial_star) { nil }
        end
        
        if system.respond_to?(:validate_star_presence)
          system.define_singleton_method(:validate_star_presence) { true }
        end
        
        system.save(validate: false)
        system
      end
      
      it 'delegates to SystemBuilderService for building the system' do
        # Create a spy on the SystemBuilderService initialization
        builder_spy = spy("SystemBuilderService")
        allow(StarSim::SystemBuilderService).to receive(:new).with(name: "SOL").and_return(builder_spy)
        
        # Generate the system
        StarSim::SystemGeneratorService.new(sol_system).generate!(
          num_stars: 1, 
          num_planets: 9
        )
        
        # Verify the builder was called
        expect(builder_spy).to have_received(:build!)
      end
    end
  end
end
