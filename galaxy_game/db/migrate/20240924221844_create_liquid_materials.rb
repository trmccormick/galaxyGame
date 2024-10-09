class CreateLiquidMaterials < ActiveRecord::Migration[6.1]
  def change
    create_table :liquid_materials do |t|
      t.string :name, null: false
      t.float :amount, null: false, default: 0
      t.references :hydrosphere, null: false, foreign_key: true

      t.timestamps
    end
  end
end

