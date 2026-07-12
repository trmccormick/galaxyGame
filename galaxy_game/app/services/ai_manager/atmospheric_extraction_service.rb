# app/services/ai_manager/atmospheric_extraction_service.rb
module AIManager
  class AtmosphericExtractionService
    attr_reader :skimmer, :source_body, :target_body, :owner_corporation

    def initialize(skimmer, source_body, target_body: nil)
      @skimmer = skimmer
      @source_body = source_body
      @target_body = target_body || resolve_target_body
      @owner_corporation = resolve_owner_corporation(skimmer)
    end

    # Primary public API — called by AI Manager decision logic
    def execute_extraction(transfer_params = {})
      validate_skimmer_ownership!
      validate_source_atmosphere!

      # Skimmers ALWAYS extract raw (proportional) — they cannot selectively target gases
      transfer_mode = :raw
      capacity = transfer_params[:capacity] || default_skimmer_capacity

      TerraSim::AtmosphericTransferService
        .new(source_body, target_body, mode: transfer_mode, logger: Rails.logger)
        .transfer_atmosphere({ capacity: capacity })
    end

    # Skimmer docks with Cycler to offload cargo
    def dock_and_transfer_to_cycler(cycler, max_capacity: nil)
      return false unless can_dock?(cycler)

      # Calculate total atmospheric mass from gases (not the column which may be nil/Hash)
      skimmer_mass = skimmer.atmosphere&.gases&.sum { |gas| gas.mass.to_i } || 0
      cycler_storage = max_capacity || cycler_available_storage(cycler)
      
      cargo_amount = [skimmer_mass, cycler_storage].min

      transfer_gases_to_cycler(cycler, cargo_amount)
    end

    private

    def validate_skimmer_ownership!
      return if owner_corporation
      raise ArgumentError, "Skimmer #{skimmer.id} has no owner — cannot extract"
    end

    def validate_source_atmosphere!
      unless source_body.atmosphere&.present?
        raise ArgumentError, "Source body #{source_body.name} has no atmosphere"
      end
    end

    def resolve_owner_corporation(skimmer)
      return nil unless skimmer.owner
      # Owner can be an Organization (with organization_type enum) or a Corporation subclass
      if skimmer.owner.respond_to?(:organization_type) && skimmer.owner.organization_type == 'corporation'
        skimmer.owner
      elsif skimmer.owner.respond_to?(:account) && skimmer.owner.account&.respond_to?(:corporation)
        skimmer.owner.account.corporation
      else
        nil
      end
    end

    def resolve_target_body
      # Default target is Luna for MVP (LDC settlement)
      CelestialBodies::CelestialBody.find_by(name: 'Luna')
    end

    def can_dock?(cycler)
      (skimmer.has_available_docking_port? == true) && (cycler.base_craft&.has_available_docking_port? == true)
    end

    def transfer_gases_to_cycler(cycler, amount)
      # CARGO GOES IN definition_data['cargo'] HASH — NOT atmosphere
      gases = skimmer.atmosphere&.gases || []
      cycler_cargo = (cycler.definition_data || {})['cargo'] ||= {}

      gases.each do |gas|
        gas_mass = (amount * (gas.percentage / 100.0)).to_i
        cycler_cargo[gas.name] = (cycler_cargo[gas.name] || 0) + gas_mass
      end

      # Update cycler's serialized definition_data
      cycler.definition_data ||= {}
      cycler.definition_data['cargo'] = cycler_cargo
      cycler.save! if cycler.changed?

      # Remove from skimmer atmosphere by iterating through gases individually
      if skimmer.atmosphere
        skimmer.atmosphere.gases.each do |gas|
          gas_mass_to_remove = (amount * (gas.percentage / 100.0)).to_i
          skimmer.atmosphere.remove_gas(gas.name, gas_mass_to_remove) if gas_mass_to_remove > 0
        end
      end
    end

    def cycler_available_storage(cycler)
      # Use cycler's storage capacity or available docking port constraint
      return 0 unless cycler.base_craft
      
      cycler.base_craft.base_units.sum do |unit|
        unit.operational_data&.dig('storage', 'capacity') || 0
      end - (cycler.base_craft.base_units.sum do |unit|
        unit.operational_data&.dig('current_load') || 0
      end)
    end

    def default_skimmer_capacity
      # Use skimmer's atmosphere total mass as default extraction amount
      skimmer.atmosphere&.total_atmospheric_mass || 5000
    end
  end
end
