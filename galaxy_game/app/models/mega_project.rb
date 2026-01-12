class MegaProject < ApplicationRecord
  belongs_to :settlement, class_name: 'Settlement::BaseSettlement'
  belongs_to :project_manager, class_name: 'Player', optional: true

  enum status: { planning: 0, active: 1, paused: 2, completed: 3, failed: 4, cancelled: 5 }
  enum project_type: {
    mars_l1_shield: 0,
    mariana_worldhouse: 1,
    orbital_ring: 2,
    planetary_engine: 3,
    dyson_swarm: 4,
    interstellar_probe: 5
  }

  # Material requirements stored as JSONB
  store :material_requirements, coder: JSON
  store :progress_data, coder: JSON
  store :project_metadata, coder: JSON

  validates :name, presence: true
  validates :project_type, presence: true
  validates :deadline, presence: true
  validates :budget_gcc, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :urgent, -> { where('deadline < ?', 30.days.from_now) }
  scope :by_type, ->(type) { where(project_type: type) }

  # Instance methods
  def urgency_factor
    days_remaining = (deadline - Time.current).to_i / 86400.0
    return 3.0 if days_remaining <= 7   # Critical
    return 2.0 if days_remaining <= 30  # High
    return 1.5 if days_remaining <= 90  # Medium
    1.0 # Normal
  end

  def completion_percentage
    return 100.0 if status == 'completed'

    total_required = material_requirements.values.sum.to_f
    total_delivered = progress_data.fetch('delivered_materials', {}).values.sum.to_f

    total_required > 0 ? (total_delivered / total_required * 100).to_f : 0.0
  end

  def materials_needed
    requirements = material_requirements || {}
    delivered = progress_data.fetch('delivered_materials', {})

    requirements.each_with_object({}) do |(material, required), needed|
      delivered_qty = delivered.fetch(material, 0).to_f
      needed[material] = [required.to_f - delivered_qty, 0].max
    end
  end

  def overdue?
    deadline < Time.current && status != 'completed'
  end

  def budget_remaining
    spent = progress_data.fetch('budget_spent', 0).to_f
    budget_gcc - spent
  end

  # Class methods
  def self.generate_buy_orders
    active.each do |project|
      project.generate_buy_orders
    end
  end

  def generate_buy_orders
    materials_needed.each do |material, quantity|
      next if quantity <= 0

      # Calculate dynamic price based on urgency and local supply
      base_price = Market::NpcPriceCalculator.calculate_ask(settlement, material) || 10.0
      urgency_multiplier = urgency_factor
      supply_penalty = calculate_supply_penalty(material)

      final_price = (base_price * urgency_multiplier * supply_penalty).round(2)

      # Create or update buy order
      Market::DemandService.create_project_buy_order(
        project: self,
        material: material,
        quantity: quantity,
        price_per_unit: final_price
      )
    end
  end

  private

  def calculate_supply_penalty(material)
    # Check local settlement inventory
    local_supply = settlement.inventory.current_storage_of(material)
    required = material_requirements[material].to_f

    return 1.5 if local_supply <= 0                    # No supply = 50% penalty
    return 1.2 if local_supply < (required * 0.1)     # Low supply = 20% penalty
    return 1.1 if local_supply < (required * 0.5)     # Medium supply = 10% penalty
    1.0 # Normal supply
  end
end