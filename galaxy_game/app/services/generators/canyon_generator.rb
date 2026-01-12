# app/services/generators/canyon_generator.rb
module Generators
  class CanyonGenerator
    def initialize(random: true, params: {})
      @random = random
      @params = params
    end

    def generate
      # Create the canyon feature
      canyon = CelestialBodies::Features::Canyon.create!(
        celestial_body: @params[:celestial_body],
        feature_id: @params[:feature_id] || "cn_#{rand(1000..9999)}",
        status: @params[:status] || 'natural',
        static_data: build_static_data
      )

      return canyon unless canyon.persisted?

      if @random
        generate_random_features(canyon)
      else
        generate_predefined_features(canyon)
      end

      canyon.reload
    end

    private

    def build_static_data
      length = @params[:length] || rand(1000..20000)
      width = @params[:width] || rand(50..500) # Canyons are narrower than valleys
      depth = @params[:depth] || rand(200..2000) # Canyons are deeper than valleys

      dimensions = {
        'length_m' => length,
        'width_m' => width,
        'depth_m' => depth,
        'volume_m3' => length * width * depth * 0.7 # Rough volume estimation with 70% fill factor
      }

      formation = @params[:formation] || ['tectonic_rifting', 'erosion', 'river_cutting', 'glacial_erosion'].sample

      conversion_suitability = {
        'habitat' => @params[:habitat_rating] || rand(1..7), # Canyons are challenging to enclose
        'estimated_cost_multiplier' => @params[:cost_multiplier] || rand(1.5..3.0), # Very expensive due to height
        'advantages' => @params[:advantages] || generate_advantages,
        'challenges' => @params[:challenges] || generate_challenges
      }

      segments = @params[:segments] || generate_segments(length, width, depth)

      {
        'dimensions' => dimensions,
        'formation' => formation,
        'conversion_suitability' => conversion_suitability,
        'segments' => segments,
        'priority' => @params[:priority] || rand(1..4),
        'strategic_value' => @params[:strategic_value] || generate_strategic_value
      }
    end

    def generate_segments(length, width, depth)
      # Canyons are divided into segments for construction
      num_segments = rand(2..6)
      segment_length = length / num_segments

      segments = []
      num_segments.times do |i|
        start_pos = i * segment_length
        end_pos = (i + 1) * segment_length

        # Vary dimensions slightly per segment
        segment_width = width * rand(0.8..1.3)
        segment_depth = depth * rand(0.9..1.1)

        segments << {
          'name' => "Section #{i + 1}",
          'start_position_m' => start_pos,
          'end_position_m' => end_pos,
          'length_m' => segment_length,
          'width_m' => segment_width,
          'depth_m' => segment_depth,
          'terrain_complexity' => rand(2..5), # Canyons are more complex
          'cliff_stability' => rand(1..5)
        }
      end

      segments
    end

    def generate_advantages
      possible_advantages = [
        'Natural wall protection',
        'Strategic defensive position',
        'Wind protection',
        'Natural drainage',
        'Large vertical space for construction',
        'Geological stability'
      ]
      possible_advantages.sample(rand(1..3))
    end

    def generate_challenges
      possible_challenges = [
        'Extreme height for covering',
        'Cliff stability concerns',
        'Limited construction access',
        'Weather exposure',
        'Dust accumulation',
        'Complex engineering requirements',
        'Temperature variations'
      ]
      possible_challenges.sample(rand(2..4)) # Canyons have significant challenges
    end

    def generate_strategic_value
      possible_values = [
        'Natural fortress',
        'Observation and surveillance point',
        'Transportation corridor protection',
        'Resource mining site',
        'Scientific research location'
      ]
      possible_values.sample(rand(1..2))
    end

    def generate_predefined_features(canyon)
      # Canyons might have access points at various heights
      if @params[:access_points]
        @params[:access_points].each do |point_data|
          CelestialBodies::Features::AccessPoint.create!(
            celestial_body: canyon.celestial_body,
            parent_feature: canyon,
            feature_id: "#{canyon.feature_id}_access_#{rand(100..999)}",
            status: 'natural',
            static_data: {
              'dimensions' => {
                'width_m' => point_data[:width] || rand(5..30),
                'height_m' => point_data[:height] || rand(3..15)
              },
              'position' => {
                'distance_from_entrance_m' => point_data[:position] || rand(0..canyon.length_m.to_i),
                'height_above_floor_m' => point_data[:height_above_floor] || rand(0..canyon.depth_m.to_i)
              },
              'attributes' => {
                'access_type' => point_data[:access_type] || ['ledge', 'cave', 'slope'].sample
              }
            }
          )
        end
      end
    end

    def generate_random_features(canyon)
      # Generate 0-3 access points randomly
      num_points = rand(0..3)
      num_points.times do |i|
        CelestialBodies::Features::AccessPoint.create!(
          celestial_body: canyon.celestial_body,
          parent_feature: canyon,
          feature_id: "#{canyon.feature_id}_access_#{i + 1}",
          status: 'natural',
          static_data: {
            'dimensions' => {
              'width_m' => rand(5..30),
              'height_m' => rand(3..15)
            },
            'position' => {
              'distance_from_entrance_m' => rand(0..canyon.length_m.to_i),
              'height_above_floor_m' => rand(0..canyon.depth_m.to_i)
            },
            'attributes' => {
              'access_type' => ['ledge', 'cave', 'slope'].sample
            }
          }
        )
      end
    end
  end
end