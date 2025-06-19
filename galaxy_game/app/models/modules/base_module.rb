module Modules
  class BaseModule < ApplicationRecord
    include AtmosphericProcessing
    
    # Associations
    belongs_to :attachable, polymorphic: true, optional: true

    # Validations
    validates :name, :module_type, :identifier, presence: true

    before_validation :load_module_data, on: :create
    after_create :apply_module_to_attachable
    before_destroy :remove_module_from_attachable

    # Add the identifier attribute
    attribute :identifier, :string

    def operational_status
      operational_data&.dig('operational_status') || 'inactive'
    end

    def input_resources
      operational_data&.dig('input_resources') || []
    end

    def output_resources
      operational_data&.dig('output_resources') || []
    end

    def consumables
      operational_data&.dig('consumables') || {}
    end

    # Method to be called when this module is attached to an attachable (unit or craft)
    def apply_module_to_attachable
      return unless attachable  # If no attachable is attached, return early
      
      # Base functionality: applies the module to the attachable (affects sealing, adds energy cost, etc.)
      attachable.add_module_effect(self)
    end

    # Method to remove this module from the attachable
    def remove_module_from_attachable
      return unless attachable  # If no attachable is attached, return early

      attachable.remove_module_effect(self)
    end

    private

    def load_module_data
      # Return early if module_type is nil or blank
      return if module_type.blank?
      
      @lookup_service ||= Lookup::ModuleLookupService.new
      module_data = @lookup_service.find_module(module_type)
      
      if module_data.present?
        self.name ||= module_data['name']
        self.description ||= module_data['description'] 
        # ✅ FIX: Use ||= for conditional assignment
        self.energy_cost ||= module_data.dig('consumables', 'energy')
        self.maintenance_materials ||= module_data['maintenance']
        self.module_class ||= module_data['module_type']
        self.operational_data ||= module_data
      end
    rescue => e
      # Log the error but don't crash
      Rails.logger.error "Failed to load module data for #{module_type}: #{e.message}"
    end
  end
end