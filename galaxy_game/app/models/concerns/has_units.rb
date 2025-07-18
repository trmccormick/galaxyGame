# app/models/concerns/has_units.rb
module HasUnits
  extend ActiveSupport::Concern

  included do
    # Assuming Craft::BaseCraft already defines this:
    # belongs_to :owner, polymorphic: true
    # validates :owner, presence: true

    has_many :base_units, class_name: 'Units::BaseUnit', as: :attachable, dependent: :destroy
    # Removed `has_many :units` as per previous discussion, use `base_units` directly.
  end

  # This method creates and attaches a new unit from a blueprint ID.
  def add_unit(unit_blueprint_id)
    unit_data = Lookup::UnitLookupService.new.find_unit(unit_blueprint_id.to_s)

    unless unit_data
      errors.add(:base, "Invalid unit blueprint ID or data not found.")
      return "Invalid unit blueprint ID or data not found." # Match test expectation
    end

    # Max units check (if craft.operational_data['max_units'] is present)
    max_units = operational_data.dig('max_units') # Can be nil if not set
    if max_units.present? && base_units.count >= max_units.to_i
      errors.add(:base, "Max units reached for this craft (#{max_units}).")
      return "Max units reached" # Match test expectation
    end

    # Compatibility check (if craft.operational_data['compatible_unit_types'] is present)
    compatible_unit_types = operational_data.dig('compatible_unit_types') # Can be nil if not set
    if compatible_unit_types.present? && !compatible_unit_types.include?(unit_data['id'])
      errors.add(:base, "Unit type '#{unit_data['id']}' is not compatible with this craft.")
      return "Unit type '#{unit_data['id']}' is not compatible with this craft." # Match test expectation
    end

    unit = Units::BaseUnit.new(
      identifier: "#{unit_blueprint_id}_#{SecureRandom.hex(4)}",
      name: unit_data['name'],
      unit_type: unit_data['id'], # Store the blueprint ID as the unit_type
      # Correctly assign the nested 'operational_data' hash directly
      operational_data: unit_data['operational_data'] || {},
      owner: self.owner,
      attachable: self
    )

    if unit.save
      apply_unit_effects(unit)
      return unit # Return the created unit object
    else
      errors.add(:base, "Failed to create and attach unit: #{unit.errors.full_messages.to_sentence}")
      return nil # Return nil on failure
    end
  end

  # This method attaches an *existing* unit to the craft
  # It should be the primary method for attaching units if BaseCraft's was removed.
  def install_unit(unit)
    return false unless unit.is_a?(Units::BaseUnit)

    if unit.attachable == self
      errors.add(:base, "Unit is already attached to this craft.")
      return false
    end

    begin
      if unit.update(attachable: self)
        apply_unit_effects(unit)
        return true
      else
        errors.add(:base, "Failed to install unit: #{unit.errors.full_messages.to_sentence}")
        return false
      end
    rescue => e
      errors.add(:base, "Error installing unit: #{e.message}")
      Rails.logger.error "Error installing unit #{unit.id}: #{e.message}"
      return false
    end
  end

  # This method detaches and destroys a unit from the craft
  # Renamed to `uninstall_unit` for consistency, with an alias for `remove_unit`
  def uninstall_unit(unit)
    return nil unless unit.is_a?(Units::BaseUnit)

    # Check if unit is actually attached to this craft
    unless base_units.exists?(unit.id) # Use exists? for efficient check
      errors.add(:base, "Unit not found or not attached to this object.")
      return nil
    end

    begin
      unit_name = unit.name
      if unit.destroy # This will delete the unit record
        revert_unit_effects(unit)
        return "Unit '#{unit_name}' removed" # Match test expectation
      else
        errors.add(:base, "Failed to remove unit: #{unit.errors.full_messages.to_sentence}")
        return nil
      end
    rescue => e
      errors.add(:base, "Error removing unit: #{e.message}")
      Rails.logger.error "Error removing unit #{unit.id}: #{e.message}"
      return nil
    end
  end

  # Alias for backward compatibility with existing tests
  alias_method :remove_unit, :uninstall_unit

  # This method applies the effects of a unit to the craft
  def apply_unit_effects(unit)
    # Population management is the responsibility of the PopulationManagement concern.
    # Power management is the responsibility of BatteryManagement/EnergyManagement.
    # REMOVED: Power capacity update logic from here.

    # If there are *any* other effects that HasUnits should apply, add them here.
    # Otherwise, this method might become empty or just call recalculate_stats.

    save! # Still needed if any other operational_data changes are made here
    recalculate_stats # Call recalculate_stats if it aggregates other properties
  end

  # This method reverts the effects of a unit when it's removed
  def revert_unit_effects(unit)
    # Population management is the responsibility of the PopulationManagement concern.
    # Power management is the responsibility of BatteryManagement/EnergyManagement.
    # REMOVED: Power capacity revert logic from here.

    # If there are *any* other effects that HasUnits should revert, add them here.

    save! # Still needed if any other operational_data changes are made here
    recalculate_stats
  end

  # Helper method to get the count of installed units
  def installed_units_count
    base_units.count
  end

  # Ensure craft_info returns the operational_data for checks
  def craft_info
    return {} if operational_data.blank?
    operational_data
  end

  # Ensure recalculate_stats is defined if used
  def recalculate_stats
    Rails.logger.debug "Recalculating stats for craft #{id}"
    true # Or perform actual recalculation
  end
end


