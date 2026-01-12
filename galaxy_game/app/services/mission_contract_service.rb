class MissionContractService
  # Service for managing B2B contracts and mission-based transactions

  def self.create_supply_contract(supplier, buyer, resource_name, quantity, delivery_terms = {})
    # Create a supply contract between two entities
    requirements = {
      'resource' => resource_name,
      'quantity' => quantity,
      'delivery_location' => delivery_terms['location'] || buyer.location_name,
      'deadline' => delivery_terms['deadline'] || 30.days.from_now
    }

    reward = calculate_supply_reward(supplier, buyer, resource_name, quantity, delivery_terms)

    MissionContract.create!(
      mission_id: "supply_#{resource_name}_#{SecureRandom.hex(4)}",
      name: "Supply Contract: #{quantity}kg #{resource_name}",
      description: "#{supplier.name} to supply #{quantity}kg of #{resource_name} to #{buyer.name}",
      requirements: requirements,
      reward: reward,
      offered_by: supplier,
      status: :open,
      operational_data: {
        'contract_type' => 'supply',
        'supplier_id' => supplier.id,
        'buyer_id' => buyer.id,
        'terms' => delivery_terms
      }
    )
  end

  def self.create_construction_contract(contractor, client, project_spec, budget = {})
    # Create a construction/service contract
    requirements = {
      'project_spec' => project_spec,
      'completion_deadline' => budget['deadline'] || 90.days.from_now,
      'quality_standards' => project_spec['standards'] || 'standard'
    }

    reward = {
      'type' => 'credits',
      'amount' => budget['amount'] || calculate_project_cost(project_spec),
      'payment_terms' => budget['payment_terms'] || 'completion'
    }

    MissionContract.create!(
      mission_id: "construction_#{SecureRandom.hex(4)}",
      name: "Construction Contract: #{project_spec['name']}",
      description: "#{contractor.name} to complete #{project_spec['name']} for #{client.name}",
      requirements: requirements,
      reward: reward,
      offered_by: client,
      status: :open,
      operational_data: {
        'contract_type' => 'construction',
        'contractor_id' => contractor.id,
        'client_id' => client.id,
        'project_spec' => project_spec
      }
    )
  end

  def self.create_from_profile(profile_json, offered_by)
    profile = JSON.parse(profile_json) if profile_json.is_a?(String)
    manifest = load_manifest(profile["manifest_file"])
    phases = profile["phases"]

    MissionContract.create!(
      mission_id: profile["mission_id"],
      name: profile["name"],
      description: profile["description"],
      requirements: extract_requirements(manifest),
      reward: determine_reward(manifest),
      manifest: manifest,
      phases: phases,
      offered_by: offered_by,
      status: :open
    )
  end

  def self.accept(contract, accepter)
    return false unless contract.open?
    return false unless eligible_to_accept?(contract, accepter)

    contract.update!(
      accepted_by: accepter,
      status: :accepted,
      operational_data: contract.operational_data.merge(
        'accepted_at' => Time.current,
        'deadline' => calculate_deadline(contract)
      )
    )

    notify_parties(contract, :accepted)
    true
  end

  def self.complete(contract, delivery_data = {})
    return false unless contract.accepted?
    return false unless validate_completion(contract, delivery_data)

    contract.update!(
      status: :completed,
      operational_data: contract.operational_data.merge(
        'completed_at' => Time.current,
        'delivery_data' => delivery_data
      )
    )

    # Process reward payment
    RewardService.pay_out(contract.reward, contract.accepted_by)

    notify_parties(contract, :completed)
    true
  end

  def self.cancel(contract, reason = nil)
    return false unless contract.open? || contract.accepted?

    contract.update!(
      status: :failed,
      operational_data: contract.operational_data.merge(
        'cancelled_at' => Time.current,
        'cancellation_reason' => reason
      )
    )

    notify_parties(contract, :cancelled)
    true
  end

  def self.check_expirations
    # Check for expired contracts
    MissionContract.where(status: [:open, :accepted]).each do |contract|
      deadline = contract.operational_data['deadline']
      if deadline && Time.parse(deadline) < Time.current
        expire_contract(contract)
      end
    end
  end

  private

  def self.calculate_supply_reward(supplier, buyer, resource_name, quantity, terms)
    # Calculate fair market value for the supply contract
    base_price = Market::NpcPriceCalculator.calculate_ask(supplier.settlement, resource_name) || 10.0
    total_value = base_price * quantity

    # Apply contract-specific markup
    contract_markup = terms['urgency'] == 'high' ? 1.5 : 1.2
    reward_amount = total_value * contract_markup

    # Apply delivery risk premium
    risk_premium = calculate_delivery_risk(buyer, supplier)
    reward_amount *= (1 + risk_premium)

    {
      'type' => 'credits',
      'amount' => reward_amount.round(2),
      'description' => "Supply contract payment for #{quantity}kg #{resource_name}",
      'market_adjusted' => true
    }
  end

  def self.calculate_project_cost(project_spec)
    # Estimate project cost based on complexity
    base_cost = project_spec['estimated_cost'] || 10000
    complexity_multiplier = project_spec['complexity'] || 1.0

    (base_cost * complexity_multiplier).round(2)
  end

  def self.calculate_delivery_risk(buyer, supplier)
    # Calculate risk premium based on distance, reliability, etc.
    distance_factor = calculate_distance_factor(buyer, supplier)
    reliability_factor = supplier.reliability_score || 0.8

    # Higher distance = higher risk, lower reliability = higher risk
    risk = (distance_factor * 0.3) + ((1 - reliability_factor) * 0.2)
    [risk, 0.5].min  # Cap at 50% premium
  end

  def self.calculate_distance_factor(entity_a, entity_b)
    # Simplified distance calculation
    location_a = entity_a.respond_to?(:location) ? entity_a.location : entity_a.settlement&.location
    location_b = entity_b.respond_to?(:location) ? entity_b.location : entity_b.settlement&.location

    return 0.1 unless location_a && location_b  # Default low risk

    # Calculate actual distance (simplified)
    distance = Math.sqrt(
      (location_a.x - location_b.x)**2 +
      (location_a.y - location_b.y)**2
    )

    # Normalize to 0-1 scale (assuming max distance of 1000 units)
    [distance / 1000.0, 1.0].min
  end

  def self.eligible_to_accept?(contract, accepter)
    # Check if the accepter can fulfill the contract requirements
    case contract.operational_data['contract_type']
    when 'supply'
      can_supply_resource?(accepter, contract.requirements)
    when 'construction'
      can_perform_construction?(accepter, contract.requirements)
    else
      true  # Default allow
    end
  end

  def self.can_supply_resource?(supplier, requirements)
    resource = requirements['resource']
    quantity = requirements['quantity']

    settlement = supplier.respond_to?(:settlement) ? supplier.settlement : supplier
    return false unless settlement

    available = settlement.inventory_level(resource) || 0
    available >= quantity
  end

  def self.can_perform_construction?(contractor, requirements)
    # Check if contractor has required capabilities
    project_spec = requirements['project_spec']
    required_skills = project_spec['required_skills'] || []

    contractor.respond_to?(:has_skills?) && contractor.has_skills?(required_skills)
  end

  def self.validate_completion(contract, delivery_data)
    case contract.operational_data['contract_type']
    when 'supply'
      validate_supply_delivery(contract, delivery_data)
    when 'construction'
      validate_construction_completion(contract, delivery_data)
    else
      true  # Default validation passes
    end
  end

  def self.validate_supply_delivery(contract, delivery_data)
    required_quantity = contract.requirements['quantity']
    delivered_quantity = delivery_data['delivered_quantity'] || 0

    delivered_quantity >= required_quantity * 0.95  # Allow 5% shortfall
  end

  def self.validate_construction_completion(contract, delivery_data)
    # Check if project meets quality standards
    quality_score = delivery_data['quality_score'] || 0
    required_quality = contract.requirements['quality_standards']

    quality_score >= required_quality
  end

  def self.calculate_deadline(contract)
    base_deadline = contract.requirements['deadline'] ||
                   contract.operational_data['deadline']

    return base_deadline if base_deadline

    # Default deadlines based on contract type
    case contract.operational_data['contract_type']
    when 'supply'
      30.days.from_now
    when 'construction'
      90.days.from_now
    else
      60.days.from_now
    end
  end

  def self.expire_contract(contract)
    contract.update!(status: :expired)
    notify_parties(contract, :expired)
  end

  def self.notify_parties(contract, event)
    # Notify both parties of contract status changes
    [contract.offered_by, contract.accepted_by].compact.each do |party|
      send_notification(party, contract, event)
    end
  end

  def self.send_notification(recipient, contract, event)
    # Placeholder for notification system
    # Could integrate with ActionCable, email, or in-game notifications
    Rails.logger.info "Contract #{contract.id} #{event} notification sent to #{recipient.class.name} #{recipient.id}"
  end

  # Legacy methods for backward compatibility
  def self.offer_to_players(contract)
    # Notify eligible players
    Player.eligible_for(contract).each do |player|
      send_notification(player, contract, :offered)
    end
  end

  def self.load_manifest(manifest_file)
    path = Rails.root.join("data/missions/titan_harvester_mission", manifest_file)
    JSON.parse(File.read(path))
  rescue StandardError => e
    Rails.logger.error "Failed to load manifest #{manifest_file}: #{e.message}"
    {}
  end

  def self.extract_requirements(manifest)
    {
      "craft_type" => manifest.dig("craft", "id"),
      "units" => manifest.dig("inventory", "units"),
      "supplies" => manifest.dig("inventory", "supplies")
    }
  end

  def self.determine_reward(manifest)
    { "credits" => 5000, "market_adjusted" => true }
  end
end