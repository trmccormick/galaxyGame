require 'rails_helper'

RSpec.describe StarSim::ProceduralGenerator, type: :service do
  let(:solar_system) do
    # Create directly without using factories
    galaxy = Galaxy.create!(name: "Test Galaxy", identifier: "TEST-GALAXY")
    
    # Create the solar system directly
    system = SolarSystem.new(name: "Empty System", identifier: "EMPTY", galaxy: galaxy)
    
    # Skip callbacks that might create initial stars
    system.define_singleton_method(:ensure_initial_star) { nil } if system.respond_to?(:ensure_initial_star)
    system.define_singleton_method(:validate_star_presence) { true } if system.respond_to?(:validate_star_presence)
    
    # Save without validation
    system.save(validate: false)
    
    system
  end
  
  let(:generator) { SystemGenerator.new(solar_system) }
  let(:num_planets) { 2 }
  let(:num_stars) { 1 }

  describe '#generate_system' do
    before do
      # Most basic stubs
      allow_any_instance_of(NameGeneratorService).to receive(:generate_system_name).and_return("Test System")
      allow_any_instance_of(NameGeneratorService).to receive(:generate_star_name).and_return("Test Star")
      allow_any_instance_of(NameGeneratorService).to receive(:generate_planet_identifier).and_return("Test-Planet")
      
      # Skip validation
      allow_any_instance_of(SolarSystem).to receive(:save!).and_return(true)
      allow_any_instance_of(SolarSystem).to receive(:update!).and_return(true)
    end

    it 'creates the specified number of stars' do
      expect(generator).to receive(:create_stars).with(num_stars).and_call_original
      expect(generator).to receive(:create_celestial_bodies).with(num_planets).and_call_original
      
      generator.generate_system(num_planets: num_planets, num_stars: num_stars)
    end

    it 'creates the specified number of celestial bodies' do
      expect(generator).to receive(:create_celestial_bodies).with(num_planets).and_call_original
      
      generator.generate_system(num_planets: num_planets, num_stars: num_stars)
    end
  end
end