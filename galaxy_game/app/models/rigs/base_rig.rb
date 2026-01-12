module Rigs
  class BaseRig < ApplicationRecord
    belongs_to :attachable, polymorphic: true, optional: true

    validates :name, presence: true
    validates :description, presence: true
    validates :rig_type, presence: true
    validates :capacity, presence: true, numericality: { greater_than_or_equal_to: 0 }

    after_initialize :load_rig_data

    attribute :identifier, :string

    def operational_data
      self[:operational_data] || {}
    end

    def apply_rig_to_attachable
      apply_effects
    end

    def remove_rig_from_attachable
      remove_from
    end

    def self.load_from_json(rig_type)
      rig_lookup_service = Lookup::RigLookupService.new
      data = rig_lookup_service.find_rig(rig_type)

      return nil if data.blank?

      new(
        name: data['name'],
        description: data['description'] || "#{data['name']} description",
        rig_type: rig_type,
        capacity: data['capacity'] || 100,
        operational_data: data
      )
    end

    def apply_to(attachable)
      update(attachable: attachable)
      apply_effects
    end

    def apply_effects
      return false unless attachable

      apply_consumable_effects if operational_data['consumables']
      apply_output_effects     if operational_data['output_resources']
      apply_damage_effects     if operational_data['damage_risk']

      true
    end

    def remove_from
      return false unless attachable

      revert_effects(attachable)
      update(attachable: nil)
      destroy
      true
    end

    def revert_effects(target = nil)
      target ||= attachable
      return false unless target

      revert_consumable_effects(target) if operational_data['consumables']
      revert_output_effects(target)     if operational_data['output_resources']
      revert_damage_effects(target)     if operational_data['damage_risk']

      true
    end

    def process_tick(time_skipped = 1)
      # No-op for base class, override in subclasses.
    end

    private

    def load_rig_data
      return if rig_type.blank? || operational_data.present?

      rig_lookup_service = Lookup::RigLookupService.new
      data = rig_lookup_service.find_rig(rig_type)
      self.operational_data = data if data.present?
    end

    def apply_consumable_effects
      return unless attachable.respond_to?(:update_consumables)

      operational_data['consumables'].each do |resource, amount|
        attachable.update_consumables(resource, amount)
      end
    end

    def revert_consumable_effects(target)
      return unless target.respond_to?(:update_consumables)

      operational_data['consumables'].each do |resource, amount|
        target.update_consumables(resource, -amount)
      end
    end

    def apply_output_effects
      return unless attachable.respond_to?(:update_outputs)

      operational_data['output_resources'].each do |resource|
        attachable.update_outputs(resource['id'], resource['amount'])
      end
    end

    def revert_output_effects(target)
      return unless target.respond_to?(:update_outputs)

      operational_data['output_resources'].each do |resource|
        target.update_outputs(resource['id'], -resource['amount'])
      end
    end

    def apply_damage_effects
      return unless attachable.respond_to?(:update_damage_risks)

      operational_data['damage_risk'].each do |risk_type, amount|
        attachable.update_damage_risks(risk_type, amount)
      end
    end

    def revert_damage_effects(target)
      return unless target.respond_to?(:update_damage_risks)

      operational_data['damage_risk'].each do |risk_type, amount|
        target.update_damage_risks(risk_type, -amount)
      end
    end
  end
end
