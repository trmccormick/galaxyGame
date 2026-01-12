module Storage
  class StorageManager
    def initialize(owner)
      @owner = owner
    end

    def store(item_id, quantity)
      raise ArgumentError, "Item ID cannot be nil" if item_id.nil?
      raise ArgumentError, "Quantity must be positive" if quantity <= 0

      item = lookup_item(item_id)
      storage_type = determine_storage_type(item)
      
      if surface_storable?(item)
        surface_store(item_id, quantity)
      else
        unit_store(storage_type, item_id, quantity)
      end
    end

    def can_store?(item_id, quantity)
      return false if quantity.negative?
      
      item = lookup_item(item_id)
      storage_type = determine_storage_type(item)
      
      if surface_storable?(item)
        true  # Surface storage has no capacity limit
      else
        available_capacity_for(storage_type) >= quantity
      end
    end

    def storage_capacity
      @owner.base_units.sum do |unit|
        next 0 unless unit.operational_data.present? && unit.operational_data['storage'].present?
        unit.operational_data['storage']['capacity'] || 0
      end
    end

    def storage_capacity_by_type
      capacities = { liquid: 0, solid: 0, gas: 0, multi: 0 }
      
      @owner.base_units.each do |unit|
        next unless unit.operational_data.present? && unit.operational_data['storage'].present?
        
        storage_data = unit.operational_data['storage']
        type = storage_data['type']&.to_sym || :solid
        capacity = storage_data['capacity'] || 0
        
        capacities[type] += capacity if capacities.key?(type)
      end
      
      capacities
    end

    private

    def lookup_item(item_id)
      Lookup::ItemLookupService.new.find_item(item_id)
    end

    def surface_storable?(item)
      ['raw_material', 'ore', 'regolith', 'waste'].include?(item.type)
    end

    def determine_storage_type(item)
      case item.type
      when 'gas' then 'gas_storage'
      when 'liquid' then 'liquid_storage'
      when 'craft' then 'hangar'
      else 'item_storage'
      end
    end

    def available_capacity_for(type)
      @owner.base_units.where(unit_type: type).sum(&:available_capacity)
    end

    def find_storage_unit(type)
      @owner.base_units.where(unit_type: type).find_each do |unit|
        return unit if unit.available_storage > 0
      end
      nil
    end
  end
end