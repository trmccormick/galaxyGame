# app/models/craft/transport/cycler.rb
module Craft
  module Transport
    class Cycler < ApplicationRecord
      self.table_name = 'cyclers'
      
      serialize :definition_data, JSON

      attr_accessor :craft_info, :craft_name, :craft_type

      belongs_to :base_craft, class_name: 'Craft::BaseCraft', foreign_key: :base_craft_id, optional: true

      has_many :docked_crafts, class_name: 'Craft::BaseCraft', foreign_key: :docked_at_id
      has_many :scheduled_arrivals, class_name: 'ScheduledArrival', foreign_key: :cycler_id
      has_many :scheduled_departures, class_name: 'ScheduledDeparture', foreign_key: :cycler_id

      validates :cycler_type,      presence: true
      validates :orbital_period,   presence: true

      before_validation :initialize_trajectory, on: :create
      before_validation :set_orbital_period_nil_if_zero

      # load from JSON config and attach modules/units
      def self.create_from_definition(filename)
        data = load_definition(filename) || {}
        cycler = new(
          craft_name:        data['name'],
          craft_type:        'cycler',
          definition_data:   data,
          cycler_type:       data['cycler_type'],
          orbital_period:    data.dig('operational_parameters','transfer_window','period')
        )
        return cycler unless cycler.valid?

        cycler.save!
        create_recommended_modules(cycler)
        create_recommended_units(cycler)
        cycler
      end

      def initialize_trajectory
        self.orbital_period = case cycler_type
        when 'earth_mars'
          780
        when 'earth_venus'
          584
        when 'venus_mars'
          333
        else
          0
        end
      end

      def set_orbital_period_nil_if_zero
        self.orbital_period = nil if orbital_period == 0
      end

      private

      def validate_cycler_requirements
        errors.add(:base, 'Invalid craft type for cycler') unless craft_info.try(:[], 'type') == 'cycler'
      end
    end
  end
end
