# frozen_string_literal: true

module Logistics
  class Manifest < ApplicationRecord
    self.table_name = 'logistics_manifests'

    enum status: {
      pending: 0,
      in_transit: 1,
      delivered: 2,
      failed: 3
    }

    # manifest_type enum values (stored as integers): import = 0, export = 1
    # Note: Using integer column with manual constants instead of Rails enum for flexibility
    IMPORT_TYPE = 0
    EXPORT_TYPE = 1
    
    def import?
      manifest_type == IMPORT_TYPE
    end

    def export?
      manifest_type == EXPORT_TYPE
    end

    belongs_to :source_settlement, class_name: 'Settlement::BaseSettlement'
    belongs_to :destination_settlement, class_name: 'Settlement::BaseSettlement'

    serialize :items, Array

    validates :manifest_id, presence: true, uniqueness: true
    validates :items, presence: true
    validates :total_items, numericality: { greater_than_or_equal_to: 0 }
    validates :total_cost, numericality: { greater_than_or_equal_to: 0 }
    validates :status, presence: true
    
    # Export-specific validations (only apply to export manifests)
    validate :validate_export_fields_if_export_manifest

    scope :imports, -> { where(manifest_type: IMPORT_TYPE) }
    scope :exports, -> { where(manifest_type: EXPORT_TYPE) }
    
    # Scope for exports in approval workflow
    scope :pending_approval, -> { where(status: 'pending', manifest_type: EXPORT_TYPE) }

    private

    def validate_export_fields_if_export_manifest
      return if import?  # Skip export validations for import manifests
      
      # Export manifests should have estimated_revenue_gcc populated
      errors.add(:estimated_revenue_gcc, "must be present for export manifests") unless estimated_revenue_gcc && estimated_revenue_gcc > 0

      # Export manifests should have total_weight_kg within AstroLift HLT capacity (50 tons)
      if total_weight_kg && total_weight_kg.to_f > 50_000.0
        errors.add(:total_weight_kg, "exceeds AstroLift HLT cargo capacity of 50 metric tons")
      end
    end
  end
end
