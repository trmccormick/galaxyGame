# app/models/concerns/has_rigs.rb
module HasRigs
  extend ActiveSupport::Concern

  included do
    has_many :base_rigs, class_name: 'Rigs::BaseRig', as: :attachable, dependent: :destroy
    alias_method :rigs, :base_rigs
  end

  def add_rig(rig_type)
    rig_data = Lookup::RigLookupService.new.find_rig(rig_type.to_s)

    unless rig_data
      errors.add(:base, "Invalid rig type or data not found.")
      return "Invalid rig type or data not found."
    end

    max_rigs = available_rig_ports
    if max_rigs.present? && base_rigs.count >= max_rigs.to_i
      errors.add(:base, "Max rigs reached for this craft (#{max_rigs}).")
      return "Max rigs reached for this craft (#{max_rigs})"
    end

    rig_obj = Rigs::BaseRig.new(
      identifier: "#{rig_type}_#{SecureRandom.hex(4)}",
      name: rig_data['name'] || rig_type.humanize,
      rig_type: rig_type,
      capacity: rig_data['capacity'] || 100,
      description: rig_data['description'] || "#{rig_type} description",
      operational_data: rig_data,
      attachable: self
    )

    if rig_obj.save
      apply_rig_effects(rig_obj)
      return rig_obj
    else
      errors.add(:base, "Failed to create and attach rig: #{rig_obj.errors.full_messages.to_sentence}")
      return "Failed to create rig: #{rig_obj.errors.full_messages.join(', ')}"
    end
  end

  def remove_rig(rig_type)
    rig_obj = base_rigs.find_by(rig_type: rig_type)
    return "Rig not found" unless rig_obj

    begin
      revert_rig_effects(rig_obj)
      rig_obj.destroy
      return rig_obj.destroyed? ? "Rig removed" : "Failed to remove rig"
    rescue => e
      Rails.logger.error "Error removing rig #{rig_obj.id}: #{e.message}"
      return "Error removing rig: #{e.message}"
    end
  end

  def apply_rig_effects(rig_obj)
    return false unless rig_obj&.operational_data

    rig_effects = rig_obj.operational_data.dig('effects') || []
    
    rig_effects.each do |effect|
      case effect['type']
      when 'processing_boost'
        apply_processing_boost_effect(effect)
      when 'mining_boost'
        apply_mining_boost_effect(effect)
      end
    end

    # Track applied effects
    self.operational_data ||= {}
    self.operational_data['active_rig_effects'] ||= []
    self.operational_data['active_rig_effects'] << {
      'rig_id' => rig_obj.id,
      'rig_type' => rig_obj.rig_type,
      'effects' => rig_effects
    }

    save if respond_to?(:save)
  end

  def revert_rig_effects(rig_obj)
    return false unless operational_data&.dig('active_rig_effects')

    # Find and remove the rig's effects
    effect_entry = operational_data['active_rig_effects'].find { |e| e['rig_id'] == rig_obj.id }
    return false unless effect_entry

    effect_entry['effects'].each do |effect|
      case effect['type']
      when 'processing_boost'
        revert_processing_boost_effect(effect)
      when 'mining_boost'
        revert_mining_boost_effect(effect)
      end
    end

    # Remove from tracked effects
    operational_data['active_rig_effects'].delete_if { |e| e['rig_id'] == rig_obj.id }
    save if respond_to?(:save)
  end

  def available_rig_ports
    ports_data = get_ports_data if respond_to?(:get_ports_data)
    return 0 unless ports_data
    
    internal = ports_data.dig('internal_rig_ports') || 0
    external = ports_data.dig('external_rig_ports') || 0
    internal + external
  end

  def determine_rig_class(rig_type)
    Rigs::BaseRig
  end

  private

  def apply_processing_boost_effect(effect)
    boost_multiplier = effect.dig('parameters', 'boost_multiplier') || 1.0
    
    if respond_to?(:operational_data) && operational_data
      self.operational_data['processing_effects'] ||= {}
      current_multiplier = self.operational_data['processing_effects']['boost_multiplier'] || 1.0
      self.operational_data['processing_effects']['boost_multiplier'] = current_multiplier * boost_multiplier
    end
  end

  def revert_processing_boost_effect(effect)
    # Revert processing boost
    boost_multiplier = effect['boost_multiplier'] || 1.0
    
    if respond_to?(:operational_data) && operational_data&.dig('processing_effects')
      current = self.operational_data['processing_effects']['boost_multiplier'] || 1.0
      self.operational_data['processing_effects']['boost_multiplier'] = current / boost_multiplier
    end
  end

  def apply_mining_boost_effect(effect)
    boost_gcc_per_hour = effect.dig('parameters', 'boost_gcc_per_hour') || 0
    
    if respond_to?(:operational_data) && operational_data
      self.operational_data['mining_effects'] ||= {}
      current_boost = self.operational_data['mining_effects']['boost_gcc_per_hour'] || 0
      self.operational_data['mining_effects']['boost_gcc_per_hour'] = current_boost + boost_gcc_per_hour
    end
  end

  def revert_mining_boost_effect(effect)
    boost_gcc_per_hour = effect.dig('parameters', 'boost_gcc_per_hour') || 0
    
    if respond_to?(:operational_data) && operational_data&.dig('mining_effects')
      current_boost = self.operational_data['mining_effects']['boost_gcc_per_hour'] || 0
      self.operational_data['mining_effects']['boost_gcc_per_hour'] = current_boost - boost_gcc_per_hour
    end
  end
end
