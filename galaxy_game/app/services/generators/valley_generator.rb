# app/services/generators/valley_generator.rb
module Generators
  class ValleyGenerator
    def initialize(random: true, params: {})
      @random = random
      @params = params
    end

    def generate
      # Create the valley feature
      valley = CelestialBodies::Features::Valley.create!(
        celestial_body: @params[:celestial_body],
        feature_id: @params[:feature_id] || "vl_#{rand(1000..9999)}",
        status: @params[:status] || 'natural',
        static_data: build_static_data
      )

      return valley unless valley.persisted?

      if @random
        generate_random_features(valley)
      else
        generate_predefined_features(valley)
      end

      valley.reload
    end

    private

    def build_static_data
      dimensions = {
        'length_m' => @params[:length] || rand(5000..50000),
        'width_m' => @params[:width] || rand(1000..10000),
        'depth_m' => @params[:depth] || rand(100..1000),
        'volume_m3' => nil # Will be calculated if needed
      }

      formation = @params[:formation] || ['tectonic_rifting', 'erosion', 'glacial_carving', 'impact_cratering'].sample

      conversion_suitability = {
        'habitat' => @params[:habitat_rating] || rand(1..10),
        'estimated_cost_multiplier' => @params[:cost_multiplier] || rand(0.8..1.5),
        'advantages' => @params[:advantages] || generate_advantages,
        'challenges' => @params[:challenges] || generate_challenges
      }

      segments = @params[:segments] || generate_segments(dimensions)

      {
        'dimensions' => dimensions,
        'formation' => formation,
        'conversion_suitability' => conversion_suitability,
        'segments' => segments,
        'priority' => @params[:priority] || rand(1..5),
        'strategic_value' => @params[:strategic_value] || generate_strategic_value
      }
    end

    def generate_advantages
      possible_advantages = [
        'Natural wind protection',
        'Large enclosed volume',
        'Multiple construction segments',
        'Geological stability',
        'Natural drainage patterns',
        'Strategic defensive position'
      ]
      possible_advantages.sample(rand(1..3))
    end

    def generate_challenges
      possible_challenges = [
        'Complex terrain',
        'Limited flat construction areas',
        'Weather exposure at openings',
        'Dust accumulation',
        'Temperature variations',
        'Access difficulties'
      ]
      possible_challenges.sample(rand(1..3))
    end

    def generate_strategic_value
      possible_values = [
        'Large habitat potential',
        'Agricultural development site',
        'Transportation corridor',
        'Resource collection area',
        'Military/defensive position'
      ]
      possible_values.sample(rand(1..2))
    end

    def generate_segments(dimensions)
      length = dimensions['length_m']
      width = dimensions['width_m']

      # Divide valley into 3-8 segments
      num_segments = rand(3..8)
      segment_length = length / num_segments

      segments = []
      num_segments.times do |i|
        start_pos = i * segment_length
        end_pos = (i + 1) * segment_length

        segments << {
          'name' => "Segment #{i + 1}",
          'start_position_m' => start_pos,
          'end_position_m' => end_pos,
          'length_m' => segment_length,
          'width_m' => width * rand(0.8..1.2), # Vary width slightly
          'terrain_complexity' => rand(1..5)
        }
      end

      segments
    end

    def generate_predefined_features(valley)
      # Valleys typically don't have predefined child features like skylights
      # They might have access points at the ends
      if @params[:access_points]
        @params[:access_points].each do |point_data|
          CelestialBodies::Features::AccessPoint.create!(
            celestial_body: valley.celestial_body,
            parent_feature: valley,
            feature_id: "#{valley.feature_id}_access_#{rand(100..999)}",
            status: 'natural',
            static_data: {
              'dimensions' => {
                'width_m' => point_data[:width] || rand(20..100),
                'height_m' => point_data[:height] || rand(10..50)
              },
              'position' => {
                'distance_from_entrance_m' => point_data[:position] || rand(0..valley.length_m.to_i)
              },
              'attributes' => {
                'access_type' => point_data[:access_type] || [:wide, :narrow].sample
              }
            }
          )
        end
      end
    end

    def generate_random_features(valley)
      # Generate 0-2 access points randomly
      num_points = rand(0..2)
      num_points.times do |i|
        CelestialBodies::Features::AccessPoint.create!(
          celestial_body: valley.celestial_body,
          parent_feature: valley,
          feature_id: "#{valley.feature_id}_access_#{i + 1}",
          status: 'natural',
          static_data: {
            'dimensions' => {
              'width_m' => rand(20..100),
              'height_m' => rand(10..50)
            },
            'position' => {
              'distance_from_entrance_m' => rand(0..valley.length_m.to_i)
            },
            'attributes' => {
              'access_type' => [:wide, :narrow].sample
            }
          }
        )
      end
    end
  end
end