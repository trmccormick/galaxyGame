# app/services/generators/cave_generator.rb
module Generators
  class CaveGenerator
    def initialize(random: true, params: {})
      @random = random
      @params = params
    end

    def generate
      # Create the cave feature
      cave = CelestialBodies::Features::Cave.create!(
        celestial_body: @params[:celestial_body],
        feature_id: @params[:feature_id] || "cv_#{rand(1000..9999)}",
        status: @params[:status] || 'natural',
        static_data: build_static_data
      )

      return cave unless cave.persisted?

      if @random
        generate_random_features(cave)
      else
        generate_predefined_features(cave)
      end

      cave.reload
    end

    private

    def build_static_data
      depth = @params[:depth] || rand(10..200)
      network_size = @params[:network_size] || rand(100..2000)

      dimensions = {
        'depth_m' => depth,
        'network_size_m' => network_size,
        'volume_m3' => @params[:volume] || calculate_volume(depth, network_size)
      }

      cave_type = @params[:cave_type] || ['limestone', 'lava', 'ice', 'erosional', 'tectonic'].sample

      conversion_suitability = {
        'habitat' => @params[:habitat_rating] || rand(1..8), # Caves are generally less suitable than lava tubes
        'estimated_cost_multiplier' => @params[:cost_multiplier] || rand(1.2..2.5), # More expensive due to complexity
        'advantages' => @params[:advantages] || generate_advantages,
        'challenges' => @params[:challenges] || generate_challenges
      }

      {
        'dimensions' => dimensions,
        'cave_type' => cave_type,
        'conversion_suitability' => conversion_suitability,
        'priority' => @params[:priority] || rand(1..4),
        'strategic_value' => @params[:strategic_value] || generate_strategic_value
      }
    end

    def calculate_volume(depth, network_size)
      # Rough estimation: assume average cross-section of 10m²
      depth * network_size * 10
    end

    def generate_advantages
      possible_advantages = [
        'Natural radiation shielding',
        'Complex network for expansion',
        'Geological stability',
        'Hidden location',
        'Natural ventilation potential'
      ]
      possible_advantages.sample(rand(1..3))
    end

    def generate_challenges
      possible_challenges = [
        'Complex cave system navigation',
        'Limited natural light',
        'Groundwater issues',
        'Dust and debris',
        'Structural collapse risk',
        'Limited access points'
      ]
      possible_challenges.sample(rand(2..4)) # Caves have more challenges
    end

    def generate_strategic_value
      possible_values = [
        'Hidden base location',
        'Scientific research site',
        'Resource exploration',
        'Emergency shelter',
        'Covert operations'
      ]
      possible_values.sample(rand(1..2))
    end

    def generate_predefined_features(cave)
      if @params[:skylights]
        @params[:skylights].each do |skylight_data|
          CelestialBodies::Features::Skylight.create!(
            celestial_body: cave.celestial_body,
            parent_feature: cave,
            feature_id: "#{cave.feature_id}_skylight_#{rand(100..999)}",
            status: 'natural',
            static_data: {
              'dimensions' => {
                'diameter_m' => skylight_data[:diameter] || rand(2..15)
              },
              'position' => {
                'distance_from_entrance_m' => skylight_data[:position] || rand(0..cave.network_size_m.to_i)
              }
            }
          )
        end
      end

      if @params[:access_points]
        @params[:access_points].each do |point_data|
          CelestialBodies::Features::AccessPoint.create!(
            celestial_body: cave.celestial_body,
            parent_feature: cave,
            feature_id: "#{cave.feature_id}_access_#{rand(100..999)}",
            status: 'natural',
            static_data: {
              'dimensions' => {
                'width_m' => point_data[:size] || rand(1..10),
                'height_m' => point_data[:size] || rand(1..8)
              },
              'position' => {
                'distance_from_entrance_m' => point_data[:position] || rand(0..cave.network_size_m.to_i)
              },
              'attributes' => {
                'access_type' => point_data[:access_type] || ['narrow', 'tight', 'spacious'].sample
              }
            }
          )
        end
      end
    end

    def generate_random_features(cave)
      generate_skylights(cave)
      generate_access_points(cave)
    end

    def generate_skylights(cave)
      num_skylights = rand(0..3) # Caves may have fewer skylights
      num_skylights.times do |i|
        CelestialBodies::Features::Skylight.create!(
          celestial_body: cave.celestial_body,
          parent_feature: cave,
          feature_id: "#{cave.feature_id}_skylight_#{i + 1}",
          status: 'natural',
          static_data: {
            'dimensions' => {
              'diameter_m' => rand(2..15)
            },
            'position' => {
              'distance_from_entrance_m' => rand(0..cave.network_size_m.to_i)
            }
          }
        )
      end
    end

    def generate_access_points(cave)
      num_points = rand(1..4)
      num_points.times do |i|
        CelestialBodies::Features::AccessPoint.create!(
          celestial_body: cave.celestial_body,
          parent_feature: cave,
          feature_id: "#{cave.feature_id}_access_#{i + 1}",
          status: 'natural',
          static_data: {
            'dimensions' => {
              'width_m' => rand(1..10),
              'height_m' => rand(1..8)
            },
            'position' => {
              'distance_from_entrance_m' => rand(0..cave.network_size_m.to_i)
            },
            'attributes' => {
              'access_type' => ['narrow', 'tight', 'spacious'].sample
            }
          }
        )
      end
    end
  end
end