class ExtractionService
  # Service for extracting buffer gases like Argon on Mars at high energy cost

  def self.extract_argon_on_mars(settlement, amount_needed)
    return false unless settlement.location&.celestial_body&.name == 'Mars'

    # Check if N2 levels are critical
    priority_heuristic = AIManager::PriorityHeuristic.new(settlement)
    return false unless priority_heuristic.nitrogen_critical?

    # Calculate energy cost (high cost)
    energy_cost_per_kg = 1000 # GCC per kg Argon
    total_energy_cost = amount_needed * energy_cost_per_kg

    # Check if settlement has enough energy
    available_energy = settlement.account&.balance || 0
    return false if available_energy < total_energy_cost

    # Deduct energy cost
    settlement.account.update!(balance: available_energy - total_energy_cost)

    # Add Argon to gas_storage
    structures = Structures::BaseStructure.where(settlement_id: settlement.id)
    argon_per_structure = amount_needed / structures.count.to_f

    structures.each do |structure|
      structure.operational_data ||= {}
      structure.operational_data['gas_storage'] ||= {}
      structure.operational_data['gas_storage']['argon'] ||= 0.0
      structure.operational_data['gas_storage']['argon'] += argon_per_structure
      structure.save!
    end

    Rails.logger.info "[ExtractionService] Extracted #{amount_needed}kg Argon on Mars at cost #{total_energy_cost} GCC"
    true
  end
end