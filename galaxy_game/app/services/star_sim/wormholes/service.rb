# app/services/star_sim/wormholes/service.rb
module StarSim
  module Wormholes
    class Service
      MAX_WORMHOLES_PER_SYSTEM = 3

      def self.shift_wormhole(wormhole)
        return unless wormhole.fluctuating?

        wormhole.entrance.update!(
          x_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
          y_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR), 
          z_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR)
        )

        wormhole.exit.update!(
          x_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
          y_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR),
          z_coordinate: rand(-GameConstants::MAX_DISTANCE_FROM_STAR..GameConstants::MAX_DISTANCE_FROM_STAR)
        )

        wormhole.update!(
          stability: random_stability,
          disruption_level: rand(0..100)
        )
      end

      def self.random_stability
        rand(0..100) # Random stability value, 0 being unstable, 100 being stable
      end

      def self.shift_wormholes
        Wormhole.fluctuating.each { |w| shift_wormhole(w) }
      end

      def self.system_at_max_wormholes?(system)
        system.wormholes_as_system_a.count + 
        system.wormholes_as_system_b.count >= GameConstants::MAX_WORMHOLES_PER_SYSTEM
      end

      def self.generate_connection(source_system:, type: :natural)
        if type == :natural
          # Natural wormholes can connect to any system, including new ones
          target_system = find_or_create_target_system(source_system)
        else
          # Artificial wormholes can only connect to discovered systems
          target_system = find_discovered_system(source_system)
          
          if target_system.nil?
            raise "Cannot create artificial wormhole - no discovered systems available"
          end
        end
        
        create_wormhole(source_system, target_system, natural: type == :natural)
      end

      private

      def self.find_or_create_target_system(source_system)
        # Determine if we're connecting to an existing system or generating a new one
        if should_create_new_system?
          create_new_system(source_system.galaxy)
        else
          find_existing_system(source_system)
        end
      end

      def self.find_existing_system(source_system)
        # Avoid connecting to the same system
        SolarSystem.where.not(id: source_system.id)
                  .order("RANDOM()")
                  .first
      end

      def self.should_create_new_system?
        # 60% chance to create a new system, 40% to use existing
        rand < 0.6
      end

      def self.create_new_system(galaxy)
        # Create a new system 
        new_system = SolarSystem.create!(
          name: "Unknown System", 
          identifier: "SYS-#{SecureRandom.hex(4)}",
          galaxy: galaxy,
          discovery_state: :undiscovered
        )
        
        # Generate the system
        StarSim::SystemGeneratorService.new(new_system).generate!(
          num_stars: rand(1..3),
          num_planets: rand(0..8)
        )
        
        new_system
      end

      def self.find_discovered_system(source_system)
        # For artificial wormholes, only connect to discovered systems
        SolarSystem.where(discovery_state: [:discovered, :explored])
                  .where.not(id: source_system.id)
                  .order("RANDOM()")
                  .first
      end

      def self.create_wormhole(source_system, target_system, natural: true)
        wormhole = Wormhole.create!(
          solar_system_a: source_system,
          solar_system_b: target_system,
          natural: natural,
          wormhole_type: determine_wormhole_type(natural),
          stability: natural ? :unstable : :stable
        )
        
        # Mark target system as discovered when a wormhole connects to it
        target_system.update!(discovery_state: :discovered) if target_system.undiscovered?
        
        # Return the created wormhole
        wormhole
      end

      def self.determine_wormhole_type(natural)
        if natural
          # Natural wormholes have random types
          [:traversable, :non_traversable, :one_way].sample
        else
          # Artificial wormholes are always traversable
          :traversable
        end
      end
    end
  end
end