# app/models/craft/transport/base_transport.rb
module Craft
  module Transport
    class BaseTransport < Craft::BaseCraft
      include Docking
      include LifeSupport
      include EnergyManagement

      has_many :docked_crafts,
               class_name: 'Craft::BaseCraft',
               foreign_key: :docked_at_id,
               inverse_of: :docked_at,
               dependent: :nullify

      has_many :units,   as: :attachable, class_name: 'Units::BaseUnit',   dependent: :destroy
      has_many :modules, as: :attachable, class_name: 'Modules::BaseModule', dependent: :destroy
      has_many :rigs,    as: :attachable, class_name: 'Rigs::BaseRig',       dependent: :destroy

      validates :craft_name, :craft_type, presence: true

      # Common transport‐level methods
      def embark_unit(unit)
        return false unless can_dock?(unit.owner)
        unit.update!(attachable: self, owner: self)
      end

      def disembark_unit(unit, into:)
        return false unless unit.attachable == self
        unit.update!(attachable: into, owner: into)
      end

      # Tell everyone onboard to return for docking (e.g. low battery, end of mission)
      def recall_units!
        units.each { |u| u.assign_task(:return_to_craft, craft_id: self.id) }
      end
    end
  end
end
