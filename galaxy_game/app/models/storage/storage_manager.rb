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

    def storage_capacity_by_type
      capacities = Hash.new(0)
      
      @owner.base_units.each do |unit|
        next unless unit.operational_data&.dig('storage')
        storage_data = unit.operational_data['storage']
        
        # Handle each storage type directly defined in the storage hash
        storage_data.each do |type, value|
          # Skip special keys
          next if ['type', 'capacity', 'current_level', 'current_contents'].include?(type)
          capacities[type.to_sym] += value.to_i
        end
      end
      
      Rails.logger.debug "Final capacities: #{capacities.inspect}"
      capacities
    end

    def storage_capacity
      # For backward compatibility, only count liquid and gas
      capacities = storage_capacity_by_type
      capacities[:liquid].to_i + capacities[:gas].to_i
    end

    def total_storage_capacity
      # Sum all storage types
      storage_capacity_by_type.values.sum
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