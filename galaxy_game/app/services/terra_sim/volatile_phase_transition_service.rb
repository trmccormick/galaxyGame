module TerraSim
  class VolatilePhaseTransitionService
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @geosphere = celestial_body.geosphere
      @atmosphere = celestial_body.atmosphere
      @temperature = celestial_body.surface_temperature
      @material_lookup = Lookup::MaterialLookupService.new
    end
    
    def simulate
      return unless @geosphere && @geosphere.stored_volatiles.present?
      
      # Calculate what volatiles should be released based on temperature
      released_volatiles = @geosphere.calculate_volatile_release(@temperature)
      
      # Add released volatiles to atmosphere
      add_to_atmosphere(released_volatiles) if @atmosphere && released_volatiles.present?
      
      # Check for freezing of atmospheric gases
      freeze_from_atmosphere if @atmosphere
    end
    
    private
    
    def add_to_atmosphere(released_volatiles)
      released_volatiles.each do |compound, amount|
        # Convert mass to percentage based on total atmosphere
        current_mass = calculate_atmospheric_mass
        
        # Skip if no mass (no atmosphere)
        next if current_mass <= 0
        
        # Calculate what percentage this release represents
        percentage = (amount / current_mass) * 100
        
        # Add or update gas in atmosphere
        gas = @atmosphere.gases.find_or_initialize_by(name: compound)
        
        if gas.persisted?
          # Update existing gas using update_columns to avoid frozen errors
          gas.update_columns(
            percentage: gas.percentage + percentage,
            updated_at: Time.current
          )
        else
          # Create new gas
          gas.percentage = percentage
          gas.save!
        end
      end
      
      # Reload before normalizing to ensure fresh data
      @atmosphere.gases.reload
      normalize_atmosphere
    end
    
    def freeze_from_atmosphere
      # Work with IDs instead of objects to avoid frozen/destroyed issues
      gas_data = @atmosphere.gases.map { |g| { id: g.id, name: g.name, percentage: g.percentage } }
      
      gas_data.each do |gas_info|
        # Get freezing point - for many gases this is the sublimation point
        freezing_point = case gas_info[:name]
                        when 'CO2'
                          194.7  # CO2 freezing point
                        when 'N2'
                          63.2   # N2 freezing point 
                        when 'CH4'
                          90.7   # CH4 freezing point
                        when 'O2'
                          54.8   # O2 freezing point
                        when 'H2O'
                          273.15 # Water freezing point
                        else
                          100.0  # Default value
                        end
        
        # Check if temperature is below freezing point
        if @temperature < freezing_point
          # Calculate percentage that freezes (temperature dependent)
          freeze_factor = [(freezing_point - @temperature) / 50.0, 1.0].min * 0.5
          frozen_percentage = gas_info[:percentage] * freeze_factor
          
          # Remove from atmosphere
          new_percentage = gas_info[:percentage] - frozen_percentage
          
          if new_percentage > 0.1
            # Update using direct SQL to avoid frozen issues
            CelestialBodies::Materials::Gas.where(id: gas_info[:id]).update_all(
              percentage: new_percentage,
              updated_at: Time.current
            )
          else
            # Remove gas completely if percentage is too small
            CelestialBodies::Materials::Gas.where(id: gas_info[:id]).delete_all
          end
          
          # Add to geosphere stored volatiles
          if frozen_percentage > 0
            # Convert percentage back to mass
            frozen_mass = (frozen_percentage / 100.0) * calculate_atmospheric_mass
            
            # Determine where to store it based on the compound
            location = case gas_info[:name]
                      when 'H2O'
                        'polar_caps' # Water tends to form polar caps
                      else
                        'surface_ice' # Default for most gases
                      end
            
            # Update stored volatiles
            current_stored = @geosphere.stored_volatiles.dig(gas_info[:name], location) || 0
            @geosphere.update_volatile_store(gas_info[:name], location, current_stored + frozen_mass)
          end
        end
      end
      
      # CRITICAL: Reload gases after modifications
      @atmosphere.gases.reload
      
      # Normalize gas percentages to 100%
      normalize_atmosphere
    end
    
    def normalize_atmosphere
      # Query fresh from database to avoid frozen/stale data
      total_percentage = CelestialBodies::Materials::Gas
        .where(atmosphere_id: @atmosphere.id)
        .sum(:percentage)
      
      if total_percentage > 0 && (total_percentage - 100).abs > 0.01
        # Get fresh gas records
        gases = CelestialBodies::Materials::Gas.where(atmosphere_id: @atmosphere.id)
        
        gases.each do |gas|
          normalized_percentage = (gas.percentage / total_percentage) * 100
          
          # Use update_all for atomic update without loading objects
          CelestialBodies::Materials::Gas
            .where(id: gas.id)
            .update_all(
              percentage: normalized_percentage,
              updated_at: Time.current
            )
        end
        
        # Reload the association after updates
        @atmosphere.gases.reload
      end
    end
    
    def calculate_atmospheric_mass
      # Calculate atmospheric mass from pressure and planet data
      # This is a simplified calculation
      gravity = @celestial_body.gravity || 9.8
      radius = @celestial_body.radius || 6371000
      pressure = @atmosphere.pressure || 0
      
      # M = (P * 4πr²) / g
      (pressure * 101325) * (4 * Math::PI * radius**2) / gravity
    end
  end
end