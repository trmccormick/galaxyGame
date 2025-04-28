class CreateStarDistances < ActiveRecord::Migration[7.0]
  def change
    create_table :star_distances do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.references :star, null: false, foreign_key: true
      t.float :distance

      t.timestamps
    end
  end
end
