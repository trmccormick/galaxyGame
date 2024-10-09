class CreateBiomassRecyclers < ActiveRecord::Migration[7.0]
  def change
    create_table :biomass_recyclers do |t|
      t.string :name
      t.jsonb :material_list
      t.integer :power_required
      t.references :base_unit, null: false, foreign_key: true

      t.timestamps
    end
  end
end
