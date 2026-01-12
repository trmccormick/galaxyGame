# app/services/generators/crater_generator.rb
module Generators
  class CraterGenerator
    def initialize(random: true, params: {})
      @random = random
      @params = params
    end

    def generate
      # Create the crater feature
      crater = CelestialBodies::Features::Crater.create!(
        celestial_body: @params[:celestial_body],
        feature_id: @params[:feature_id] || "cr_#{rand(1000..9999)}",
        status: @params[:status] || 'natural',
        static_data: build_static_data
      )

      crater.reload
    end

    private

    def build_static_data
      diameter = @params[:diameter] || rand(1000..50000) # 1km to 50km
      depth = @params[:depth] || calculate_depth(diameter)

      dimensions = {
        'diameter_m' => diameter,
        'depth_m' => depth,
        'rim_height_m' => @params[:rim_height] || rand(10..200),
        'floor_area_m2' => Math::PI * (diameter / 2.0) ** 2
      }

      crater_type = @params[:crater_type] || ['impact', 'volcanic', 'collapse', 'erosional'].sample

      composition = build_composition

      attributes = {
        'permanently_shadowed' => @params[:permanently_shadowed] || rand < 0.3, # 30% chance
        'solar_exposure_percent' => @params[:solar_exposure] || rand(0..100),
        'temperature_floor_k' => @params[:temperature] || rand(50..200)
      }

      conversion_suitability = {
        'crater_dome' => @params[:dome_suitability] || rand(1..10),
        'estimated_cost_multiplier' => @params[:cost_multiplier] || calculate_cost_multiplier(diameter),
        'advantages' => @params[:advantages] || generate_advantages,
        'challenges' => @params[:challenges] || generate_challenges
      }

      resources = build_resources

      {
        'dimensions' => dimensions,
        'crater_type' => crater_type,
        'composition' => composition,
        'attributes' => attributes,
        'conversion_suitability' => conversion_suitability,
        'resources' => resources,
        'priority' => @params[:priority] || rand(1..5),
        'strategic_value' => @params[:strategic_value] || generate_strategic_value
      }
    end

    def calculate_depth(diameter)
      # Simple depth estimation based on diameter
      # Real craters follow complex scaling laws, but this is simplified
      depth_ratio = rand(0.02..0.15) # Depth/diameter ratio
      diameter * depth_ratio
    end

    def calculate_cost_multiplier(diameter)
      # Larger craters are more expensive to dome
      diameter_km = diameter / 1000.0
      base_multiplier = 1.0

      if diameter_km > 20
        base_multiplier * 2.0
      elsif diameter_km > 10
        base_multiplier * 1.5
      elsif diameter_km < 2
        base_multiplier * 0.8
      else
        base_multiplier
      end
    end

    def build_composition
      has_ice = @params[:has_ice] || rand < 0.4 # 40% chance of ice

      composition = {
        'surface_material' => @params[:surface_material] || ['basalt', 'regolith', 'ice', 'sediment'].sample,
        'ice_present' => has_ice
      }

      if has_ice
        composition['ice_concentration'] = @params[:ice_concentration] || rand(0.1..0.9)
        composition['ice_depth_m'] = @params[:ice_depth] || rand(0.1..10.0)
      end

      composition
    end

    def build_resources
      resources = {}

      if @params[:water_ice_tons]
        resources['water_ice_tons'] = @params[:water_ice_tons]
        resources['accessible_ice_tons'] = @params[:accessible_ice_tons] || (@params[:water_ice_tons] * rand(0.1..0.5))
      elsif rand < 0.3 # 30% chance of ice resources
        ice_tons = rand(1000..1000000)
        resources['water_ice_tons'] = ice_tons
        resources['accessible_ice_tons'] = ice_tons * rand(0.1..0.5)
      end

      minerals = @params[:minerals] || []
      if minerals.empty? && rand < 0.4 # 40% chance of minerals
        possible_minerals = ['iron', 'titanium', 'rare_earth_elements', 'helium_3', 'water']
        minerals = possible_minerals.sample(rand(1..3))
      end

      resources['minerals'] = minerals unless minerals.empty?

      resources
    end

    def generate_advantages
      possible_advantages = [
        'Natural bowl shape for dome construction',
        'Radiation shielding from walls',
        'Large enclosed volume',
        'Potential ice resources',
        'Strategic defensive position',
        'Temperature stability'
      ]
      possible_advantages.sample(rand(1..3))
    end

    def generate_challenges
      possible_challenges = [
        'Complex dome engineering',
        'Dust accumulation',
        'Limited access points',
        'Temperature extremes',
        'Radiation exposure at rim',
        'Structural integrity concerns'
      ]
      possible_challenges.sample(rand(1..3))
    end

    def generate_strategic_value
      possible_values = [
        'Water ice mining site',
        'Large habitat potential',
        'Resource extraction',
        'Scientific research location',
        'Strategic observation point'
      ]
      possible_values.sample(rand(1..2))
    end
  end
end