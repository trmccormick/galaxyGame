# app/models/settlement/space_station.rb
module Settlement
  class SpaceStation < BaseSettlement
    include LifeSupport
    include Docking
    include Structures::Shell
    
    has_many :storage_units, class_name: 'Units::BaseUnit', as: :attachable
    has_many :docked_crafts, class_name: 'Craft::BaseCraft', foreign_key: :docked_at_id, inverse_of: :docked_at, dependent: :destroy
    has_one :atmosphere, as: :structure, dependent: :destroy
    
    # Shell construction attributes
    attribute :construction_start_date, :datetime
    
    validates :settlement_type, inclusion: { in: %w[station outpost] }
    
    after_initialize :set_defaults, if: :new_record?
    after_create :initialize_core_systems
    after_update :trigger_shell_callbacks, if: :saved_change_to_operational_data?
    
    # app/models/settlement/space_station.rb
    # RETIRED 2026-04-10
    # Use Settlement::OrbitalSettlement with Structures::OrbitalStructure instead.
    # This file is kept for git history only. Do not use this class.
    
  end
  end
end