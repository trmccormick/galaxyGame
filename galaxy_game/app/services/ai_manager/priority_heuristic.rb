module AIManager
  class PriorityHeuristic
    def initialize(settlement)
      @settlement = settlement
    end

    # Check if O2 levels are below 15% of target
    def oxygen_critical?
      target_o2 = calculate_target_o2
      current_o2 = current_o2_mass
      current_o2 < target_o2 * 0.15
    end

    # Check if N2 levels are below 15% of target
    def nitrogen_critical?
      target_n2 = calculate_target_n2
      current_n2 = current_n2_mass
      current_n2 < target_n2 * 0.15
    end

    # Check if settlement account is negative
    def account_negative?
      @settlement.account&.balance&.negative?
    end

    # Check if corporation has high debt levels
    def corporate_high_debt?
      return false unless @settlement.owner&.is_a?(Organizations::BaseOrganization)
      
      corporation = @settlement.owner
      total_debt = corporation.accounts.sum do |account|
        account.balance.negative? ? account.balance.abs : 0
      end
      
      total_assets = corporation.accounts.sum { |account| [account.balance, 0].max }
      total_debt > total_assets * 0.5
    end

    # Check if methane synthesis is possible and beneficial
    def can_synthesize_methane?
      # Check if CO is available (from production or storage)
      co_available = check_gas_available('CO')
      h2_available = check_gas_available('H2')
      
      co_available && h2_available
    end

    # Check if storage capacity is critically low
    def storage_capacity_critical?
      # Check tank farm capacity - assume < 10% is critical
      tank_capacity = @settlement.operational_data&.dig('tank_farm_capacity').to_f
      tank_capacity < 10.0
    end

    # Get priority actions based on current state
    def get_priorities
      priorities = []

      if oxygen_critical?
        if @settlement.celestial_body.can_generate_locally?(:O2)
          priorities << :local_oxygen_generation
        else
          priorities << :refill_oxygen
        end
      end

      if nitrogen_critical?
        if @settlement.celestial_body.can_generate_locally?(:Ar)
          priorities << :local_argon_extraction
        else
          priorities << :refill_nitrogen
        end
      end

      if account_negative?
        priorities << :debt_repayment
      end

      # Check for methane synthesis opportunity
      if can_synthesize_methane?
        priorities << :methane_synthesis
      end

      # Check for storage capacity constraint
      if storage_capacity_critical?
        priorities << :construct_storage_module
      end

      priorities
    end

    # For debt repayment, calculate ask price for Si with 95% EAP ceiling
    def calculate_si_ask_price
      eap = Market::NpcPriceCalculator.calculate_ask(@settlement, 'Si')
      eap * 0.95
    end

    # Check if storage capacity is critically low
    def storage_capacity_critical?
      # Check tank farm capacity - assume < 10% is critical
      tank_capacity = @settlement.operational_data&.dig('tank_farm_capacity').to_f
      tank_capacity > 0 && tank_capacity < 10.0
    end

    private

    def calculate_target_o2
      # Calculate target O2 mass based on settlement needs
      # This is a placeholder - implement based on settlement population, volume, etc.
      1000.0 # kg, placeholder
    end

    def calculate_target_n2
      # Calculate target N2 mass based on settlement needs
      500.0 # kg, placeholder
    end

    def current_o2_mass
      # Sum O2 from all structures' gas_storage
      total_o2 = 0.0
      Structures::BaseStructure.where(settlement_id: @settlement.id).each do |structure|
        gas_storage = structure.operational_data&.dig('gas_storage') || {}
        total_o2 += gas_storage['oxygen'].to_f
      end
      total_o2
    end

    def current_n2_mass
      # Sum N2 from all structures' gas_storage
      total_n2 = 0.0
      Structures::BaseStructure.where(settlement_id: @settlement.id).each do |structure|
        gas_storage = structure.operational_data&.dig('gas_storage') || {}
        total_n2 += gas_storage['nitrogen'].to_f
      end
      total_n2
    end

    def check_gas_available(gas_name)
      # Check inventory for the gas
      gas_item = @settlement.inventory&.items&.find_by(name: gas_name, material_type: :gas)
      return false unless gas_item
      
      # Consider available if we have at least 100 kg
      gas_item.amount >= 100.0
    end
  end
end