# app/services/manufacturing/assembly_service.rb
module Manufacturing
  class AssemblyService
    # Result object for assembly operations
    class AssemblyResult
      attr_accessor :success, :job, :errors, :missing_materials, :tenant_fee, :material_costs

      def initialize
        @success = false
        @errors = []
        @missing_materials = []
        @material_costs = {}
        @tenant_fee = 0
      end

      def success?
        @success
      end

      def add_error(message)
        @errors << message
        @success = false
      end
    end

    # Start an assembly job for a blueprint at a settlement
    # @param blueprint [Blueprint] The blueprint to assemble
    # @param settlement [Settlement::BaseSettlement] The settlement where assembly occurs
    # @param requester [Player|Organization] The entity requesting the assembly
    # @param buy_missing [Boolean] Whether to buy missing materials from NPC stock
    # @return [AssemblyResult]
    def self.start_assembly(blueprint:, settlement:, requester:, buy_missing: false)
      result = AssemblyResult.new

      # Validate inputs
      unless blueprint.is_a?(Blueprint)
        result.add_error("Invalid blueprint")
        return result
      end

      unless settlement.is_a?(Settlement::BaseSettlement)
        result.add_error("Invalid settlement")
        return result
      end

      # Get blueprint specifications
      blueprint_data = Lookup::BlueprintLookupService.new.find_blueprint(blueprint.name)
      unless blueprint_data
        result.add_error("Blueprint data not found for #{blueprint.name}")
        return result
      end

      # Check material availability
      material_check = check_material_availability(blueprint_data, settlement, requester)
      result.missing_materials = material_check[:missing]
      result.material_costs = material_check[:costs]

      # If materials are missing and not buying, fail
      if result.missing_materials.any? && !buy_missing
        result.add_error("Missing materials: #{result.missing_materials.keys.join(', ')}")
        return result
      end

      # Calculate tenant fee
      result.tenant_fee = calculate_tenant_fee(blueprint_data)

      # Check if requester can afford tenant fee
      unless can_afford_fee?(requester, result.tenant_fee)
        result.add_error("Cannot afford tenant fee of #{result.tenant_fee} GCC")
        return result
      end

      # Buy missing materials if requested
      if buy_missing && result.missing_materials.any?
        buy_result = buy_missing_materials(result.missing_materials, result.material_costs, settlement, requester)
        unless buy_result[:success]
          result.add_error("Failed to buy materials: #{buy_result[:error]}")
          return result
        end
      end

      # Create the assembly job
      job = create_assembly_job(blueprint, blueprint_data, settlement, requester)
      unless job
        result.add_error("Failed to create assembly job")
        return result
      end

      # Charge tenant fee
      charge_tenant_fee(settlement, requester, result.tenant_fee)

      result.job = job
      result.success = true
      result
    end

    private

    # Check which materials are available in settlement inventory
    def self.check_material_availability(blueprint_data, settlement, requester)
      required_materials = blueprint_data['required_materials'] || {}
      missing = {}
      costs = {}

      required_materials.each do |material_name, requirements|
        required_amount = requirements['amount'] || 0
        available_amount = settlement.inventory.items.where(
          name: material_name,
          owner: requester
        ).sum(:amount)

        if available_amount < required_amount
          amount_needed = required_amount - available_amount
          missing[material_name] = amount_needed
          # Calculate FMV cost for missing amount
          costs[material_name] = calculate_fmv_cost(material_name, amount_needed, settlement)
        end
      end

      { missing: missing, costs: costs }
    end

    # Calculate Fair Market Value cost for a material
    def self.calculate_fmv_cost(material_name, amount, settlement)
      # Use market service to get current prices
      price_per_unit = Market::NpcPriceCalculator.calculate_ask(settlement, material_name) || 0
      price_per_unit * amount
    end

    # Calculate tenant fee based on blueprint complexity
    def self.calculate_tenant_fee(blueprint_data)
      build_time = blueprint_data.dig('production_data', 'build_time_hours') || 1
      material_count = blueprint_data.dig('required_materials')&.size || 1

      # Base fee of 10 GCC, plus 1 GCC per hour and per material
      10 + build_time + material_count
    end

    # Check if requester can afford the fee
    def self.can_afford_fee?(requester, amount)
      account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: requester,
        currency: Financial::Currency.find_by!(symbol: 'GCC')
      )
      account.balance >= amount
    end

    # Buy missing materials from NPC stock
    def self.buy_missing_materials(missing_materials, costs, settlement, requester)
      total_cost = costs.values.sum

      unless can_afford_fee?(requester, total_cost)
        return { success: false, error: "Cannot afford material costs of #{total_cost} GCC" }
      end

      # Create transactions for each material
      currency = Financial::Currency.find_by!(symbol: 'GCC')
      settlement_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: settlement,
        currency: currency
      )
      requester_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: requester,
        currency: currency
      )

      missing_materials.each do |material_name, amount_needed|
        cost = costs[material_name]

        if cost > 0
          # Transfer payment
          requester_account.transfer_funds(cost, settlement_account, "Purchase of #{material_name} for assembly")
        end

        # Add material to settlement inventory
        settlement.inventory.items.create!(
          name: material_name,
          amount: amount_needed,
          owner: requester,
          material_type: :raw_material # This should be determined properly
        )
      end

      { success: true }
    end

    # Create the appropriate assembly job
    def self.create_assembly_job(blueprint, blueprint_data, settlement, requester)
      job_type = determine_job_type(blueprint_data)

      case job_type
      when :unit_assembly
        create_unit_assembly_job(blueprint, blueprint_data, settlement, requester)
      when :construction
        create_construction_job(blueprint, blueprint_data, settlement, requester)
      else
        nil
      end
    end

    # Determine what type of job this blueprint represents
    def self.determine_job_type(blueprint_data)
      category = blueprint_data['category']

      case category
      when 'units', 'craft'
        :unit_assembly
      when 'structures', 'facilities'
        :construction
      else
        :construction # Default fallback
      end
    end

    # Create a unit assembly job
    def self.create_unit_assembly_job(blueprint, blueprint_data, settlement, requester)
      UnitAssemblyJob.create!(
        base_settlement: settlement,
        owner: requester,
        unit_type: blueprint_data['id'] || blueprint.name.downcase.gsub(' ', '_'),
        count: 1,
        status: :materials_pending,
        priority: :normal
      )
    end

    # Create a construction job
    def self.create_construction_job(blueprint, blueprint_data, settlement, requester)
      ConstructionJob.create!(
        jobable: settlement,
        blueprint: blueprint,
        settlement: settlement,
        job_type: :structure_upgrade, # Default, should be determined from blueprint
        status: :materials_pending,
        target_values: {
          'build_time_hours' => blueprint_data.dig('production_data', 'build_time_hours') || 1
        }
      )
    end

    # Charge tenant fee to requester and credit to settlement
    def self.charge_tenant_fee(settlement, requester, amount)
      currency = Financial::Currency.find_by!(symbol: 'GCC')

      settlement_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: settlement,
        currency: currency
      )
      requester_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: requester,
        currency: currency
      )

      # Don't charge if accounts are the same (e.g., settlement delegates to owner)
      return if requester_account.id == settlement_account.id

      requester_account.transfer_funds(amount, settlement_account, "Tenant fee for factory usage")
    end
  end
end