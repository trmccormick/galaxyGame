# db/migrate/20240923123545_create_composting_units.rb
class CreateCompostingUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :composting_units do |t|
      t.string :name, null: false
      t.jsonb :material_list, null: false, default: {}
      t.integer :power_required, null: false
      t.references :base_unit, foreign_key: true

      t.timestamps
    end
  end
end
