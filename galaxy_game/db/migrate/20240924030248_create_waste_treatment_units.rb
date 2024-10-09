# db/migrate/20240923123500_create_waste_treatment_units.rb
class CreateWasteTreatmentUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :waste_treatment_units do |t|
      t.string :name, null: false
      t.jsonb :material_list, null: false, default: {}
      t.integer :power_required, null: false
      t.references :base_unit, foreign_key: true

      t.timestamps
    end
  end
end
