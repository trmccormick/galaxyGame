class CreateCelestialBodiesSpheresCryospheres < ActiveRecord::Migration[7.0]
  def change
    create_table :celestial_bodies_spheres_cryospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.float :thickness # in meters
      t.json :composition # material composition
      t.boolean :artificial, default: false # natural vs engineered
      t.string :shell_type # 'ice', 'metallic', 'carbon_composite', 'hybrid'
      t.float :thermal_conductivity # W/m·K
      t.float :density # kg/m³
      t.boolean :convecting, default: false # does it have convective motion?
      t.json :properties # additional properties like tensile_strength, melting_point
      
      t.timestamps
    end
  end
end
