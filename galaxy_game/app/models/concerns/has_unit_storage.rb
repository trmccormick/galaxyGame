module HasUnitStorage
  extend ActiveSupport::Concern

  included do
    has_many :base_units, 
             class_name: 'Units::BaseUnit',
             as: :attachable,
             dependent: :destroy

    has_one :inventory, as: :inventoryable, dependent: :destroy
    has_many :items, through: :inventory

    delegate :storage_capacity, :storage_capacity_by_type, to: :storage_manager
  end

  def storage_manager
    @storage_manager ||= Storage::StorageManager.new(self)
  end

  def storage_capacity_by_type
    capacities = Hash.new(0)
    
    base_units.each do |unit|
      next unless unit.operational_data&.dig('storage')
      
      unit.operational_data['storage'].each do |type, capacity|
        next if type == 'capacity' || type == 'current_contents'
        capacities[type.to_sym] += capacity.to_i
      end
    end
    
    capacities
  end

  def collect_materials
    Rails.logger.debug "Starting collect_materials"
    Rails.logger.debug "Initial inventory items: #{inventory&.items&.count}"
    
    ensure_inventory
    
    base_units.each do |unit|
      Rails.logger.debug "Processing unit: #{unit.name}"
      Rails.logger.debug "Unit operational data: #{unit.operational_data.inspect}"
      
      next unless unit.operational_data&.dig('resources', 'stored')
      stored = unit.operational_data['resources']['stored']
      next if stored.empty?
      
      Rails.logger.debug "Found stored items: #{stored.inspect}"
      
      stored.each do |item_id, amount|
        next if amount <= 0
        
        Rails.logger.debug "Creating item: #{item_id} amount: #{amount}"
        
        # Create or update inventory item
        item = inventory.items.create!(
          name: item_id,
          amount: amount,
          owner: owner || self
        )
        
        # Clear storage in unit
        stored[item_id] = 0
        unit.operational_data['storage']['current_level'] = 0
      end
      
      unit.save!
    end
    
    inventory.reload
    Rails.logger.debug "Final inventory items: #{inventory.items.count}"
    true
  end

  def process_materials
    base_units.each do |unit|
      unit.process_materials(inventory)
    end
  end

  def update_inventory(collected_materials)
    return unless inventory && collected_materials.present?
    
    collected_materials.each do |material, amount|
      item = inventory.items.find_or_initialize_by(name: material)
      item.amount = (item.amount || 0) + amount
      item.save!
    end
  end

  def ensure_inventory
    create_inventory unless inventory
  end
end