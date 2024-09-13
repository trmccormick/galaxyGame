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

ActiveRecord::Schema[7.0].define(version: 2024_09_13_174517) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "biomes", force: :cascade do |t|
    t.string "name"
    t.daterange "temperature_range"
    t.daterange "humidity_range"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.float "mass"
    t.float "radius"
    t.float "distance_from_sun"
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
    t.string "type"
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

  create_table "orbital_relationships", force: :cascade do |t|
    t.bigint "celestial_body_id", null: false
    t.integer "sun_id", null: false
    t.float "distance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["celestial_body_id"], name: "index_orbital_relationships_on_celestial_body_id"
    t.index ["sun_id"], name: "index_orbital_relationships_on_sun_id"
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

  create_table "stars", force: :cascade do |t|
    t.string "name"
    t.string "type_of_star"
    t.float "age"
    t.float "mass"
    t.float "radius"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "units", force: :cascade do |t|
    t.string "name"
    t.string "unit_type"
    t.integer "capacity"
    t.integer "energy_cost"
    t.integer "production_rate"
    t.string "gas_type"
    t.json "resource_requirements"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "material_list"
    t.string "location_type"
    t.integer "location_id"
  end

  add_foreign_key "environments", "biomes"
  add_foreign_key "environments", "celestial_bodies", column: "planet_id"
  add_foreign_key "orbital_relationships", "celestial_bodies"
  add_foreign_key "plant_environments", "environments"
  add_foreign_key "plant_environments", "plants"
end
