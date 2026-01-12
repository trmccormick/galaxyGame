class CreateBiologyLifeFormParents < ActiveRecord::Migration[7.0]
  def change
    create_table :biology_life_form_parents do |t|
      t.references :parent, null: false, foreign_key: { to_table: :biology_life_forms }
      t.references :child, null: false, foreign_key: { to_table: :biology_life_forms }
      t.timestamps
    end
    
    add_index :biology_life_form_parents, [:parent_id, :child_id], unique: true
  end
end
