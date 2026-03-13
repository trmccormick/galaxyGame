# Task: Fix Pressurization Service + Byproduct Service — Wrong Architecture

## Background
Gas storage is NOT tracked in structure `operational_data` or unit fields.
All items including gases are tracked via the `Item` model in the settlement's
inventory. Gas items have `material_type: :gas`.

The correct way to get gas quantities for a settlement:
```ruby
settlement.inventory.items.where(material_type: :gas)
```

Two services are currently wrong and need to be rewritten to use inventory.

---

## Fix 1: Rewrite `source_gases_from_depot_tanks` in StructurePressurizationService

### File to modify
`app/services/pressurization/structure_pressurization_service.rb`

### Find and replace the entire `source_gases_from_depot_tanks` method:

Find:
```ruby
def self.source_gases_from_depot_tanks(settlement)
  gases = {}
  
  # Look for depot tanks in the settlement
  depot_tanks = settlement.structures.where("operational_data->>'structure_type' = ?", 'depot_tank')
  
  depot_tanks.each do |tank|
    tank_data = tank.operational_data || {}
    
    # Check for stored gases
    if tank_data['gas_storage']
      tank_data['gas_storage'].each do |gas_name, amount|
        # Convert to common names used by pressurization service
        common_name = case gas_name
                      when 'O2' then 'oxygen'
                      when 'N2' then 'nitrogen'
                      when 'CO2' then 'carbon_dioxide'
                      else gas_name.downcase
                      end
        
        gases[common_name.to_sym] ||= 0
        gases[common_name.to_sym] += amount
      end
    end
  end
```

Replace with:
```ruby
def self.source_gases_from_depot_tanks(settlement)
  gases = {}

  # Gas quantities are tracked in the settlement inventory as Items with material_type: :gas
  gas_items = settlement.inventory.items.where(material_type: :gas)

  gas_items.each do |item|
    # Normalize gas names to symbols used by pressurization service
    common_name = case item.name.upcase
                  when 'O2', 'OXYGEN'       then :oxygen
                  when 'N2', 'NITROGEN'     then :nitrogen
                  when 'CO2'                then :carbon_dioxide
                  when 'CH4', 'METHANE'     then :methane
                  when 'H2', 'HYDROGEN'     then :hydrogen
                  when 'AR', 'ARGON'        then :argon
                  else item.name.downcase.to_sym
                  end

    gases[common_name] ||= 0
    gases[common_name] += item.amount.to_f
  end

  gases
end
```

---

## Fix 2: Rewrite `add_gas_to_sector_storage` in ByproductManufacturingService

### File to modify
`app/services/manufacturing/byproduct_manufacturing_service.rb`

### Find and replace the entire `add_gas_to_sector_storage` method:

Find:
```ruby
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
```

Replace with:
```ruby
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
```

---

## Fix 3: Update the spec to use inventory instead of depot_tank structure

### File to modify
`spec/services/pressurization/structure_pressurization_service_spec.rb`

### Find the context setup (around line 100):
```ruby
let!(:depot_tank) { create(:depot_tank, settlement: settlement) }
before do
  depot_tank.save
  depot_tank.update_columns(operational_data: depot_tank.operational_data.merge('gas_storage' => { 'oxygen' => 100, 'nitrogen' => 200 }))
end
```

### Replace with:
```ruby
before do
  # Gas is stored as inventory items with material_type: :gas
  create(:item, name: 'O2', material_type: :gas, amount: 100, inventory: settlement.inventory, owner: settlement.owner)
  create(:item, name: 'N2', material_type: :gas, amount: 200, inventory: settlement.inventory, owner: settlement.owner)
end
```

---

## Verification

```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/pressurization/structure_pressurization_service_spec.rb --format progress 2>&1 | tail -3'
```
Expected: 0 failures

Also verify byproduct service still works:
```bash
docker exec -it web bash -c 'unset DATABASE_URL && RAILS_ENV=test bundle exec rspec spec/services/manufacturing/ --format progress 2>&1 | tail -3'
```
Expected: 0 failures
