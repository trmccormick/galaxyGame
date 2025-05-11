module TerraSim
  class GeosphereInitializer
    def initialize(celestial_body)
      @celestial_body = celestial_body
      @body_type = celestial_body.class.name.demodulize.underscore
      @config = get_config_for_body_type
    end
    
    def initialize_geosphere
      geological_activity = determine_geological_activity
      tectonic_activity = determine_tectonic_activity
      
      @geosphere = @celestial_body.build_geosphere(
        geological_activity: geological_activity,
        tectonic_activity: tectonic_activity
      )
      
      initialize_materials
      
      @geosphere.save!
    end
    
    private
    
    def initialize_materials
      # Core materials
      @config[:core_materials].each do |material|
        percentage = 100.0 / @config[:core_materials].length
        @geosphere.geological_materials.build(
          name: material,
          percentage: percentage,
          layer: 'core',
          state: determine_state(material, 'core'),
          mass: calculate_layer_mass('core') * (percentage / 100.0)
        )
      end
      
      # Mantle materials
      @config[:mantle_materials].each do |material|
        percentage = 100.0 / @config[:mantle_materials].length
        @geosphere.geological_materials.build(
          name: material,
          percentage: percentage,
          layer: 'mantle',
          state: determine_state(material, 'mantle'),
          mass: calculate_layer_mass('mantle') * (percentage / 100.0)
        )
      end
      
      # Crust materials
      @config[:crust_materials].each do |material|
        percentage = 100.0 / @config[:crust_materials].length
        @geosphere.geological_materials.build(
          name: material,
          percentage: percentage,
          layer: 'crust',
          state: determine_state(material, 'crust'),
          mass: calculate_layer_mass('crust') * (percentage / 100.0)
        )
      end
    end
    
    def determine_state(material, layer)
      # Always treat these specific gases as gases in the crust
      if ['Hydrogen', 'Helium', 'Methane', 'Ammonia'].include?(material) && layer == 'crust'
        return 'gas'
      end
      
      # Ice always stays solid
      if material.include?('Ice')
        return 'solid'
      end
      
      # Metallic hydrogen under extreme pressure
      if material == 'Hydrogen' && layer == 'core' && calculate_pressure(layer) > 1_000_000
        return 'metallic_hydrogen'
      end
      
      # Default state based on layer
      case layer
      when 'core'
        'solid'  # Default core state is solid
      when 'mantle'
        'liquid' # Default mantle state is liquid
      else
        # Default crust state depends on material
        ['Hydrogen', 'Helium', 'Methane', 'Ammonia'].include?(material) ? 'gas' : 'solid'
      end
    end

    def calculate_pressure(layer)
      case layer
      when 'core'
        # Convert mass to float before division
        @celestial_body.mass ? (@celestial_body.mass.to_f / 5.972e24) * 3.6e11 : 3.6e11
      when 'mantle'
        @celestial_body.mass ? (@celestial_body.mass.to_f / 5.972e24) * 1.3e11 : 1.3e11
      else
        @celestial_body.mass ? (@celestial_body.mass.to_f / 5.972e24) * 1e5 : 1e5
      end
    end
    
    def calculate_layer_mass(layer)
      radius = @celestial_body.radius || 6371000.0 # Earth radius in meters
      density = @celestial_body.density || 5.51 # Earth density in g/cm³
      
      case layer
      when 'core'
        # Significantly increase core coefficient to make core > mantle
        radius * 0.6 * density * 1e9 # Increase from 0.5 to 0.6
      when 'mantle'
        radius * 0.3 * density * 1e9 # Keep mantle at 0.3
      when 'crust'
        radius * 0.01 * density * 1e9 # Keep crust at 0.01
      end
    end
    
    def determine_geological_activity
      case @body_type
      when 'terrestrial_planet'  then rand(1..10)
      when 'carbon_planet'       then rand(1..8)
      when 'gas_giant'           then rand(0..5)
      when 'ice_giant'           then rand(0..3)
      else                            rand(0..3)
      end
    end
    
    def determine_tectonic_activity
      case @body_type
      when 'terrestrial_planet', 'carbon_planet' then true
      when 'celestial_body' then true  
      else false
      end
    end
    
    def determine_tectonic_plates
      case @body_type
      when 'terrestrial_planet'  then rand(5..15)
      when 'carbon_planet'       then rand(5..15)
      else 0
      end
    end

    def get_config_for_body_type
      case @body_type
      when 'terrestrial_planet'
        {
          core_materials: ['Iron', 'Nickel'],
          mantle_materials: ['Silicon', 'Oxygen', 'Magnesium'],
          crust_materials: ['Silicon', 'Oxygen', 'Aluminum']
        }
      when 'carbon_planet'
        {
          core_materials: ['Iron', 'Carbon'],
          mantle_materials: ['Carbon', 'Silicon Carbide'],
          crust_materials: ['Graphite', 'Diamond', 'Silicon Carbide']
        }
      when 'ice_giant'
        {
          core_materials: ['Rock', 'Ice'],
          mantle_materials: ['Water Ice', 'Methane Ice', 'Ammonia Ice'],
          crust_materials: ['Methane Ice', 'Ammonia Ice']
        }
      when 'gas_giant'
        {
          core_materials: ['Iron', 'Silicate', 'Hydrogen'],
          mantle_materials: ['Hydrogen', 'Helium'],
          crust_materials: ['Hydrogen', 'Helium', 'Methane']
        }
      else
        {
          core_materials: ['Iron', 'Nickel'],
          mantle_materials: ['Silicon', 'Oxygen', 'Magnesium'],
          crust_materials: ['Silicon', 'Oxygen', 'Aluminum']
        }
      end
    end
  end
end