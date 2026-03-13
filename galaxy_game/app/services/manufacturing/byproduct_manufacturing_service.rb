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
      # Gas is stored as Items with material_type: :gas in the settlement inventory
      inventory = settlement.inventory
      return unless inventory

      # Normalize gas name (service uses 'O2', 'N2' etc.)
      gas_name = gas.to_s

      existing_item = inventory.items.find_by(name: gas_name, material_type: :gas)

      if existing_item
        existing_item.update!(amount: existing_item.amount + mass)
      else
        inventory.items.create!(
          name: gas_name,
          material_type: :gas,
          amount: mass,
          owner: settlement.owner
        )
      end
    end
  end
end