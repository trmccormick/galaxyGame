module HasStorage
  extend ActiveSupport::Concern

  included do
    has_one :inventory, as: :inventoryable, dependent: :destroy
    after_create :create_inventory
    after_initialize :initialize_storage, if: -> { 
      operational_data.blank? || !operational_data.key?('capacity')
    }
    delegate :storage_capacity, :storage_capacity_by_type, to: :storage_manager
  end

  def storage_manager
    @storage_manager ||= Storage::StorageManager.new(self)
  end

  def storage_capacity
    return base_units.sum(&:storage_capacity) if respond_to?(:base_units)
    operational_data&.dig('storage', 'capacity') || 0
  end

  def storage_capacity_by_type
    return {} unless respond_to?(:base_units)

    base_units.each_with_object(Hash.new(0)) do |unit, capacities|
      type = unit.storage_type || 'general'
      capacities[type] += unit.storage_capacity
    end
  end

  def available_storage
    storage_capacity - current_total_storage
  end

  def can_store?(material_type, amount)
    return false unless storage_compatible?(material_type)
    
    if respond_to?(:base_units)
      # Find appropriate storage unit
      unit = find_storage_unit_for(material_type)
      return false unless unit
      unit.can_store?(material_type, amount)
    else
      # Direct storage check
      available_storage >= amount
    end
  end

  def store(material_type, amount)
    return false unless can_store?(material_type, amount)
    
    stored = operational_data['resources']['stored']
    stored[material_type] = (stored[material_type] || 0) + amount
    
    update_operational_data('stored', stored)
  end

  def store_item(item)
    unit_type = storage_type_for(item)
    available_unit = find_available_storage_unit(unit_type)
    
    raise StorageError, "No available storage unit" unless available_unit
    available_unit.store(item)
  end

  private

  def storage_compatible?(material_type)
    return true if respond_to?(:base_units) # Let units handle compatibility
    
    compatibility = operational_data&.dig('storage', 'compatibility') || []
    compatibility.include?(material_type)
  end

  def current_storage_of(material_type)
    operational_data&.dig('resources', 'stored', material_type) || 0
  end

  def current_total_storage
    inventory&.used_capacity || 0
  end

  def update_operational_data(key, value)
    update!(operational_data: operational_data.merge(
      'resources' => operational_data['resources'].merge(key => value)
    ))
  end

  def storage_type_for(item)
    case item
    when Craft::BaseCraft then 'hangar'
    when Gas then 'gas_storage'
    else 'item_storage'
    end
  end

  def find_available_storage_unit(type)
    base_units.where(unit_type: type).find_each do |unit|
      return unit if unit.can_store?(item)
    end
    nil
  end

  def find_storage_unit_for(material_type)
    return nil unless respond_to?(:base_units)

    base_units.find do |unit|
      unit.storage_type == material_type_to_storage(material_type) &&
        unit.operational_data&.dig('storage', 'capacity').to_i > 0
    end
  end

  def material_type_to_storage(material_type)
    case material_type.to_s
    when /fuel/, /liquid/ then 'liquid_tank'
    when /gas/ then 'gas_tank'
    else 'general_storage'
    end
  end

  def create_inventory
    build_inventory(capacity: storage_capacity).save!
  end

  def initialize_storage
    return if operational_data&.dig('capacity')  # Don't override if unit has capacity data
    
    base_data = {
      'modules' => {'internal' => [], 'external' => []},
      'rigs' => [],
      'resources' => {
        'stored' => {},
        'production_rate' => nil,
        'consumption_rate' => nil
      },
      'efficiency' => 1.0,
      'temperature' => 20,
      'maintenance_cycle' => 0,
      'storage' => {'type' => nil, 'capacity' => 0}
    }

    self.operational_data = if operational_data.present?
      operational_data.merge(base_data)
    else
      base_data
    end
  end
end