class Item < ApplicationRecord
  # Associations
  belongs_to :inventory, optional: true
  belongs_to :container, class_name: "Item", optional: true
  belongs_to :owner, polymorphic: true
  belongs_to :storage_unit, polymorphic: true, optional: true

  has_many :contained_items, class_name: "Item", 
           foreign_key: "container_id", 
           dependent: :destroy

  # Validations  
  validates :name, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }, 
            unless: :is_container?
  validates :storage_method, presence: true
  validate :validate_storage_location
  validate :validate_item_exists
  validates :durability, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_validation :set_item_attributes, on: :create
  
  def degrade(amount)
    return if durability.nil?
    self.durability -= amount
    self.durability = 0 if durability.negative?
    save!
  end

  def properties
    @properties ||= fetch_item_properties
  end

  def material_properties
    return @material_properties if @material_properties

    if name == "Regolith" && metadata["source_body"].present?
      Rails.logger.debug "Looking for CelestialBody with identifier: #{metadata["source_body"]}"
      body = ::CelestialBodies::CelestialBody.find_by(identifier: metadata["source_body"])
      Rails.logger.debug "Found CelestialBody: #{body.inspect}"
      return {} unless body&.geosphere&.crust_composition
  
      @material_properties = {
        "name" => "#{body.name} Regolith",
        "composition" => body.geosphere.crust_composition,
        "source" => body.name
      }
    else
      lookup_service = Lookup::ItemLookupService.new
      @material_properties = lookup_service.find_item(name)
    end
    
    @material_properties || {}
  end

  def container?
    properties&.dig('type') == 'container'
  end
  alias_method :is_container?, :container?

  def stackable?
    !equipment? && !is_container?
  end

  def equipment?
    properties&.dig('type') == 'equipment'
  end

  def total_weight
    # Base weight for all items
    base_weight = properties&.dig('weight', 'amount').to_i * amount

    if container?
      # For containers, add contained items' weights
      contained_items.inject(base_weight) { |sum, item| sum + item.total_weight }
    else
      base_weight
    end
  end  

  def add_item(item)
    raise "Cannot add items to a non-container item." unless container?
    
    # Calculate new total weight including the new item
    new_total = contained_items.sum(&:total_weight) + item.total_weight
    capacity = properties['capacity_kg'].to_i
    
    if new_total > capacity
      raise "Cannot add item: Exceeds container weight capacity."
    end
  
    # If we get here, weight is ok
    item.update!(container: self, inventory: nil)
    contained_items.reload
  end  

  # Remove an item from this container
  def remove_item(item)
    raise "Item not found in this container." unless contained_items.include?(item)
    
    # Return item to container's inventory
    item.update!(container: nil, inventory: self.inventory)
  end

  # Check if an item is available for trade
  def tradeable?
    return false if equipment? && equipped?  # Can't trade equipped items
    return false if quest_item?             # Can't trade quest items
    return false if amount.zero?            # Can't trade zero quantity
    return false if container? && !empty?   # Can't trade containers with items
    true
  end

  def equipped?
    # TODO: Implement equipment system
    false
  end

  def quest_item?
    properties&.dig('flags', 'quest_item') || false
  end

  def empty?
    contained_items.empty?
  end

  def container?
    properties&.dig('type') == 'container'
  end

  # Add quantity to an item (inventory management)
  def add_quantity(amount)
    return unless can_store?(amount)
    increment!(:amount, amount)
  end

  # Remove quantity from an item (inventory management)
  def remove_quantity(amount)
    return false if amount > self.amount
    decrement!(:amount, amount)
    true
  end

  # Check if the quantity of an item is sufficient
  def available?(amount)
    stackable? ? self.amount >= amount : self.amount.positive?
  end

  def can_store?(additional_amount)
    return false unless stackable?
    max_stack = properties&.dig('stack_limit') || Float::INFINITY
    (amount + additional_amount) <= max_stack
  end

  def stackable_with?(other_item)
    return false unless stackable?
    return false unless name == other_item.name
    return false unless material_type == other_item.material_type
    
    # For processed materials, check composition matches
    if name.start_with?('Processed')
      my_comp = metadata['composition']
      other_comp = other_item.metadata['composition']
      return my_comp == other_comp
    end
    
    true
  end

  def process_regolith!(temperature, efficiency = 1.0)
    return unless name.end_with?('Regolith')
    
    original_comp = material_properties['smelting_output']
    processed_comp = {}
    extracted = {}

    original_comp.each do |material|
      if material['material'] == 'Oxygen'
        # Extract oxygen based on temperature and efficiency
        extracted['Oxygen'] = material['percentage'] * efficiency
      else
        # Remaining materials stay in processed regolith
        processed_comp[material['material']] = material['percentage']
      end
    end

    # Create new processed regolith item
    processed = Item.create!(
      name: "Processed Regolith",
      amount: self.amount,
      material_type: :processed_material,
      storage_method: :bulk_storage,
      owner: self.owner,
      inventory: self.inventory,
      metadata: {
        'composition' => processed_comp,
        'origin_material' => self.name,
        'processing_temperature' => temperature,
        'processing_efficiency' => efficiency
      }
    )

    # Create extracted oxygen item
    if extracted['Oxygen'].positive?
      Item.create!(
        name: "Oxygen",
        amount: (self.amount * extracted['Oxygen'] / 100.0).round(2),
        material_type: :gas,
        storage_method: :pressurized_storage,
        owner: self.owner,
        inventory: self.inventory
      )
    end

    # Remove original regolith
    self.destroy
  end

  def process_regolith!(processor)
    return unless name == "Regolith"
    return unless metadata["source_body"].present?
    
    body = ::CelestialBodies::CelestialBody.find_by(identifier: metadata["source_body"])
    return unless body&.geosphere&.crust_composition

    processor.process_material(
      amount: amount,
      composition: body.geosphere.crust_composition,
      temperature: processor.temperature,
      pressure: processor.pressure
    )
  end

  private

  def fetch_item_properties
    return {} unless name
    # Try regular items first
    item_data = Lookup::ItemLookupService.new.find_item(name)
    return item_data if item_data.present?

    # If not found, check if it's a blueprint byproduct
    if name.end_with?("Scrap") || name.start_with?("Used")
      Blueprint::MaterialGenerator.generate_material({
        "material": name,
        "description": "Byproduct from manufacturing process",
        "weight_per_unit": weight_per_unit_for_scrap(name)
      })
    end
  end

  def weight_per_unit_for_scrap(name)
    case name
    when /Steel Scrap/ then 2.0
    when /Copper Scrap/ then 1.0
    when /Circuit Boards/ then 0.5
    when /Used Platinum Catalyst/ then 0.001
    when /Carbon Fiber Scrap/ then 0.5
    else 1.0
    end
  end

  def fetch_material_properties
    return {} unless name
    Lookup::MaterialLookupService.new.find_material(name) || {}
  end

  def set_item_attributes
    self.material_type ||= properties&.dig('type') || material_properties['type']
    self.storage_method ||= properties.dig('storage', 'method') || :bulk_storage
  end

  def validate_item_exists
    return if properties.present? || material_properties.present?
    errors.add(:name, "must be a valid item or material")
  end

  def validate_storage_location
    return true if inventory.present?
    return true if container.present?
    return true if storage_unit.present?
    
    errors.add(:base, "Item must be in an inventory, container, or storage unit")
  end
end

