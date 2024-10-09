# db/migrate/20240923123615_create_biogas_generators.rb
class CreateBiogasGenerators < ActiveRecord::Migration[7.0]
  def change
    create_table :biogas_generators do |t|
      t.string :name, null: false
      t.jsonb :material_list, null: false, default: {}
      t.integer :power_required, null: false
      t.references :base_unit, foreign_key: true

      t.timestamps
    end
  end
end

