module Manufacturing
  class ByproductManufacturingService
    # Service for handling byproduct generation during resource extraction
    # Currently handles O2 byproduct from Silicon mining

    BYPRODUCTS = {
      'Si' => { 'O2' => 0.5 } # 0.5 kg O2 per kg Si mined
    }.freeze

    def self.process_mining_byproducts(settlement, material, amount_mined)
      return unless BYPRODUCTS.key?(material)

      byproducts = BYPRODUCTS[material]
      byproducts.each do |gas, ratio|
        byproduct_mass = amount_mined * ratio
        add_gas_to_sector_storage(settlement, gas, byproduct_mass)
      end
    end

    private

    def self.add_gas_to_sector_storage(settlement, gas, mass)
      # Find depot tanks in the settlement to store the gas
      depot_tanks = settlement.structures.where(structure_name: 'depot_tank')

      return if depot_tanks.empty?

      # Distribute the gas across available depot tanks
      # For simplicity, add to the first available tank
      depot_tank = depot_tanks.first

      current_storage = depot_tank.operational_data.fetch('gas_storage', {})
      updated_storage = current_storage.merge(
        gas => current_storage.fetch(gas, 0) + mass
      )

      depot_tank.update_columns(
        operational_data: depot_tank.operational_data.merge('gas_storage' => updated_storage)
      )

      Rails.logger.info "[ByproductManufacturing] Added #{mass} kg of #{gas} to #{depot_tank.name} from mining byproduct"
    end
  end
end