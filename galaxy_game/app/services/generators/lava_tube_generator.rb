# app/services/generators/lava_tube_generator.rb
module Generators
  class LavaTubeGenerator
    def initialize(random: true, params: {})
      @random = random
      @params = params
    end

    def generate
      # Create the lava tube feature
      lava_tube = CelestialBodies::Features::LavaTube.create!(
        celestial_body: @params[:celestial_body],
        feature_id: @params[:feature_id] || "lt_#{rand(1000..9999)}",
        status: @params[:status] || 'natural',
        static_data: build_static_data
      )

      return lava_tube unless lava_tube.persisted?

      if @random
        generate_random_features(lava_tube)
      else
        generate_predefined_features(lava_tube)
      end

      lava_tube.reload
    end

    private

    def build_static_data
      dimensions = {
        'length_m' => @params[:length] || rand(1000..5000),
        'width_m' => @params[:diameter] || rand(10..50), # Using diameter as width
        'height_m' => @params[:height] || rand(5..25),
        'estimated_volume_m3' => nil # Will be calculated if needed
      }

      attributes = {
        'natural_shielding' => @params[:natural_shielding] || rand(0.1..0.9),
        'thermal_stability' => @params[:thermal_stability] || ['stable', 'moderate', 'unstable'].sample
      }

      conversion_suitability = {
        'habitat' => @params[:habitat_rating] || rand(1..10),
        'estimated_cost_multiplier' => @params[:cost_multiplier] || rand(0.5..2.0),
        'advantages' => @params[:advantages] || generate_advantages,
        'challenges' => @params[:challenges] || generate_challenges
      }

      {
        'dimensions' => dimensions,
        'attributes' => attributes,
        'conversion_suitability' => conversion_suitability,
        'priority' => @params[:priority] || rand(1..5),
        'strategic_value' => @params[:strategic_value] || generate_strategic_value
      }
    end

    def generate_advantages
      possible_advantages = [
        'Natural radiation shielding',
        'Stable temperature',
        'Large internal volume',
        'Multiple access points',
        'Geological stability',
        'Natural ventilation potential'
      ]
      possible_advantages.sample(rand(1..3))
    end

    def generate_challenges
      possible_challenges = [
        'Seismic activity risk',
        'Limited natural light',
        'Complex access requirements',
        'Groundwater infiltration',
        'Dust accumulation',
        'Temperature extremes at entrances'
      ]
      possible_challenges.sample(rand(1..3))
    end

    def generate_strategic_value
      possible_values = [
        'Habitat potential',
        'Resource extraction site',
        'Transportation corridor',
        'Scientific research location',
        'Military/defensive position'
      ]
      possible_values.sample(rand(1..2))
    end

    def generate_predefined_features(lava_tube)
      if @params[:skylights]
        @params[:skylights].each do |skylight_data|
          CelestialBodies::Features::Skylight.create!(
            celestial_body: lava_tube.celestial_body,
            parent_feature: lava_tube,
            feature_id: "#{lava_tube.feature_id}_skylight_#{rand(100..999)}",
            status: 'natural',
            static_data: {
              'dimensions' => {
                'diameter_m' => skylight_data[:diameter] || rand(5..20)
              },
              'position' => {
                'distance_from_entrance_m' => skylight_data[:position] || rand(0..lava_tube.length_m.to_i)
              }
            }
          )
        end
      end

      if @params[:access_points]
        @params[:access_points].each do |point_data|
          CelestialBodies::Features::AccessPoint.create!(
            celestial_body: lava_tube.celestial_body,
            parent_feature: lava_tube,
            feature_id: "#{lava_tube.feature_id}_access_#{rand(100..999)}",
            status: 'natural',
            static_data: {
              'dimensions' => {
                'width_m' => point_data[:size] || rand(2..10),
                'height_m' => point_data[:size] || rand(2..10)
              },
              'position' => {
                'distance_from_entrance_m' => point_data[:position] || rand(0..lava_tube.length_m.to_i)
              },
              'attributes' => {
                'access_type' => point_data[:access_type] || [:large, :medium, :small].sample
              }
            }
          )
        end
      end
    end

    def generate_random_features(lava_tube)
      generate_skylights(lava_tube)
      generate_access_points(lava_tube)
    end

    def generate_skylights(lava_tube)
      num_skylights = rand(1..5)
      num_skylights.times do |i|
        CelestialBodies::Features::Skylight.create!(
          celestial_body: lava_tube.celestial_body,
          parent_feature: lava_tube,
          feature_id: "#{lava_tube.feature_id}_skylight_#{i + 1}",
          status: 'natural',
          static_data: {
            'dimensions' => {
              'diameter_m' => rand(5..20)
            },
            'position' => {
              'distance_from_entrance_m' => rand(0..lava_tube.length_m.to_i)
            }
          }
        )
      end
    end

    def generate_access_points(lava_tube)
      num_points = rand(2..10)
      num_points.times do |i|
        CelestialBodies::Features::AccessPoint.create!(
          celestial_body: lava_tube.celestial_body,
          parent_feature: lava_tube,
          feature_id: "#{lava_tube.feature_id}_access_#{i + 1}",
          status: 'natural',
          static_data: {
            'dimensions' => {
              'width_m' => rand(2..10),
              'height_m' => rand(2..10)
            },
            'position' => {
              'distance_from_entrance_m' => rand(0..lava_tube.length_m.to_i)
            },
            'attributes' => {
              'access_type' => [:large, :medium, :small].sample
            }
          }
        )
      end
    end
  end
end