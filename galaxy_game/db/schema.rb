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

ActiveRecord::Schema[7.0].define(version: 2026_02_12_011654) do
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
    t.decimal "balance", precision: 20, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "colony_id"
    t.bigint "currency_id", default: 1, null: false
    t.integer "lock_version"
    t.index ["accountable_type", "accountable_id"], name: "index_accounts_on_accountable_type_and_accountable_id"
    t.index ["colony_id"], name: "index_accounts_on_colony_id"
    t.index ["currency_id"], name: "index_accounts_on_currency_id"
  end

  create_table "adapted_features", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.string "feature_id", null: false
    t.string "feature_type", null: false
    t.string "type", null: false
    t.string "status", default: "natural"
    t.datetime "adapted_at"
    t.datetime "discovered_at"
    t.integer "settlement_id"
    t.integer "discovered_by"
    t.integer "parent_feature_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "static_data"
    t.jsonb "operational_data", default: {}
    t.index ["celestial_body_id"], name: "index_adapted_features_on_celestial_body_id"
    t.index ["feature_id", "feature_type", "celestial_body_id"], name: "index_adapted_features_on_feature_and_body", unique: true
    t.index ["operational_data"], name: "index_adapted_features_on_operational_data", using: :gin
    t.index ["parent_feature_id"], name: "index_adapted_features_on_parent_feature_id"
    t.index ["type"], name: "index_adapted_features_on_type"
  end

  create_table "atmospheres", force: :cascade do |t|
    t.bigint "celestial_body_id"
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
    t.bigint "craft_id"
    t.bigint "structure_id"
    t.string "structure_type"
    t.index ["celestial_body_id"], name: "index_atmospheres_on_celestial_body_id"
    t.index ["craft_id"], name: "index_atmospheres_on_craft_id"
    t.index ["structure_id"], name: "index_atmospheres_on_structure_id"
    t.index ["structure_type", "structure_id"], name: "index_atmospheres_on_structure_type_and_structure_id"
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
    t.bigint "orbiting_celestial_body_id"
    t.decimal "size"
    t.index ["craft_type"], name: "index_base_crafts_on_craft_type"
    t.index ["docked_at_id"], name: "index_base_crafts_on_docked_at_id"
    t.index ["name"], name: "index_base_crafts_on_name"
    t.index ["operational_data"], name: "index_base_crafts_on_operational_data", using: :gin
    t.index ["orbiting_celestial_body_id"], name: "index_base_crafts_on_orbiting_celestial_body_id"
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

  create_table "base_rigs", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name"
    t.text "description"
    t.string "rig_type"
    t.integer "capacity"
    t.jsonb "operational_data"
    t.string "attachable_type"
    t.integer "attachable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_base_rigs_on_identifier", unique: true
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
    t.string "panel_type"
    t.jsonb "operational_data", default: {}
    t.index ["accounts_id"], name: "index_base_settlements_on_accounts_id"
    t.index ["base_settlements_type", "base_settlements_id"], name: "index_base_settlements_on_base_settlements"
    t.index ["colony_id"], name: "index_base_settlements_on_colony_id"
    t.index ["operational_data"], name: "index_base_settlements_on_operational_data", using: :gin
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

  create_table "biology_life_form_parents", force: :cascade do |t|
    t.bigint "parent_id", null: false
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_biology_life_form_parents_on_child_id"
    t.index ["parent_id", "child_id"], name: "index_biology_life_form_parents_on_parent_id_and_child_id", unique: true
    t.index ["parent_id"], name: "index_biology_life_form_parents_on_parent_id"
  end

  create_table "biology_life_forms", force: :cascade do |t|
    t.bigint "biosphere_id", null: false
    t.string "type"
    t.string "name", null: false
    t.integer "complexity", default: 0
    t.integer "domain", default: 0
    t.bigint "population", default: 1000
    t.jsonb "properties", default: {}
    t.string "preferred_biome"
    t.decimal "mass", precision: 10, scale: 6, default: "0.1"
    t.decimal "size_modifier", precision: 5, scale: 3, default: "1.0"
    t.decimal "metabolism_rate", precision: 5, scale: 3, default: "0.1"
    t.decimal "health_modifier", precision: 5, scale: 3, default: "1.0"
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
    t.index ["biosphere_id"], name: "index_biology_life_forms_on_biosphere_id"
    t.index ["type"], name: "index_biology_life_forms_on_type"
  end

  create_table "biomes", force: :cascade do |t|
    t.string "name", null: false
    t.int4range "temperature_range", null: false
    t.int4range "humidity_range", null: false
    t.text "description"
    t.string "climate_type"
    t.boolean "supports_vegetation", default: true
    t.float "base_productivity", default: 1.0
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
    t.integer "licensed_runs_remaining"
    t.index ["player_id"], name: "index_blueprints_on_player_id"
  end

  create_table "bond_repayments", force: :cascade do |t|
    t.bigint "bond_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "amount", precision: 20, scale: 4, null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bond_id"], name: "index_bond_repayments_on_bond_id"
    t.index ["currency_id"], name: "index_bond_repayments_on_currency_id"
  end

  create_table "bonds", force: :cascade do |t|
    t.string "issuer_type", null: false
    t.bigint "issuer_id", null: false
    t.string "holder_type", null: false
    t.bigint "holder_id", null: false
    t.bigint "currency_id", null: false
    t.decimal "amount", precision: 20, scale: 4, null: false
    t.decimal "interest_rate", precision: 5, scale: 2
    t.datetime "issued_at", null: false
    t.datetime "due_at"
    t.string "status", default: "issued", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_bonds_on_currency_id"
    t.index ["holder_type", "holder_id"], name: "index_bonds_on_holder"
    t.index ["issuer_type", "issuer_id"], name: "index_bonds_on_issuer"
  end

  create_table "celestial_bodies", force: :cascade do |t|
    t.string "identifier", null: false
    t.string "name"
    t.string "type"
    t.decimal "size", precision: 38, scale: 10
    t.decimal "gravity", precision: 38, scale: 10
    t.decimal "density", precision: 38, scale: 10
    t.decimal "orbital_period", precision: 38, scale: 10
    t.decimal "mass", precision: 38, scale: 10
    t.decimal "radius", precision: 15, scale: 5
    t.decimal "axial_tilt", precision: 5, scale: 2
    t.decimal "escape_velocity", precision: 38, scale: 10
    t.decimal "semi_major_axis", precision: 38, scale: 10
    t.decimal "surface_area", precision: 22, scale: 5
    t.decimal "volume", precision: 30, scale: 5
    t.integer "status", default: 0, null: false
    t.decimal "known_pressure", precision: 10, scale: 5, default: "0.0", null: false
    t.bigint "parent_celestial_body_id"
    t.jsonb "properties", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "rotational_period", precision: 10, scale: 4
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
    t.integer "origin_body_id"
    t.string "composition_type"
    t.index ["identifier"], name: "index_celestial_bodies_on_identifier", unique: true
    t.index ["origin_body_id"], name: "index_celestial_bodies_on_origin_body_id"
    t.index ["parent_celestial_body_id"], name: "index_celestial_bodies_on_parent_celestial_body_id"
    t.index ["rotational_period"], name: "index_celestial_bodies_on_rotational_period"
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
    t.jsonb "properties", default: {}
    t.index ["celestial_body_id"], name: "index_celestial_bodies_materials_on_celestial_body_id"
    t.index ["material_id"], name: "index_celestial_bodies_materials_on_material_id"
  end

  create_table "celestial_bodies_spheres_cryospheres", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.float "thickness"
    t.json "composition"
    t.boolean "artificial", default: false
    t.string "shell_type"
    t.float "thermal_conductivity"
    t.float "density"
    t.boolean "convecting", default: false
    t.json "properties"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_celestial_bodies_spheres_cryospheres_on_celestial_body_id"
  end

  create_table "celestial_locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "coordinates", null: false
    t.string "locationable_type"
    t.bigint "locationable_id"
    t.bigint "celestial_body_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "altitude", precision: 15, scale: 2
    t.jsonb "environmental_data"
    t.index ["altitude"], name: "index_celestial_locations_on_altitude"
    t.index ["celestial_body_id", "coordinates"], name: "unique_coordinates_per_celestial_body", unique: true
    t.index ["celestial_body_id"], name: "index_celestial_locations_on_celestial_body_id"
    t.index ["locationable_type", "locationable_id"], name: "index_celestial_locations_on_locationable"
    t.index ["name"], name: "index_celestial_locations_on_name"
    t.check_constraint "altitude IS NULL OR altitude >= 0::numeric", name: "check_altitude_non_negative"
  end

  create_table "claims_claim_denials", force: :cascade do |t|
    t.bigint "policy_id", null: false
    t.string "reason"
    t.json "loss_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_claims_claim_denials_on_policy_id"
  end

  create_table "claims_claim_payouts", force: :cascade do |t|
    t.bigint "policy_id", null: false
    t.decimal "amount", precision: 15, scale: 2
    t.json "loss_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["policy_id"], name: "index_claims_claim_payouts_on_policy_id"
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

  create_table "component_production_jobs", force: :cascade do |t|
    t.bigint "settlement_id", null: false
    t.bigint "printer_unit_id", null: false
    t.string "component_blueprint_id", null: false
    t.string "component_name", null: false
    t.integer "quantity", default: 1, null: false
    t.string "status", default: "pending", null: false
    t.decimal "production_time_hours", precision: 10, scale: 2, null: false
    t.decimal "progress_hours", precision: 10, scale: 2, default: "0.0"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.jsonb "materials_consumed", default: {}
    t.decimal "import_cost_gcc", precision: 10, scale: 2, default: "0.0"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_blueprint_id"], name: "index_component_production_jobs_on_component_blueprint_id"
    t.index ["printer_unit_id"], name: "index_component_production_jobs_on_printer_unit_id"
    t.index ["settlement_id", "status"], name: "index_component_production_jobs_on_settlement_id_and_status"
    t.index ["settlement_id"], name: "index_component_production_jobs_on_settlement_id"
    t.index ["status"], name: "index_component_production_jobs_on_status"
  end

  create_table "consortium_memberships", force: :cascade do |t|
    t.bigint "consortium_id", null: false
    t.bigint "member_id", null: false
    t.decimal "investment_amount", precision: 20, scale: 2
    t.decimal "ownership_percentage", precision: 5, scale: 2
    t.integer "voting_power"
    t.string "membership_status", default: "active"
    t.datetime "joined_at"
    t.json "membership_terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consortium_id", "member_id"], name: "index_consortium_memberships_on_consortium_id_and_member_id", unique: true
    t.index ["consortium_id"], name: "index_consortium_memberships_on_consortium_id"
    t.index ["member_id"], name: "index_consortium_memberships_on_member_id"
  end

  create_table "construction_jobs", force: :cascade do |t|
    t.string "jobable_type", null: false
    t.bigint "jobable_id", null: false
    t.bigint "settlement_id", null: false
    t.integer "job_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.jsonb "target_values", default: {}
    t.datetime "start_date"
    t.datetime "completion_date"
    t.datetime "estimated_completion"
    t.string "priority", default: "normal"
    t.integer "completion_percentage", default: 0
    t.bigint "blueprint_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_id"], name: "index_construction_jobs_on_blueprint_id"
    t.index ["job_type", "status"], name: "index_construction_jobs_on_job_type_and_status"
    t.index ["jobable_type", "jobable_id"], name: "index_construction_jobs_on_jobable"
    t.index ["settlement_id"], name: "index_construction_jobs_on_settlement_id"
    t.index ["status"], name: "index_construction_jobs_on_status"
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "symbol", null: false
    t.boolean "is_system_currency", default: false, null: false
    t.integer "precision"
    t.string "issuer_type"
    t.bigint "issuer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issuer_type", "issuer_id"], name: "index_currencies_on_issuer_type_and_issuer_id"
    t.index ["name"], name: "index_currencies_on_name", unique: true
    t.index ["symbol"], name: "index_currencies_on_symbol", unique: true
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

  create_table "equipment_requests", force: :cascade do |t|
    t.string "requestable_type", null: false
    t.bigint "requestable_id", null: false
    t.string "equipment_type", null: false
    t.integer "quantity_requested", null: false
    t.integer "quantity_fulfilled", default: 0
    t.string "status", default: "pending"
    t.string "priority", default: "normal"
    t.datetime "fulfilled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_type", "status"], name: "index_equipment_requests_on_equipment_type_and_status"
    t.index ["requestable_type", "requestable_id"], name: "index_equipment_requests_on_requestable"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.bigint "from_currency_id", null: false
    t.bigint "to_currency_id", null: false
    t.decimal "rate", precision: 15, scale: 8, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_currency_id", "to_currency_id"], name: "index_exchange_rates_on_from_currency_id_and_to_currency_id", unique: true
    t.index ["from_currency_id"], name: "index_exchange_rates_on_from_currency_id"
    t.index ["to_currency_id"], name: "index_exchange_rates_on_to_currency_id"
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
    t.jsonb "base_values", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "regolith_depth", default: 0.0
    t.float "regolith_particle_size", default: 0.0
    t.float "weathering_rate", default: 0.0
    t.jsonb "plates", default: {}
    t.json "stored_volatiles"
    t.boolean "ice_tectonic_enabled", default: false
    t.float "total_geosphere_mass", default: 0.0
    t.jsonb "terrain_map"
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

  create_table "insurance_policies", force: :cascade do |t|
    t.bigint "insurance_corporation_id", null: false
    t.string "policy_holder_type", null: false
    t.bigint "policy_holder_id", null: false
    t.string "covered_contract_type", null: false
    t.bigint "covered_contract_id", null: false
    t.integer "policy_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.decimal "coverage_amount", precision: 15, scale: 2
    t.decimal "premium_amount", precision: 15, scale: 2
    t.decimal "deductible", precision: 15, scale: 2, default: "0.0"
    t.decimal "coverage_percentage", precision: 5, scale: 4
    t.json "risk_factors"
    t.json "underwriting_data"
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["covered_contract_type", "covered_contract_id"], name: "idx_ins_policies_contract"
    t.index ["covered_contract_type", "covered_contract_id"], name: "index_insurance_policies_on_covered_contract"
    t.index ["insurance_corporation_id"], name: "index_insurance_policies_on_insurance_corporation_id"
    t.index ["policy_holder_type", "policy_holder_id"], name: "idx_ins_policies_holder"
    t.index ["policy_holder_type", "policy_holder_id"], name: "index_insurance_policies_on_policy_holder"
    t.index ["status"], name: "index_insurance_policies_on_status"
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

  create_table "ledger_entries", force: :cascade do |t|
    t.bigint "from_account_id"
    t.bigint "to_account_id", null: false
    t.bigint "currency_id"
    t.bigint "item_id"
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.integer "entry_type", default: 0, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_ledger_entries_on_currency_id"
    t.index ["entry_type"], name: "index_ledger_entries_on_entry_type"
    t.index ["from_account_id", "to_account_id", "created_at"], name: "idx_ledger_entries_accounts_time"
    t.index ["from_account_id"], name: "index_ledger_entries_on_from_account_id"
    t.index ["item_id"], name: "index_ledger_entries_on_item_id"
    t.index ["to_account_id"], name: "index_ledger_entries_on_to_account_id"
  end

  create_table "liquid_materials", force: :cascade do |t|
    t.string "name", null: false
    t.float "amount", default: 0.0, null: false
    t.bigint "hydrosphere_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hydrosphere_id"], name: "index_liquid_materials_on_hydrosphere_id"
  end

  create_table "logistics_contracts", force: :cascade do |t|
    t.bigint "from_settlement_id", null: false
    t.bigint "to_settlement_id", null: false
    t.string "material"
    t.decimal "quantity"
    t.string "transport_method"
    t.integer "status"
    t.datetime "scheduled_at"
    t.datetime "completed_at"
    t.json "operational_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider_name"
    t.decimal "shipping_cost", precision: 10, scale: 2
    t.datetime "started_at"
    t.bigint "provider_id"
    t.index ["from_settlement_id"], name: "index_logistics_contracts_on_from_settlement_id"
    t.index ["provider_id"], name: "index_logistics_contracts_on_provider_id"
    t.index ["to_settlement_id"], name: "index_logistics_contracts_on_to_settlement_id"
  end

  create_table "logistics_providers", force: :cascade do |t|
    t.string "name", null: false
    t.string "identifier", null: false
    t.decimal "base_fee_per_kg", precision: 10, scale: 4, default: "1.0", null: false
    t.integer "reliability_rating", default: 3, null: false
    t.decimal "speed_multiplier", precision: 5, scale: 2, default: "1.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "organization_id", null: false
    t.index ["identifier"], name: "index_logistics_providers_on_identifier", unique: true
    t.index ["name"], name: "index_logistics_providers_on_name", unique: true
    t.index ["organization_id"], name: "index_logistics_providers_on_organization_id"
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
    t.bigint "settlement_id"
    t.index ["settlement_id"], name: "index_market_marketplaces_on_settlement_id"
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
    t.datetime "fulfilled_at"
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

  create_table "market_settings", force: :cascade do |t|
    t.decimal "transportation_cost_per_kg"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "market_supply_chains", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "market_order_id"
    t.string "sourceable_type", null: false
    t.bigint "sourceable_id", null: false
    t.string "destinationable_type", null: false
    t.bigint "destinationable_id", null: false
    t.string "resource_name"
    t.decimal "volume"
    t.string "status"
    t.index ["destinationable_type", "destinationable_id"], name: "index_market_supply_chains_on_destinationable"
    t.index ["sourceable_type", "sourceable_id"], name: "index_market_supply_chains_on_sourceable"
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
    t.string "fee_type", null: false
    t.decimal "percentage", precision: 5, scale: 2
    t.decimal "fixed_amount", precision: 15, scale: 2
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

  create_table "material_processing_jobs", force: :cascade do |t|
    t.bigint "settlement_id", null: false
    t.bigint "unit_id", null: false
    t.string "processing_type"
    t.string "input_material"
    t.decimal "input_amount"
    t.jsonb "output_materials"
    t.string "status"
    t.datetime "start_date"
    t.datetime "estimated_completion"
    t.datetime "completion_date"
    t.jsonb "operational_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "progress_hours"
    t.decimal "production_time_hours"
    t.index ["settlement_id"], name: "index_material_processing_jobs_on_settlement_id"
    t.index ["unit_id"], name: "index_material_processing_jobs_on_unit_id"
  end

  create_table "material_requests", force: :cascade do |t|
    t.string "requestable_type", null: false
    t.bigint "requestable_id", null: false
    t.string "material_name", null: false
    t.decimal "quantity_requested", precision: 10, scale: 2, null: false
    t.decimal "quantity_fulfilled", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "pending"
    t.string "priority", default: "normal"
    t.datetime "fulfilled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_name", "status"], name: "index_material_requests_on_material_name_and_status"
    t.index ["requestable_type", "requestable_id"], name: "index_material_requests_on_requestable"
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

  create_table "mega_projects", force: :cascade do |t|
    t.string "name", null: false
    t.integer "project_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.bigint "settlement_id", null: false
    t.bigint "project_manager_id"
    t.datetime "deadline", null: false
    t.decimal "budget_gcc", precision: 15, scale: 2, null: false
    t.jsonb "material_requirements", default: {}, null: false
    t.jsonb "progress_data", default: {}, null: false
    t.jsonb "project_metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deadline"], name: "index_mega_projects_on_deadline"
    t.index ["project_manager_id"], name: "index_mega_projects_on_project_manager_id"
    t.index ["project_type"], name: "index_mega_projects_on_project_type"
    t.index ["settlement_id", "status"], name: "index_mega_projects_on_settlement_id_and_status"
    t.index ["settlement_id"], name: "index_mega_projects_on_settlement_id"
    t.index ["status"], name: "index_mega_projects_on_status"
  end

  create_table "migration_logs", force: :cascade do |t|
    t.bigint "unit_id", null: false
    t.bigint "robot_id", null: false
    t.integer "source_location_id"
    t.string "source_location_type"
    t.integer "target_location_id"
    t.string "target_location_type"
    t.string "migration_type"
    t.datetime "performed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["robot_id"], name: "index_migration_logs_on_robot_id"
    t.index ["unit_id"], name: "index_migration_logs_on_unit_id"
  end

  create_table "mining_logs", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.decimal "amount_mined"
    t.datetime "mined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", default: "GCC"
    t.json "operational_details", default: {}
    t.json "job_metadata", default: {}
    t.index ["currency"], name: "index_mining_logs_on_currency"
    t.index ["mined_at"], name: "index_mining_logs_on_mined_at"
    t.index ["owner_type", "owner_id"], name: "index_mining_logs_on_owner"
    t.index ["owner_type", "owner_id"], name: "index_mining_logs_on_owner_type_and_owner_id"
  end

  create_table "missions", force: :cascade do |t|
    t.string "identifier", null: false
    t.bigint "settlement_id", null: false
    t.integer "status", default: 0
    t.integer "progress", default: 0
    t.text "operational_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "completion_date"
    t.string "mission_type"
    t.index ["identifier"], name: "index_missions_on_identifier", unique: true
    t.index ["settlement_id"], name: "index_missions_on_settlement_id"
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

  create_table "orbital_construction_projects", force: :cascade do |t|
    t.bigint "station_id", null: false
    t.string "craft_blueprint_id", null: false
    t.integer "status", default: 0, null: false
    t.float "progress_percentage", default: 0.0
    t.jsonb "required_materials", default: {}
    t.jsonb "delivered_materials", default: {}
    t.datetime "construction_started_at"
    t.datetime "completed_at"
    t.datetime "estimated_completion_time"
    t.jsonb "project_metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["station_id", "status"], name: "index_orbital_construction_projects_on_station_id_and_status"
    t.index ["station_id"], name: "index_orbital_construction_projects_on_station_id"
    t.index ["status"], name: "index_orbital_construction_projects_on_status"
  end

  create_table "orbital_relationships", force: :cascade do |t|
    t.string "primary_body_type", null: false
    t.bigint "primary_body_id", null: false
    t.string "secondary_body_type", null: false
    t.bigint "secondary_body_id", null: false
    t.float "distance"
    t.decimal "semi_major_axis", precision: 20, scale: 2
    t.decimal "eccentricity", precision: 8, scale: 6, default: "0.0"
    t.decimal "inclination", precision: 8, scale: 4, default: "0.0"
    t.decimal "orbital_period", precision: 10, scale: 2
    t.decimal "argument_of_periapsis", precision: 8, scale: 4
    t.decimal "longitude_of_ascending_node", precision: 8, scale: 4
    t.decimal "mean_anomaly_at_epoch", precision: 8, scale: 4
    t.string "relationship_type", null: false
    t.datetime "epoch_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["primary_body_type", "primary_body_id", "relationship_type"], name: "index_orbital_relationships_on_primary_and_type"
    t.index ["primary_body_type", "primary_body_id", "secondary_body_type", "secondary_body_id"], name: "index_orbital_relationships_unique_pair", unique: true
    t.index ["primary_body_type", "primary_body_id"], name: "index_orbital_relationships_on_primary"
    t.index ["primary_body_type", "primary_body_id"], name: "index_orbital_relationships_on_primary_body"
    t.index ["relationship_type"], name: "index_orbital_relationships_on_relationship_type"
    t.index ["secondary_body_type", "secondary_body_id"], name: "index_orbital_relationships_on_secondary"
    t.index ["secondary_body_type", "secondary_body_id"], name: "index_orbital_relationships_on_secondary_body"
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
    t.jsonb "properties"
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
    t.string "growth_temperature_range"
    t.string "growth_humidity_range"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "player_contracts", force: :cascade do |t|
    t.string "issuer_type", null: false
    t.bigint "issuer_id", null: false
    t.string "acceptor_type"
    t.bigint "acceptor_id"
    t.bigint "location_id"
    t.integer "contract_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.json "requirements"
    t.json "reward"
    t.json "collateral"
    t.bigint "collateral_account_id"
    t.json "security_terms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["acceptor_type", "acceptor_id"], name: "index_player_contracts_on_acceptor"
    t.index ["acceptor_type"], name: "index_player_contracts_on_acceptor_type"
    t.index ["collateral_account_id"], name: "index_player_contracts_on_collateral_account_id"
    t.index ["contract_type", "status"], name: "index_player_contracts_on_contract_type_and_status"
    t.index ["issuer_type", "issuer_id"], name: "index_player_contracts_on_issuer"
    t.index ["issuer_type"], name: "index_player_contracts_on_issuer_type"
    t.index ["location_id"], name: "index_player_contracts_on_location_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name", null: false
    t.string "active_location", null: false
    t.string "biography"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disconnected", default: false, null: false
    t.datetime "disconnected_at"
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

  create_table "route_proposal_votes", force: :cascade do |t|
    t.bigint "proposal_id", null: false
    t.bigint "voter_id", null: false
    t.string "vote", null: false
    t.integer "voting_power"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposal_id"], name: "index_route_proposal_votes_on_proposal_id"
    t.index ["voter_id"], name: "index_route_proposal_votes_on_voter_id"
  end

  create_table "route_proposals", force: :cascade do |t|
    t.bigint "proposer_id", null: false
    t.bigint "consortium_id", null: false
    t.string "target_system"
    t.text "justification"
    t.integer "estimated_traffic"
    t.decimal "proposal_fee_paid", precision: 20, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consortium_id"], name: "index_route_proposals_on_consortium_id"
    t.index ["proposer_id"], name: "index_route_proposals_on_proposer_id"
  end

  create_table "scheduled_arrivals", force: :cascade do |t|
    t.bigint "cycler_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cycler_id"], name: "index_scheduled_arrivals_on_cycler_id"
  end

  create_table "scheduled_departures", force: :cascade do |t|
    t.bigint "cycler_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cycler_id"], name: "index_scheduled_departures_on_cycler_id"
  end

  create_table "scheduled_imports", force: :cascade do |t|
    t.string "material"
    t.decimal "quantity"
    t.string "source"
    t.integer "destination_id", null: false
    t.decimal "transport_cost"
    t.datetime "delivery_eta"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "seal_printing_jobs", force: :cascade do |t|
    t.bigint "settlement_id", null: false
    t.bigint "printer_unit_id", null: false
    t.string "pressurization_target_type", null: false
    t.bigint "pressurization_target_id", null: false
    t.string "seal_type", null: false
    t.string "status", default: "pending", null: false
    t.decimal "production_time_hours", precision: 10, scale: 2, null: false
    t.decimal "progress_hours", precision: 10, scale: 2, default: "0.0"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.jsonb "materials_consumed", default: {}
    t.jsonb "position_data", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pressurization_target_type", "pressurization_target_id"], name: "index_seal_printing_jobs_on_pressurization_target"
    t.index ["pressurization_target_type", "pressurization_target_id"], name: "index_seal_printing_jobs_on_target"
    t.index ["printer_unit_id"], name: "index_seal_printing_jobs_on_printer_unit_id"
    t.index ["seal_type"], name: "index_seal_printing_jobs_on_seal_type"
    t.index ["settlement_id", "status"], name: "index_seal_printing_jobs_on_settlement_id_and_status"
    t.index ["settlement_id"], name: "index_seal_printing_jobs_on_settlement_id"
    t.index ["status"], name: "index_seal_printing_jobs_on_status"
  end

  create_table "segment_components", force: :cascade do |t|
    t.bigint "segment_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity", null: false
    t.string "component_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["component_type"], name: "index_segment_components_on_component_type"
    t.index ["item_id"], name: "index_segment_components_on_item_id"
    t.index ["segment_id"], name: "index_segment_components_on_segment_id"
  end

  create_table "shell_printing_jobs", force: :cascade do |t|
    t.bigint "settlement_id", null: false
    t.bigint "printer_unit_id", null: false
    t.bigint "inflatable_tank_id", null: false
    t.string "status", default: "pending", null: false
    t.decimal "production_time_hours", precision: 10, scale: 2, null: false
    t.decimal "progress_hours", precision: 10, scale: 2, default: "0.0"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.jsonb "materials_consumed", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inflatable_tank_id"], name: "index_shell_printing_jobs_on_inflatable_tank_id"
    t.index ["printer_unit_id"], name: "index_shell_printing_jobs_on_printer_unit_id"
    t.index ["settlement_id", "status"], name: "index_shell_printing_jobs_on_settlement_id_and_status"
    t.index ["settlement_id"], name: "index_shell_printing_jobs_on_settlement_id"
    t.index ["status"], name: "index_shell_printing_jobs_on_status"
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
    t.decimal "wormhole_capacity", precision: 20, scale: 2, default: "0.0", null: false
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

  create_table "special_missions", force: :cascade do |t|
    t.bigint "settlement_id", null: false
    t.string "material"
    t.decimal "required_quantity"
    t.decimal "reward_eap"
    t.decimal "bonus_multiplier", default: "1.0"
    t.integer "status"
    t.json "operational_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["settlement_id"], name: "index_special_missions_on_settlement_id"
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
    t.jsonb "properties", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "solar_system_id"
    t.float "luminosity"
    t.float "temperature"
    t.float "life"
    t.float "r_ecosphere"
    t.index ["identifier"], name: "index_stars_on_identifier", unique: true
    t.index ["solar_system_id"], name: "index_stars_on_solar_system_id"
  end

  create_table "structures", force: :cascade do |t|
    t.string "name", null: false
    t.string "structure_name", null: false
    t.string "structure_type", null: false
    t.bigint "settlement_id"
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.bigint "container_structure_id"
    t.string "location_type"
    t.bigint "location_id"
    t.integer "current_population", default: 0
    t.jsonb "operational_data", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "geological_feature_id"
    t.integer "total_segments"
    t.integer "enclosed_segments", default: 0
    t.float "coverage_percent", default: 0.0
    t.index ["container_structure_id"], name: "index_structures_on_container_structure_id"
    t.index ["geological_feature_id"], name: "index_structures_on_geological_feature_id"
    t.index ["location_type", "location_id"], name: "index_structures_on_location"
    t.index ["name"], name: "index_structures_on_name", unique: true
    t.index ["operational_data"], name: "index_structures_on_operational_data", using: :gin
    t.index ["owner_type", "owner_id"], name: "index_structures_on_owner"
    t.index ["settlement_id"], name: "index_structures_on_settlement_id"
    t.index ["structure_name", "structure_type"], name: "index_structures_on_structure_name_and_structure_type"
  end

  create_table "structures_planetary_umbilical_hubs", force: :cascade do |t|
    t.bigint "settlement_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["settlement_id"], name: "index_structures_planetary_umbilical_hubs_on_settlement_id"
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
    t.decimal "amount", precision: 15, scale: 8, null: false
    t.string "transaction_type", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "currency_id", default: 1, null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["currency_id"], name: "index_transactions_on_currency_id"
    t.index ["recipient_type", "recipient_id"], name: "index_transactions_on_recipient_type_and_recipient_id"
  end

  create_table "unit_assembly_jobs", force: :cascade do |t|
    t.bigint "base_settlement_id", null: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.string "unit_type", null: false
    t.integer "count", default: 1
    t.string "status", default: "pending"
    t.string "priority", default: "normal"
    t.string "blueprint_id"
    t.jsonb "specifications", default: {}
    t.datetime "start_date"
    t.datetime "completion_date"
    t.datetime "estimated_completion"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_settlement_id"], name: "index_unit_assembly_jobs_on_base_settlement_id"
    t.index ["owner_type", "owner_id"], name: "index_unit_assembly_jobs_on_owner"
    t.index ["unit_type", "status"], name: "index_unit_assembly_jobs_on_unit_type_and_status"
  end

  create_table "worldhouse_segments", force: :cascade do |t|
    t.bigint "worldhouse_id", null: false
    t.integer "segment_index", null: false
    t.string "name"
    t.float "length_m", null: false
    t.float "width_m", null: false
    t.string "status", default: "planned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_status", default: "uncovered"
    t.string "panel_type"
    t.datetime "construction_date"
    t.datetime "estimated_completion"
    t.jsonb "operational_data", default: {}
    t.index ["worldhouse_id", "segment_index"], name: "index_worldhouse_segments_on_worldhouse_id_and_segment_index", unique: true
    t.index ["worldhouse_id"], name: "index_worldhouse_segments_on_worldhouse_id"
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
    t.decimal "exotic_matter_production_rate", precision: 10, scale: 4, default: "0.0", null: false
    t.integer "shift_count", default: 0, null: false
    t.datetime "last_shift_at"
    t.boolean "collapse_charge_triggered", default: false, null: false
    t.boolean "artificial_station_built", default: false, null: false
    t.datetime "station_built_at"
    t.decimal "required_exotic_matter", precision: 15, scale: 2, default: "0.0"
    t.jsonb "required_construction_materials", default: {}
    t.index ["solar_system_a_id"], name: "index_wormholes_on_solar_system_a_id"
    t.index ["solar_system_b_id"], name: "index_wormholes_on_solar_system_b_id"
  end

  add_foreign_key "access_points", "adapted_features", column: "lavatube_id"
  add_foreign_key "accounts", "colonies"
  add_foreign_key "accounts", "currencies"
  add_foreign_key "adapted_features", "adapted_features", column: "parent_feature_id"
  add_foreign_key "adapted_features", "celestial_bodies"
  add_foreign_key "atmospheres", "base_crafts", column: "craft_id"
  add_foreign_key "atmospheres", "celestial_bodies"
  add_foreign_key "base_crafts", "base_settlements", column: "docked_at_id"
  add_foreign_key "base_crafts", "celestial_bodies", column: "orbiting_celestial_body_id"
  add_foreign_key "base_crafts", "players"
  add_foreign_key "base_crafts", "wormholes", column: "stabilizing_wormhole_id"
  add_foreign_key "base_settlements", "accounts", column: "accounts_id"
  add_foreign_key "base_settlements", "colonies"
  add_foreign_key "base_settlements", "players"
  add_foreign_key "base_units", "base_units"
  add_foreign_key "biology_life_form_parents", "biology_life_forms", column: "child_id"
  add_foreign_key "biology_life_form_parents", "biology_life_forms", column: "parent_id"
  add_foreign_key "biology_life_forms", "biospheres"
  add_foreign_key "biospheres", "celestial_bodies"
  add_foreign_key "blueprints", "players"
  add_foreign_key "bond_repayments", "bonds"
  add_foreign_key "bond_repayments", "currencies"
  add_foreign_key "bonds", "currencies"
  add_foreign_key "celestial_bodies", "celestial_bodies", column: "parent_celestial_body_id"
  add_foreign_key "celestial_bodies_alien_life_forms", "biospheres"
  add_foreign_key "celestial_bodies_materials", "celestial_bodies"
  add_foreign_key "celestial_bodies_materials", "materials"
  add_foreign_key "celestial_bodies_spheres_cryospheres", "celestial_bodies"
  add_foreign_key "celestial_locations", "celestial_bodies"
  add_foreign_key "colonies", "celestial_bodies"
  add_foreign_key "component_production_jobs", "base_settlements", column: "settlement_id"
  add_foreign_key "component_production_jobs", "base_units", column: "printer_unit_id"
  add_foreign_key "consortium_memberships", "organizations", column: "consortium_id"
  add_foreign_key "consortium_memberships", "organizations", column: "member_id"
  add_foreign_key "construction_jobs", "base_settlements", column: "settlement_id"
  add_foreign_key "construction_jobs", "blueprints"
  add_foreign_key "cyclers", "base_crafts"
  add_foreign_key "dwarf_planets", "solar_systems"
  add_foreign_key "environments", "biomes"
  add_foreign_key "environments", "celestial_bodies", column: "celestial_bodies_id"
  add_foreign_key "exchange_rates", "currencies", column: "from_currency_id"
  add_foreign_key "exchange_rates", "currencies", column: "to_currency_id"
  add_foreign_key "gases", "atmospheres"
  add_foreign_key "geological_materials", "geospheres"
  add_foreign_key "geospheres", "celestial_bodies"
  add_foreign_key "hydrospheres", "celestial_bodies"
  add_foreign_key "items", "inventories"
  add_foreign_key "items", "items", column: "container_id"
  add_foreign_key "ledger_entries", "accounts", column: "from_account_id"
  add_foreign_key "ledger_entries", "accounts", column: "to_account_id"
  add_foreign_key "ledger_entries", "currencies"
  add_foreign_key "ledger_entries", "items"
  add_foreign_key "liquid_materials", "hydrospheres"
  add_foreign_key "logistics_contracts", "base_settlements", column: "from_settlement_id"
  add_foreign_key "logistics_contracts", "base_settlements", column: "to_settlement_id"
  add_foreign_key "logistics_contracts", "logistics_providers", column: "provider_id"
  add_foreign_key "logistics_providers", "organizations"
  add_foreign_key "market_conditions", "market_marketplaces"
  add_foreign_key "market_marketplaces", "base_settlements", column: "settlement_id"
  add_foreign_key "market_orders", "base_settlements"
  add_foreign_key "market_orders", "market_conditions"
  add_foreign_key "market_price_histories", "market_conditions"
  add_foreign_key "market_trades", "base_settlements", column: "buyer_settlement_id"
  add_foreign_key "market_trades", "base_settlements", column: "seller_settlement_id"
  add_foreign_key "material_piles", "surface_storages"
  add_foreign_key "material_processing_jobs", "base_settlements", column: "settlement_id"
  add_foreign_key "material_processing_jobs", "base_units", column: "unit_id"
  add_foreign_key "materials", "celestial_bodies"
  add_foreign_key "mega_projects", "base_settlements", column: "settlement_id"
  add_foreign_key "mega_projects", "players", column: "project_manager_id"
  add_foreign_key "migration_logs", "base_units", column: "robot_id"
  add_foreign_key "migration_logs", "base_units", column: "unit_id"
  add_foreign_key "missions", "base_settlements", column: "settlement_id"
  add_foreign_key "orbital_construction_projects", "base_settlements", column: "station_id"
  add_foreign_key "planet_biomes", "biomes"
  add_foreign_key "planet_biomes", "biospheres"
  add_foreign_key "plant_environments", "environments"
  add_foreign_key "plant_environments", "plants"
  add_foreign_key "route_proposal_votes", "organizations", column: "voter_id"
  add_foreign_key "route_proposal_votes", "route_proposals", column: "proposal_id"
  add_foreign_key "route_proposals", "organizations", column: "consortium_id"
  add_foreign_key "route_proposals", "organizations", column: "proposer_id"
  add_foreign_key "scheduled_arrivals", "cyclers"
  add_foreign_key "scheduled_departures", "cyclers"
  add_foreign_key "scheduled_imports", "base_settlements", column: "destination_id"
  add_foreign_key "seal_printing_jobs", "base_settlements", column: "settlement_id"
  add_foreign_key "seal_printing_jobs", "base_units", column: "printer_unit_id"
  add_foreign_key "segment_components", "items"
  add_foreign_key "segment_components", "worldhouse_segments", column: "segment_id"
  add_foreign_key "shell_printing_jobs", "base_settlements", column: "settlement_id"
  add_foreign_key "shell_printing_jobs", "base_units", column: "inflatable_tank_id"
  add_foreign_key "shell_printing_jobs", "base_units", column: "printer_unit_id"
  add_foreign_key "skylights", "adapted_features", column: "lavatube_id"
  add_foreign_key "solar_systems", "galaxies"
  add_foreign_key "solar_systems", "stars", column: "current_star_id"
  add_foreign_key "special_missions", "base_settlements", column: "settlement_id"
  add_foreign_key "star_distances", "celestial_bodies"
  add_foreign_key "star_distances", "stars"
  add_foreign_key "structures", "adapted_features", column: "geological_feature_id"
  add_foreign_key "structures", "base_settlements", column: "settlement_id"
  add_foreign_key "structures", "structures", column: "container_structure_id"
  add_foreign_key "structures_planetary_umbilical_hubs", "base_settlements", column: "settlement_id"
  add_foreign_key "surface_storages", "base_settlements", column: "settlement_id"
  add_foreign_key "surface_storages", "celestial_bodies"
  add_foreign_key "surface_storages", "inventories"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "currencies"
  add_foreign_key "unit_assembly_jobs", "base_settlements"
  add_foreign_key "worldhouse_segments", "structures", column: "worldhouse_id"
  add_foreign_key "wormholes", "solar_systems", column: "solar_system_a_id"
  add_foreign_key "wormholes", "solar_systems", column: "solar_system_b_id"
end
