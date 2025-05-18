# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2025_05_15_165627) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_points", force: :cascade do |t|
    t.string "name"
    t.integer "size"
    t.integer "position"
    t.integer "access_type"
    t.bigint "lavatube_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lavatube_id"], name: "index_access_points_on_lavatube_id"
  end

  create_table "accounts", force: :cascade do |t|
    t.string "accountable_type", null: false
    t.bigint "accountable_id", null: false
    t.decimal "balance", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "colony_id"
    t.index ["accountable_type", "accountable_id"], name: "index_accounts_on_accountable_type_and_accountable_id"
    t.index ["colony_id"], name: "index_accounts_on_colony_id"
  end

  create_table "atmospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.float "temperature", default: 0.0
    t.float "pressure", default: 0.0
    t.json "composition", default: {}
    t.float "total_atmospheric_mass", default: 0.0
    t.json "dust", default: {}
    t.integer "pollution", default: 0
    t.string "environment_type", default: "planetary"
    t.boolean "sealing_status", default: false
    t.json "gas_changes", default: {}
    t.float "dynamic_pressure"
    t.jsonb "base_values", default: {}, null: false
    t.jsonb "temperature_data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_atmospheres_on_celestial_body_id"
  end

  create_table "base_crafts", force: :cascade do |t|
    t.string "name", null: false
    t.string "craft_name", null: false
    t.string "craft_type", null: false
    t.integer "current_population"
    t.boolean "deployed", default: false
    t.string "current_location"
    t.jsonb "operational_data", default: {}
    t.string "owner_type"
    t.bigint "owner_id"
    t.bigint "player_id"
    t.bigint "docked_at_id"
    t.bigint "stabilizing_wormhole_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["craft_type"], name: "index_base_crafts_on_craft_type"
    t.index ["docked_at_id"], name: "index_base_crafts_on_docked_at_id"
    t.index ["name"], name: "index_base_crafts_on_name"
    t.index ["operational_data"], name: "index_base_crafts_on_operational_data", using: :gin
    t.index ["owner_type", "owner_id"], name: "index_base_crafts_on_owner"
    t.index ["player_id"], name: "index_base_crafts_on_player_id"
    t.index ["stabilizing_wormhole_id"], name: "index_base_crafts_on_stabilizing_wormhole_id"
  end

  create_table "base_locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "locationable_type"
    t.bigint "locationable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locationable_type", "locationable_id"], name: "index_base_locations_on_locationable"
    t.index ["name"], name: "index_base_locations_on_name"
  end

  create_table "base_modules", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.string "description"
    t.string "module_type", null: false
    t.integer "energy_cost"
    t.json "maintenance_materials"
    t.string "module_class"
    t.jsonb "operational_data", default: {}
    t.string "attachable_type"
    t.bigint "attachable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_base_modules_on_attachable"
    t.index ["identifier"], name: "index_base_modules_on_identifier", unique: true
    t.index ["operational_data"], name: "index_base_modules_on_operational_data", using: :gin
  end

  create_table "base_settlements", force: :cascade do |t|
    t.string "name"
    t.integer "current_population", default: 0
    t.integer "settlement_type", default: 0
    t.bigint "colony_id"
    t.bigint "accounts_id"
    t.string "base_settlements_type"
    t.bigint "base_settlements_id"
    t.string "owner_type"
    t.bigint "owner_id"
    t.integer "length"
    t.integer "diameter"
    t.float "usable_area"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "player_id"
    t.index ["accounts_id"], name: "index_base_settlements_on_accounts_id"
    t.index ["base_settlements_type", "base_settlements_id"], name: "index_base_settlements_on_base_settlements"
    t.index ["colony_id"], name: "index_base_settlements_on_colony_id"
    t.index ["owner_type", "owner_id"], name: "index_base_settlements_on_owner"
    t.index ["player_id"], name: "index_base_settlements_on_player_id"
  end

  create_table "base_units", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.string "unit_type", null: false
    t.jsonb "operational_data", default: {}
    t.string "location_type"
    t.integer "location_id"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "attachable_type"
    t.bigint "attachable_id"
    t.bigint "base_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attachable_type", "attachable_id"], name: "index_base_units_on_attachable"
    t.index ["base_unit_id"], name: "index_base_units_on_base_unit_id"
    t.index ["identifier"], name: "index_base_units_on_identifier", unique: true
    t.index ["owner_type", "owner_id"], name: "index_base_units_on_owner"
  end

  create_table "biomes", force: :cascade do |t|
    t.string "name", null: false
    t.int4range "temperature_range", null: false
    t.int4range "humidity_range", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_biomes_on_name", unique: true
  end

  create_table "biospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.float "habitable_ratio", default: 0.0, null: false
    t.float "ice_latitude", default: 0.0, null: false
    t.float "biodiversity_index", default: 0.0, null: false
    t.float "vegetation_cover", default: 0.0, null: false
    t.integer "biome_count", default: 0, null: false
    t.text "biome_distribution"
    t.integer "soil_health", default: 0
    t.float "soil_organic_content", default: 0.0
    t.float "soil_microbial_activity", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_biospheres_on_celestial_body_id"
  end

  create_table "blueprints", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.json "input_resources"
    t.json "output_resources"
    t.integer "production_time"
    t.integer "gcc_cost"
    t.bigint "player_id", null: false
    t.boolean "purchased", default: false
    t.integer "current_research_level", default: 0
    t.float "material_efficiency", default: 0.0
    t.float "time_efficiency", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player_id"], name: "index_blueprints_on_player_id"
  end

  create_table "celestial_bodies", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name"
    t.string "type"
    t.decimal "size"
    t.decimal "gravity", precision: 10, scale: 2
    t.decimal "density", precision: 10, scale: 2
    t.decimal "orbital_period", precision: 10, scale: 2
    t.jsonb "gas_quantities", default: {}
    t.jsonb "materials", default: {}
    t.string "mass"
    t.float "radius"
    t.string "parent_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0, null: false
    t.float "known_pressure"
    t.float "surface_area"
    t.float "volume"
    t.float "surface_temperature"
    t.boolean "geological_activity", default: false
    t.integer "solar_system_id"
    t.float "albedo"
    t.float "insolation"
    t.jsonb "crust", default: "{}"
    t.jsonb "mantle", default: "{}"
    t.jsonb "core", default: "{}"
    t.jsonb "base_values", default: {}, null: false
    t.jsonb "current_values", default: {}, null: false
    t.index ["identifier"], name: "index_celestial_bodies_on_identifier", unique: true
  end

  create_table "celestial_bodies_alien_life_forms", force: :cascade do |t|
    t.bigint "biosphere_id", null: false
    t.string "name", null: false
    t.integer "complexity", default: 0
    t.integer "domain", default: 0
    t.integer "population", default: 1000
    t.jsonb "properties", default: {}
    t.string "preferred_biome"
    t.decimal "mass", precision: 10, scale: 6, default: "0.1"
    t.decimal "metabolism_rate", precision: 5, scale: 3, default: "0.1"
    t.decimal "health_modifier", precision: 5, scale: 3, default: "1.0"
    t.decimal "size_modifier", precision: 5, scale: 3, default: "1.0"
    t.decimal "consumption_rate", precision: 5, scale: 3, default: "0.1"
    t.decimal "foraging_efficiency", precision: 5, scale: 3, default: "0.5"
    t.decimal "hunting_efficiency", precision: 5, scale: 3, default: "0.5"
    t.decimal "reproduction_rate", precision: 5, scale: 3, default: "0.05"
    t.decimal "mortality_rate", precision: 5, scale: 3, default: "0.03"
    t.decimal "o2_production_rate", precision: 8, scale: 6, default: "0.0"
    t.decimal "co2_production_rate", precision: 8, scale: 6, default: "0.01"
    t.decimal "methane_production_rate", precision: 8, scale: 6, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biosphere_id"], name: "index_celestial_bodies_alien_life_forms_on_biosphere_id"
  end

  create_table "celestial_bodies_materials", force: :cascade do |t|
    t.bigint "celestial_body_id"
    t.bigint "material_id"
    t.float "amount", default: 0.0
    t.string "state", default: "solid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_celestial_bodies_materials_on_celestial_body_id"
    t.index ["material_id"], name: "index_celestial_bodies_materials_on_material_id"
  end

  create_table "celestial_locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "coordinates", null: false
    t.string "locationable_type"
    t.bigint "locationable_id"
    t.bigint "celestial_body_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id", "coordinates"], name: "unique_coordinates_per_celestial_body", unique: true
    t.index ["celestial_body_id"], name: "index_celestial_locations_on_celestial_body_id"
    t.index ["locationable_type", "locationable_id"], name: "index_celestial_locations_on_locationable"
    t.index ["name"], name: "index_celestial_locations_on_name"
  end

  create_table "colonies", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.bigint "celestial_body_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "funds", default: "0.0"
    t.decimal "expenses", default: "0.0"
    t.index ["celestial_body_id"], name: "index_colonies_on_celestial_body_id"
  end

  create_table "cyclers", force: :cascade do |t|
    t.string "cycler_type"
    t.integer "orbital_period"
    t.datetime "last_encounter_date"
    t.string "current_trajectory_phase"
    t.integer "maximum_docking_capacity"
    t.jsonb "encounter_schedule"
    t.bigint "base_craft_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_craft_id"], name: "index_cyclers_on_base_craft_id"
  end

  create_table "dwarf_planets", force: :cascade do |t|
    t.string "name"
    t.float "mass"
    t.float "surface_temperature"
    t.text "atmosphere_composition"
    t.float "atmospheric_pressure"
    t.bigint "solar_system_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solar_system_id"], name: "index_dwarf_planets_on_solar_system_id"
  end

  create_table "environments", force: :cascade do |t|
    t.bigint "biome_id", null: false
    t.bigint "celestial_bodies_id", null: false
    t.float "temperature"
    t.float "pressure"
    t.float "humidity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biome_id"], name: "index_environments_on_biome_id"
    t.index ["celestial_bodies_id"], name: "index_environments_on_celestial_bodies_id"
  end

  create_table "galaxies", force: :cascade do |t|
    t.string "name"
    t.string "identifier", null: false
    t.decimal "mass", precision: 20, scale: 2
    t.decimal "diameter", precision: 20, scale: 2
    t.string "galaxy_type"
    t.integer "age_in_billions"
    t.bigint "star_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["galaxy_type"], name: "index_galaxies_on_galaxy_type"
    t.index ["identifier"], name: "index_galaxies_on_identifier", unique: true
    t.index ["name"], name: "index_galaxies_on_name"
  end

  create_table "game_states", force: :cascade do |t|
    t.integer "year"
    t.integer "day"
    t.boolean "running", default: false
    t.integer "speed", default: 3
    t.datetime "last_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gases", force: :cascade do |t|
    t.string "name"
    t.float "percentage"
    t.float "ppm"
    t.float "mass"
    t.float "molar_mass"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "atmosphere_id", null: false
    t.index ["atmosphere_id"], name: "index_gases_on_atmosphere_id"
  end

  create_table "geological_materials", force: :cascade do |t|
    t.bigint "geosphere_id", null: false
    t.string "name", null: false
    t.string "layer", default: "crust", null: false
    t.decimal "percentage", precision: 10, scale: 6, default: "0.0"
    t.decimal "mass", precision: 38, scale: 6, default: "0.0"
    t.string "state", default: "solid"
    t.decimal "melting_point"
    t.decimal "boiling_point"
    t.boolean "is_volatile", default: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["geosphere_id", "name", "layer"], name: "index_geological_materials_on_geosphere_id_and_name_and_layer", unique: true
    t.index ["geosphere_id"], name: "index_geological_materials_on_geosphere_id"
  end

  create_table "geospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.json "crust_composition", default: {}
    t.json "mantle_composition", default: {}
    t.json "core_composition", default: {}
    t.float "total_crust_mass", default: 0.0
    t.float "total_mantle_mass", default: 0.0
    t.float "total_core_mass", default: 0.0
    t.float "temperature", default: 0.0
    t.float "pressure", default: 0.0
    t.float "geological_activity", default: 0.0
    t.boolean "tectonic_activity", default: false
    t.float "regolith_depth", default: 0.0
    t.float "regolith_particle_size", default: 0.0
    t.float "weathering_rate", default: 0.0
    t.jsonb "plates", default: {}, null: false
    t.jsonb "stored_volatiles", default: {}
    t.jsonb "base_values", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_geospheres_on_celestial_body_id"
  end

  create_table "hydrospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.float "temperature", default: 0.0
    t.float "pressure", default: 0.0
    t.json "water_bodies", default: {}
    t.json "composition", default: {}
    t.json "state_distribution", default: {"liquid" => 0.0, "solid" => 0.0, "vapor" => 0.0}
    t.float "total_water_mass", default: 0.0
    t.integer "pollution", default: 0
    t.string "environment_type", default: "planetary"
    t.boolean "sealed_status", default: false
    t.json "water_changes", default: {}
    t.float "dynamic_pressure"
    t.jsonb "base_values", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "ocean_temp"
    t.float "lake_temp"
    t.float "river_temp"
    t.float "ice_temp"
    t.index ["celestial_body_id"], name: "index_hydrospheres_on_celestial_body_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.string "inventoryable_type"
    t.bigint "inventoryable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "capacity"
    t.index ["inventoryable_type", "inventoryable_id"], name: "index_inventories_on_inventoryable"
    t.check_constraint "inventoryable_type IS NOT NULL AND inventoryable_id IS NOT NULL", name: "at_least_one_reference"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.decimal "amount", precision: 10, scale: 2, default: "0.0", null: false
    t.integer "material_type", default: 0, null: false
    t.integer "storage_method", default: 0, null: false
    t.decimal "total_weight", precision: 10, scale: 2, default: "0.0", null: false
    t.decimal "volume", precision: 10, scale: 2, default: "0.0"
    t.integer "durability"
    t.jsonb "metadata", default: {}
    t.string "origin_world"
    t.datetime "extraction_date"
    t.bigint "inventory_id"
    t.bigint "container_id"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.string "storage_unit_type"
    t.bigint "storage_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["container_id"], name: "index_items_on_container_id"
    t.index ["inventory_id"], name: "index_items_on_inventory_id"
    t.index ["owner_type", "owner_id"], name: "index_items_on_owner"
    t.index ["storage_unit_type", "storage_unit_id"], name: "index_items_on_storage_unit"
  end

  create_table "liquid_materials", force: :cascade do |t|
    t.string "name", null: false
    t.float "amount", default: 0.0, null: false
    t.bigint "hydrosphere_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hydrosphere_id"], name: "index_liquid_materials_on_hydrosphere_id"
  end

  create_table "market_conditions", force: :cascade do |t|
    t.bigint "market_marketplace_id", null: false
    t.string "resource"
    t.decimal "price"
    t.integer "supply"
    t.integer "demand"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["market_marketplace_id"], name: "index_market_conditions_on_market_marketplace_id"
  end

  create_table "market_marketplaces", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "market_orders", force: :cascade do |t|
    t.bigint "market_condition_id", null: false
    t.string "orderable_type", null: false
    t.bigint "orderable_id", null: false
    t.bigint "base_settlement_id", null: false
    t.string "resource"
    t.integer "quantity"
    t.integer "order_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_settlement_id"], name: "index_market_orders_on_base_settlement_id"
    t.index ["market_condition_id"], name: "index_market_orders_on_market_condition_id"
    t.index ["orderable_type", "orderable_id"], name: "index_market_orders_on_orderable"
  end

  create_table "market_price_histories", force: :cascade do |t|
    t.bigint "market_condition_id", null: false
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["market_condition_id"], name: "index_market_price_histories_on_market_condition_id"
  end

  create_table "market_supply_chains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "market_trades", force: :cascade do |t|
    t.string "resource"
    t.integer "quantity"
    t.decimal "price"
    t.string "buyer_type", null: false
    t.bigint "buyer_id", null: false
    t.string "seller_type", null: false
    t.bigint "seller_id", null: false
    t.bigint "buyer_settlement_id", null: false
    t.bigint "seller_settlement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_settlement_id"], name: "index_market_trades_on_buyer_settlement_id"
    t.index ["buyer_type", "buyer_id"], name: "index_market_trades_on_buyer"
    t.index ["seller_settlement_id"], name: "index_market_trades_on_seller_settlement_id"
    t.index ["seller_type", "seller_id"], name: "index_market_trades_on_seller"
  end

  create_table "market_transaction_fees", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_piles", force: :cascade do |t|
    t.bigint "surface_storage_id", null: false
    t.string "material_type", null: false
    t.decimal "amount", precision: 20, scale: 2, default: "0.0", null: false
    t.decimal "quality_factor", precision: 4, scale: 3, default: "1.0", null: false
    t.json "coordinates"
    t.decimal "height"
    t.decimal "spread_radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["surface_storage_id", "material_type"], name: "index_material_piles_on_surface_storage_id_and_material_type"
    t.index ["surface_storage_id"], name: "index_material_piles_on_surface_storage_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "name"
    t.float "amount"
    t.float "boiling_point"
    t.float "melting_point"
    t.string "state_at_room_temp"
    t.integer "state", default: 0, null: false
    t.integer "location", default: 0, null: false
    t.boolean "is_volatile", default: false
    t.string "materializable_type"
    t.bigint "materializable_id"
    t.bigint "celestial_body_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_materials_on_celestial_body_id"
    t.index ["location"], name: "index_materials_on_location"
    t.index ["materializable_type", "materializable_id"], name: "index_materials_on_materializable"
  end

  create_table "npc_colonies", force: :cascade do |t|
    t.string "name", null: false
    t.integer "population_capacity"
    t.json "initial_resources", default: {}
    t.json "ai_manager", default: {}
    t.json "trade_routes", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orbital_relationships", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.integer "sun_id", null: false
    t.float "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_orbital_relationships_on_celestial_body_id"
    t.index ["sun_id"], name: "index_orbital_relationships_on_sun_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name", null: false
    t.string "identifier", null: false
    t.integer "organization_type", default: 0, null: false
    t.json "operational_data"
    t.string "description"
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_organizations_on_identifier", unique: true
    t.index ["owner_type", "owner_id"], name: "index_organizations_on_owner"
  end

  create_table "planet_biomes", force: :cascade do |t|
    t.bigint "biome_id", null: false
    t.bigint "biosphere_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biome_id"], name: "index_planet_biomes_on_biome_id"
    t.index ["biosphere_id"], name: "index_planet_biomes_on_biosphere_id"
  end

  create_table "plant_environments", force: :cascade do |t|
    t.bigint "plant_id", null: false
    t.bigint "environment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["environment_id"], name: "index_plant_environments_on_environment_id"
    t.index ["plant_id"], name: "index_plant_environments_on_plant_id"
  end

  create_table "plants", force: :cascade do |t|
    t.string "name"
    t.daterange "growth_temperature_range"
    t.daterange "growth_humidity_range"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.string "active_location", null: false
    t.string "biography"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rigs", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "rig_type"
    t.integer "capacity"
    t.jsonb "operational_data"
    t.string "attachable_type"
    t.integer "attachable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "skylights", force: :cascade do |t|
    t.integer "diameter"
    t.integer "position"
    t.bigint "lavatube_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lavatube_id"], name: "index_skylights_on_lavatube_id"
  end

  create_table "solar_systems", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.bigint "galaxy_id"
    t.bigint "current_star_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_star_id"], name: "index_solar_systems_on_current_star_id"
    t.index ["galaxy_id"], name: "index_solar_systems_on_galaxy_id"
    t.index ["identifier"], name: "index_solar_systems_on_identifier", unique: true
  end

  create_table "spatial_locations", force: :cascade do |t|
    t.string "name", null: false
    t.float "x_coordinate", null: false
    t.float "y_coordinate", null: false
    t.float "z_coordinate", null: false
    t.string "locationable_type"
    t.bigint "locationable_id"
    t.string "spatial_context_type"
    t.bigint "spatial_context_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["locationable_type", "locationable_id"], name: "index_spatial_locations_on_locationable"
    t.index ["name"], name: "index_spatial_locations_on_name"
    t.index ["spatial_context_type", "spatial_context_id", "x_coordinate", "y_coordinate", "z_coordinate"], name: "unique_3d_position_per_context", unique: true
    t.index ["spatial_context_type", "spatial_context_id"], name: "index_spatial_locations_on_spatial_context"
  end

  create_table "sponsorships", force: :cascade do |t|
    t.string "name"
    t.string "sponsorable_type"
    t.bigint "sponsorable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sponsorable_type", "sponsorable_id"], name: "index_sponsorships_on_sponsorable"
  end

  create_table "star_distances", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.bigint "star_id", null: false
    t.float "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_star_distances_on_celestial_body_id"
    t.index ["star_id"], name: "index_star_distances_on_star_id"
  end

  create_table "stars", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name", null: false
    t.string "type_of_star", null: false
    t.float "age", null: false
    t.float "mass", null: false
    t.float "radius", null: false
    t.integer "discovery_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "solar_system_id"
    t.float "luminosity"
    t.float "temperature"
    t.float "life"
    t.float "r_ecosphere"
    t.index ["identifier"], name: "index_stars_on_identifier", unique: true
  end

  create_table "surface_storages", force: :cascade do |t|
    t.bigint "inventory_id", null: false
    t.bigint "celestial_body_id", null: false
    t.bigint "settlement_id", null: false
    t.string "name"
    t.jsonb "properties", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_surface_storages_on_celestial_body_id"
    t.index ["inventory_id", "celestial_body_id"], name: "index_surface_storages_on_inventory_id_and_celestial_body_id", unique: true
    t.index ["inventory_id"], name: "index_surface_storages_on_inventory_id"
    t.index ["settlement_id"], name: "index_surface_storages_on_settlement_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.string "transaction_type", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["recipient_type", "recipient_id"], name: "index_transactions_on_recipient_type_and_recipient_id"
  end

  create_table "wormholes", force: :cascade do |t|
    t.bigint "solar_system_a_id", null: false
    t.bigint "solar_system_b_id", null: false
    t.integer "wormhole_type", default: 0, null: false
    t.integer "stability", default: 0
    t.integer "disruption_level", default: 0
    t.datetime "formation_date"
    t.float "decay_rate"
    t.integer "power_requirement"
    t.decimal "mass_limit", precision: 20, scale: 2, default: "0.0"
    t.decimal "mass_transferred_a", precision: 20, scale: 2, default: "0.0"
    t.decimal "mass_transferred_b", precision: 20, scale: 2, default: "0.0"
    t.boolean "point_a_stabilized", default: false
    t.boolean "point_b_stabilized", default: false
    t.boolean "hazard_zone", default: false
    t.boolean "exotic_resources", default: false
    t.boolean "traversed", default: false
    t.boolean "natural", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["solar_system_a_id"], name: "index_wormholes_on_solar_system_a_id"
    t.index ["solar_system_b_id"], name: "index_wormholes_on_solar_system_b_id"
  end

  add_foreign_key "access_points", "base_settlements", column: "lavatube_id"
  add_foreign_key "accounts", "colonies"
  add_foreign_key "atmospheres", "celestial_bodies"
  add_foreign_key "base_crafts", "base_settlements", column: "docked_at_id"
  add_foreign_key "base_crafts", "players"
  add_foreign_key "base_crafts", "wormholes", column: "stabilizing_wormhole_id"
  add_foreign_key "base_settlements", "accounts", column: "accounts_id"
  add_foreign_key "base_settlements", "colonies"
  add_foreign_key "base_settlements", "players"
  add_foreign_key "base_units", "base_units"
  add_foreign_key "biospheres", "celestial_bodies"
  add_foreign_key "blueprints", "players"
  add_foreign_key "celestial_bodies_alien_life_forms", "biospheres"
  add_foreign_key "celestial_bodies_materials", "celestial_bodies"
  add_foreign_key "celestial_bodies_materials", "materials"
  add_foreign_key "celestial_locations", "celestial_bodies"
  add_foreign_key "colonies", "celestial_bodies"
  add_foreign_key "cyclers", "base_crafts"
  add_foreign_key "dwarf_planets", "solar_systems"
  add_foreign_key "environments", "biomes"
  add_foreign_key "environments", "celestial_bodies", column: "celestial_bodies_id"
  add_foreign_key "gases", "atmospheres"
  add_foreign_key "geological_materials", "geospheres"
  add_foreign_key "geospheres", "celestial_bodies"
  add_foreign_key "hydrospheres", "celestial_bodies"
  add_foreign_key "items", "inventories"
  add_foreign_key "items", "items", column: "container_id"
  add_foreign_key "liquid_materials", "hydrospheres"
  add_foreign_key "market_conditions", "market_marketplaces"
  add_foreign_key "market_orders", "base_settlements"
  add_foreign_key "market_orders", "market_conditions"
  add_foreign_key "market_price_histories", "market_conditions"
  add_foreign_key "market_trades", "base_settlements", column: "buyer_settlement_id"
  add_foreign_key "market_trades", "base_settlements", column: "seller_settlement_id"
  add_foreign_key "material_piles", "surface_storages"
  add_foreign_key "materials", "celestial_bodies"
  add_foreign_key "orbital_relationships", "celestial_bodies"
  add_foreign_key "planet_biomes", "biomes"
  add_foreign_key "planet_biomes", "biospheres"
  add_foreign_key "plant_environments", "environments"
  add_foreign_key "plant_environments", "plants"
  add_foreign_key "skylights", "base_settlements", column: "lavatube_id"
  add_foreign_key "solar_systems", "galaxies"
  add_foreign_key "solar_systems", "stars", column: "current_star_id"
  add_foreign_key "star_distances", "celestial_bodies"
  add_foreign_key "star_distances", "stars"
  add_foreign_key "surface_storages", "base_settlements", column: "settlement_id"
  add_foreign_key "surface_storages", "celestial_bodies"
  add_foreign_key "surface_storages", "inventories"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "wormholes", "solar_systems", column: "solar_system_a_id"
  add_foreign_key "wormholes", "solar_systems", column: "solar_system_b_id"
end
