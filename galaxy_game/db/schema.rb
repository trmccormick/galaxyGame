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

ActiveRecord::Schema[7.0].define(version: 2024_10_08_183429) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "settlement_id"
    t.decimal "balance", precision: 15, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["settlement_id"], name: "index_accounts_on_settlement_id"
  end

  create_table "atmospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.float "temperature", default: 0.0
    t.float "pressure", default: 0.0
    t.json "atmosphere_composition", default: {}
    t.float "total_atmospheric_mass", default: 0.0
    t.json "dust", default: {}
    t.integer "pollution", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_atmospheres_on_celestial_body_id"
  end

  create_table "base_units", force: :cascade do |t|
    t.string "name"
    t.string "unit_type"
    t.integer "capacity"
    t.integer "energy_cost"
    t.integer "production_rate"
    t.string "gas_type"
    t.json "resource_requirements"
    t.json "material_list"
    t.string "location_type"
    t.integer "location_id"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_base_units_on_owner"
  end

  create_table "biogas_generators", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "material_list", default: {}, null: false
    t.integer "power_required", null: false
    t.bigint "base_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_unit_id"], name: "index_biogas_generators_on_base_unit_id"
  end

  create_table "biomass_recyclers", force: :cascade do |t|
    t.string "name"
    t.jsonb "material_list"
    t.integer "power_required"
    t.bigint "base_unit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_unit_id"], name: "index_biomass_recyclers_on_base_unit_id"
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
    t.float "temperature_tropical", default: 273.15
    t.float "temperature_polar", default: 273.15
    t.integer "biome_count", default: 0, null: false
    t.text "biome_distribution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_biospheres_on_celestial_body_id"
  end

  create_table "celestial_bodies", force: :cascade do |t|
    t.string "name"
    t.decimal "size"
    t.decimal "gravity", precision: 10, scale: 2
    t.decimal "density", precision: 10, scale: 2
    t.decimal "orbital_period", precision: 10, scale: 2
    t.jsonb "gas_quantities", default: {}
    t.jsonb "materials", default: {}
    t.float "water_volume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "mass"
    t.float "radius"
    t.float "distance_from_star"
    t.integer "status", default: 0, null: false
    t.float "known_pressure"
    t.float "surface_area"
    t.float "volume"
    t.string "greenhouse_temp"
    t.string "polar_temp"
    t.string "tropic_temp"
    t.string "delta_t"
    t.string "ice_latitude"
    t.string "habitability_ratio"
    t.float "methane_concentration"
    t.float "ammonia_concentration"
    t.float "hydrogen_concentration"
    t.float "helium_concentration"
    t.string "type"
    t.float "surface_temperature"
    t.text "atmosphere_composition"
    t.boolean "geological_activity", default: false
    t.integer "solar_system_id"
    t.float "albedo"
    t.float "insolation"
    t.jsonb "crust", default: "{}"
    t.jsonb "mantle", default: "{}"
    t.jsonb "core", default: "{}"
    t.jsonb "gases", default: "{}"
    t.float "pressure", default: 0.0
    t.float "temperature", default: 0.0
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

  create_table "colonies", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "composting_units", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "material_list", default: {}, null: false
    t.integer "power_required", null: false
    t.bigint "base_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_unit_id"], name: "index_composting_units_on_base_unit_id"
  end

  create_table "computers", force: :cascade do |t|
    t.bigint "settlement_id"
    t.decimal "mining_power", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["settlement_id"], name: "index_computers_on_settlement_id"
  end

  create_table "dome_sponsorships", force: :cascade do |t|
    t.bigint "dome_id", null: false
    t.bigint "sponsorship_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dome_id"], name: "index_dome_sponsorships_on_dome_id"
    t.index ["sponsorship_id"], name: "index_dome_sponsorships_on_sponsorship_id"
  end

  create_table "domes", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.bigint "settlement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_capacity"
    t.integer "current_occupancy"
    t.index ["settlement_id"], name: "index_domes_on_settlement_id"
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
    t.bigint "planet_id", null: false
    t.float "temperature"
    t.float "pressure"
    t.float "humidity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["biome_id"], name: "index_environments_on_biome_id"
    t.index ["planet_id"], name: "index_environments_on_planet_id"
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

  create_table "geospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.json "crust", default: {}
    t.json "mantle", default: {}
    t.json "core", default: {}
    t.json "resources", default: {}
    t.float "temperature", default: 0.0
    t.float "pressure", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_geospheres_on_celestial_body_id"
  end

  create_table "hydrospheres", force: :cascade do |t|
    t.string "liquid_name"
    t.float "liquid_volume"
    t.float "oceans"
    t.float "lakes"
    t.float "rivers"
    t.float "ice"
    t.bigint "celestial_body_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "ocean_temp"
    t.float "lake_temp"
    t.float "river_temp"
    t.float "ice_temp"
    t.index ["celestial_body_id"], name: "index_hydrospheres_on_celestial_body_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "colony_id"
    t.string "name", null: false
    t.integer "material_type", null: false
    t.integer "quantity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "unit_id"
    t.index ["colony_id"], name: "index_inventories_on_colony_id"
    t.index ["unit_id"], name: "index_inventories_on_unit_id"
  end

  create_table "liquid_materials", force: :cascade do |t|
    t.string "name", null: false
    t.float "amount", default: 0.0, null: false
    t.bigint "hydrosphere_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hydrosphere_id"], name: "index_liquid_materials_on_hydrosphere_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "materials", force: :cascade do |t|
    t.string "name"
    t.float "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "celestial_body_id"
    t.index ["celestial_body_id"], name: "index_materials_on_celestial_body_id"
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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "satellites", force: :cascade do |t|
    t.bigint "settlement_id"
    t.decimal "mining_output", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["settlement_id"], name: "index_satellites_on_settlement_id"
  end

  create_table "settlements", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "player_id"
    t.index ["player_id"], name: "index_settlements_on_player_id"
  end

  create_table "solar_systems", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "current_star_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_star_id"], name: "index_solar_systems_on_current_star_id"
  end

  create_table "sponsorships", force: :cascade do |t|
    t.string "name"
    t.string "sponsorable_type"
    t.bigint "sponsorable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sponsorable_type", "sponsorable_id"], name: "index_sponsorships_on_sponsorable"
  end

  create_table "stars", force: :cascade do |t|
    t.string "name", null: false
    t.string "type_of_star", null: false
    t.float "age", null: false
    t.float "mass", null: false
    t.float "radius", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "solar_system_id"
    t.float "luminosity"
    t.float "temperature"
    t.float "life"
    t.float "r_ecosphere"
  end

  create_table "transactions", force: :cascade do |t|
    t.bigint "buyer_id"
    t.bigint "seller_id"
    t.decimal "amount", precision: 15, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_transactions_on_buyer_id"
    t.index ["seller_id"], name: "index_transactions_on_seller_id"
  end

  create_table "waste_treatment_units", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "material_list", default: {}, null: false
    t.integer "power_required", null: false
    t.bigint "base_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_unit_id"], name: "index_waste_treatment_units_on_base_unit_id"
  end

  add_foreign_key "accounts", "settlements"
  add_foreign_key "atmospheres", "celestial_bodies"
  add_foreign_key "biogas_generators", "base_units"
  add_foreign_key "biomass_recyclers", "base_units"
  add_foreign_key "biospheres", "celestial_bodies"
  add_foreign_key "celestial_bodies_materials", "celestial_bodies"
  add_foreign_key "celestial_bodies_materials", "materials"
  add_foreign_key "composting_units", "base_units"
  add_foreign_key "computers", "settlements"
  add_foreign_key "dome_sponsorships", "domes"
  add_foreign_key "dome_sponsorships", "sponsorships"
  add_foreign_key "domes", "settlements"
  add_foreign_key "dwarf_planets", "solar_systems"
  add_foreign_key "environments", "biomes"
  add_foreign_key "environments", "celestial_bodies", column: "planet_id"
  add_foreign_key "gases", "atmospheres"
  add_foreign_key "geospheres", "celestial_bodies"
  add_foreign_key "hydrospheres", "celestial_bodies"
  add_foreign_key "inventories", "base_units", column: "unit_id"
  add_foreign_key "inventories", "colonies"
  add_foreign_key "liquid_materials", "hydrospheres"
  add_foreign_key "materials", "celestial_bodies"
  add_foreign_key "orbital_relationships", "celestial_bodies"
  add_foreign_key "planet_biomes", "biomes"
  add_foreign_key "planet_biomes", "biospheres"
  add_foreign_key "plant_environments", "environments"
  add_foreign_key "plant_environments", "plants"
  add_foreign_key "satellites", "settlements"
  add_foreign_key "settlements", "players"
  add_foreign_key "solar_systems", "stars", column: "current_star_id"
  add_foreign_key "transactions", "settlements", column: "buyer_id"
  add_foreign_key "transactions", "settlements", column: "seller_id"
  add_foreign_key "waste_treatment_units", "base_units"
end
