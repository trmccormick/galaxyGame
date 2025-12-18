module CelestialBodies
  module Features
    # Generic model for tracking adaptation/gameplay state for any feature
    class AdaptedFeature < ApplicationRecord
      belongs_to :celestial_body, class_name: 'CelestialBodies::CelestialBody'
      validates :feature_id, presence: true
      validates :feature_type, presence: true

      # Dynamic/gameplay state
      attribute :status, :string, default: 'natural' # e.g., natural, enclosed, settlement_established
      attribute :adapted_at, :datetime
      attribute :settlement_id, :integer
      attribute :discovered_by, :integer

      # Helper to fetch static data
      def static_data
        Lookup::PlanetaryGeologicalFeatureLookupService
          .new(celestial_body)
          .find_by_id(feature_id)
      end

      def name
        static_data&.dig('name')
      end

      def coordinates
        static_data&.dig('coordinates')
      end

      def feature_specific_data
        static_data
      end
    end
  end
end