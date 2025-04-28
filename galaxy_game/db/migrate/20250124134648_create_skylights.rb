class CreateSkylights < ActiveRecord::Migration[7.0]
  def change
    create_table :skylights do |t|
      t.integer :diameter
      t.integer :position
      t.references :lavatube, null: false, foreign_key: { to_table: :base_settlements }

      t.timestamps
    end
  end
end
