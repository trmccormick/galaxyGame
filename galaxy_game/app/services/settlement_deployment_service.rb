class SettlementDeploymentService
  def self.establish_from_craft(craft, location, manifest_name: 'precursor_craft_deployment_cargo')
    cargo_manifest = CargoManifestLoader.load(manifest_name)
    verify_deployment_cargo(craft.inventory, cargo_manifest)

    ActiveRecord::Base.transaction do
      settlement = Settlement::BaseSettlement.create!(
        name: "#{location.name} Outpost",
        settlement_type: :outpost,
        location: location,
        owner: craft.owner
      )

      cargo_manifest['cargo_sections']['deployment_units'].each do |unit_data|
        deploy_unit(settlement, craft.inventory, unit_data)
      end

      transfer_cargo(craft.inventory, settlement.inventory, cargo_manifest)
      settlement
    end
  end

  # These methods will be moved or delegated from BaseSettlement
  def self.verify_deployment_cargo(inventory, cargo_manifest)
    # Implement actual verification logic as needed (placeholder: always true)
    true
  end

  def self.deploy_unit(settlement, inventory, unit_data)
    inventory.remove_item(unit_data['id'], 1)
    unit = Units::BaseUnit.create!(
      name: unit_data['name'],
      unit_type: unit_data['deployment_type'],
      identifier: "#{settlement.name}_#{unit_data['id']}_1",
      operational_data: unit_data['unit_data'],
      owner: settlement
    )
    settlement.base_units << unit
  end

  def self.transfer_cargo(from_inventory, to_inventory, cargo_manifest)
    # Transfer all items in manifest's cargo_sections['resources']
    (cargo_manifest['cargo_sections']['resources'] || []).each do |resource|
      name = resource['name']
      amount = resource['amount']
      from_inventory.remove_item(name, amount)
      to_inventory.add_item(name, amount, to_inventory.owner)
    end
  end
end
