namespace :game do
    desc "Reset game data and reload seeds"
    task reset: :environment do
      puts "Resetting game data..."
      
      begin
        # Clear existing data in the correct order (to avoid foreign key constraints)
        puts "Clearing existing data..."
        
        # Check and destroy models only if they exist
        if defined?(CelestialBodies::CelestialBody)
          puts "Deleting Celestial Bodies..."
          CelestialBodies::CelestialBody.destroy_all
        end
        
        if defined?(Star)
          puts "Deleting Stars..."
          Star.destroy_all
        end
        
        if defined?(SolarSystem)
          puts "Deleting Solar Systems..."
          SolarSystem.destroy_all 
        end
        
        if defined?(Galaxy)
          puts "Deleting Galaxies..."
          Galaxy.destroy_all
        end
        
        puts "Reloading seed data..."
        load Rails.root.join('db/seeds.rb')
        
        # Verify the data was loaded
        puts "Verification:"
        puts "Galaxies: #{Galaxy.count}"
        puts "Solar Systems: #{SolarSystem.count}" 
        puts "Stars: #{Star.count}"
        
        if defined?(CelestialBodies::CelestialBody)
          puts "Celestial Bodies: #{CelestialBodies::CelestialBody.count}"
          
          # Only check subclasses if they're defined
          if defined?(CelestialBodies::TerrestrialPlanet)
            puts "Terrestrial Planets: #{CelestialBodies::TerrestrialPlanet.count}"
          end
          
          if defined?(CelestialBodies::GasGiant)
            puts "Gas Giants: #{CelestialBodies::GasGiant.count}"
          end
          
          if defined?(CelestialBodies::Moon)
            puts "Moons: #{CelestialBodies::Moon.count}"
          end
        end
        
        puts "Game data reset complete!"
      rescue => e
        puts "Error resetting game data: #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
  end