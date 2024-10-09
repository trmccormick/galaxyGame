# db/seeds.rb

# Create Celestial Body
moon = CelestialBody.create!(name: "Moon")

# Create Materials on the Moon
materials = [
  { name: "Regolith", total_amount: 1000000, unit_of_measure: "tons" },
  { name: "Helium-3", total_amount: 500, unit_of_measure: "kg" },
  { name: "Iron", total_amount: 200000, unit_of_measure: "tons" }
]

materials.each do |material|
  Material.create!(material.merge(celestial_body: moon))
end

# Create an Outpost
outpost = Outpost.create!(name: "Artemis Outpost", celestial_body: moon)

# Create Resources available in the Outpost
resources = [
  { name: "Water", amount: 1000, unit_of_measure: "liters" },
  { name: "Oxygen", amount: 500, unit_of_measure: "kg" },
  { name: "Food", amount: 300, unit_of_measure: "kg" },
  { name: "Power", amount: 200, unit_of_measure: "kW" }
]

resources.each do |resource|
  Resource.create!(resource.merge(outpost: outpost))
end

# Create Base Units with Materials and Requirements
base_units = [
  {
    name: "Inflatable Habitat Module",
    base_materials: {
      kevlar_fabric: "500 kg",
      aluminum_mylar_layers: "200 kg",
      airtight_polymer_liner: "100 kg"
    },
    operating_requirements: {
      power: "5 kW",
      water: "50 liters/day",
      oxygen: "20 kg/day",
      food: "10 kg/day"
    },
    output_materials: {
      carbon_dioxide: "20 kg/day",
      waste_water: "30 liters/day"
    }
  },
  {
    name: "Mining Rover",
    base_materials: {
      titanium_alloy: "300 kg",
      solar_panels: "50 kg"
    },
    operating_requirements: {
      power: "10 kW",
    },
    output_materials: {
      regolith: "100 kg/day",
    }
  }
]

base_units.each do |unit_data|
  BaseUnit.create!(
    name: unit_data[:name],
    outpost: outpost,
    base_materials: unit_data[:base_materials],
    operating_requirements: unit_data[:operating_requirements],
    output_materials: unit_data[:output_materials]
  )
end

