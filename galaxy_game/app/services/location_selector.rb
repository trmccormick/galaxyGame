# app/services/location_selector.rb
class LocationSelector
    def self.choose_lava_tube(selection_method = :random)
      case selection_method
      when :random
        LavaTube.order("RANDOM()").first # Random selection
      when :player
        # Implement logic to allow the player to choose.
        # This might involve presenting a list of locations
        # and getting player input.  You'll need to decide
        # how to handle this interaction (console, web UI, etc.).
        # Placeholder for player selection:
        puts "Available Lava Tubes:"
        LavaTube.all.each_with_index do |tube, index|
          puts "#{index + 1}. #{tube.name} (#{tube.coordinates})"
        end
        print "Enter the number of your chosen lava tube: "
        choice = gets.chomp.to_i
        LavaTube.find_by_id(choice) # Or your way to convert the choice to a LavaTube
      when :priority
        LavaTube.order(priority: :desc).first
      else
        raise "Invalid selection method: #{selection_method}"
      end
    end
  end