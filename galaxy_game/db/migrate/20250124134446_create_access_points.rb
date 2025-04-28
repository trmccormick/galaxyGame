class CreateAccessPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :access_points do |t|
      t.string :name
      t.integer :size
      t.integer :position
      t.integer :access_type
      t.references :lavatube, null: false, foreign_key: { to_table: :base_settlements }

      t.timestamps
    end
  end
end
