Location::CelestialLocation.where("coordinates LIKE ?", "%99.99°N%").delete_all
Location::CelestialLocation.where("coordinates LIKE ?", "%Sanity%").delete_all
Player.where("name LIKE ?", "%SanityFinal%").delete_all
Settlement::BaseSettlement.where("name LIKE ?", "%SanityFinal%").delete_all

body = CelestialBodies::CelestialBody.find_by(identifier: "LUNA-01")
loc = Location::CelestialLocation.create!(name: "SanityFinalCheck", coordinates: "99.99°N 99.99°W", celestial_body: body)
player = Player.create!(name: "SanityFinalPlayer", active_location: "SanityFinalCheck")
settlement = Settlement::BaseSettlement.create!(name: "SanityFinalSettlement", current_population: 1, settlement_type: 0, owner: player, location: loc)
storage = Storage::SurfaceStorage.create!(inventory: settlement.inventory, celestial_body: body)
pile = storage.material_piles.create!(material_type: "raw_regolith", amount: 5000, quality_factor: 1.0)

$stderr.puts "RAW_REGOLITH_BEFORE: #{pile.amount}"

service = Manufacturing::ProductionService.new(settlement)
result = service.manufacture_component({
  id: "3d_printed_ibeam", name: "3D-Printed I-Beam", category: "structural",
  input_quantity_kg: 100, production_time_hours: 2.0,
  composition: { "SiO2" => 43.0 },
  additional_materials: [{name: "binding_agent", quantity: 0.1, composition: {}}]
}, 3)

$stderr.puts "RAW_REGOLITH_AFTER: #{storage.material_piles.where(material_type: "raw_regolith").first&.amount}"
$stderr.puts "DEPLETED_REGOLITH: #{storage.material_piles.where(material_type: "depleted_regolith").first&.amount}"
$stderr.puts "COMPONENT_AMOUNT: #{result[:component_amount]}"
$stderr.puts "PVE_CYCLES: #{result[:pve_cycles]}"

Location::CelestialLocation.where("coordinates LIKE ?", "%99.99°N%").delete_all
Location::CelestialLocation.where("coordinates LIKE ?", "%Sanity%").delete_all
Player.where("name LIKE ?", "%SanityFinal%").delete_all
Settlement::BaseSettlement.where("name LIKE ?", "%SanityFinal%").delete_all
