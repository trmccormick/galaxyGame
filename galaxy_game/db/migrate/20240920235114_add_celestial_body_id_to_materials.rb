class AddCelestialBodyIdToMaterials < ActiveRecord::Migration[6.0]
  def change
    add_reference :materials, :celestial_body, foreign_key: true
  end
end
