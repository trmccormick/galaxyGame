# app/models/celestial_bodies/features/base_feature.rb
module CelestialBodies
  module Features
    class BaseFeature < ApplicationRecord
      self.table_name = 'adapted_features'
      
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      belongs_to :parent_feature, class_name: 'CelestialBodies::Features::BaseFeature', optional: true
      has_many :child_features, class_name: 'CelestialBodies::Features::BaseFeature', foreign_key: :parent_feature_id, dependent: :destroy

      has_one :worldhouse, 
              class_name: 'Structures::Worldhouse',
              foreign_key: :geological_feature_id,
              dependent: :nullify
      
      validates :feature_id, presence: true
      validates :feature_type, presence: true
      validates :status, presence: true
      
      # Statuses
      VALID_STATUSES = %w[natural surveyed enclosed pressurized settlement_established].freeze
      validates :status, inclusion: { in: VALID_STATUSES }
      
      # Helper to fetch static data from database column or lookup service
      def static_data
        return super if super.present? # Use database column if present
        
        @static_data ||= begin
          return nil unless celestial_body
          Lookup::PlanetaryGeologicalFeatureLookupService
            .new(celestial_body)
            .find_by_id(feature_id)
        end
      end
      
      # Reload static data cache
      def reload_static_data
        @static_data = nil
        static_data
      end
      
      # Common methods all features should have
      def name
        static_data&.dig('name') || feature_id
      end
      
      def coordinates
        static_data&.dig('coordinates') || {}
      end
      
      def tier
        reload_static_data if Rails.env.test?
        static_data&.dig('tier')
      end

      def strategic?
        reload_static_data if Rails.env.test?
        tier == 'strategic'
      end

      def catalog?
        reload_static_data if Rails.env.test?
        tier == 'catalog'
      end
      
      def discovered?
        static_data&.dig('discovered') || discovered_by.present?
      end
      
      # Status helpers
      def natural?
        status == 'natural'
      end
      
      def surveyed?
        status == 'surveyed'
      end
      
      def enclosed?
        status == 'enclosed'
      end
      
      def pressurized?
        status == 'pressurized'
      end
      
      def has_settlement?
        status == 'settlement_established'
      end
      
      # Mark as discovered
      def discover!(player_id)
        return if discovered_by.present?
        
        update!(
          discovered_by: player_id,
          discovered_at: Time.current,
          status: 'surveyed'
        )
      end
      
      # Survey the feature (collect detailed data)
      def survey!
        update!(status: 'surveyed') if natural?
      end
      
      # Mark as enclosed (openings sealed/covered)
      def enclose!
        return false unless surveyed?
        update(status: 'enclosed', adapted_at: Time.current)
      end
      
      # Pressurize the feature
      def pressurize!
        return false unless enclosed?
        update(status: 'pressurized', adapted_at: Time.current)
      end
      
      # Establish settlement
      def establish_settlement!(settlement_id)
        return false unless pressurized?
        update(
          status: 'settlement_established',
          settlement_id: settlement_id,
          adapted_at: Time.current
        )
      end

      # Check if this feature can support a worldhouse
      def worldhouse_suitable?
        return false unless is_a?(Valley) || is_a?(Canyon)
        return false unless conversion_suitability
        
        suitability = conversion_suitability['pressurized_valley_section'] ||
                     conversion_suitability['worldhouse']
        
        suitability.in?(['excellent', 'good'])
      end
      
      # Convert this feature to a worldhouse structure
      def convert_to_worldhouse!(owner:, settlement:)
        return { success: false, error: 'Not suitable' } unless worldhouse_suitable?
        return { success: false, error: 'Already has worldhouse' } if worldhouse.present?
        
        # Create the worldhouse structure
        wh = Structures::Worldhouse.create!(
          name: "#{name} Worldhouse",
          geological_feature: self,
          owner: owner,
          settlement: settlement,
          celestial_body: celestial_body
        )
        
        # Initialize segments based on feature data
        initialize_segments_for(wh)
        
        { success: true, worldhouse: wh }
      end
      
      private
      
      def initialize_segments_for(worldhouse)
        # Override in specific feature types
        segments = calculate_construction_segments
        
        worldhouse.update!(total_segments: segments.length)
        
        segments.each_with_index do |seg_data, idx|
          Structures::WorldhouseSegment.create!(
            worldhouse: worldhouse,
            segment_index: idx,
            name: seg_data[:name],
            length_m: seg_data[:length_m],
            width_m: seg_data[:width_m],
            status: 'planned'
          )
        end
      end
      
      def calculate_construction_segments
        # Default: 10km segments
        return [] unless respond_to?(:length_m) && length_m
        
        segment_length = 10_000
        num_segments = (length_m / segment_length).ceil
        
        (0...num_segments).map do |i|
          {
            name: "Segment #{i + 1}",
            length_m: [segment_length, length_m - (i * segment_length)].min,
            width_m: respond_to?(:width_m) ? width_m : 1000
          }
        end
      end
    end
  end
end