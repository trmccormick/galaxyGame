class AddOrbitalAssociationToCraft < ActiveRecord::Migration[7.0]
  def change
    add_reference :base_crafts, :orbiting_celestial_body, foreign_key: { to_table: :celestial_bodies }, index: true
  end
end
