class CreateBiospheres < ActiveRecord::Migration[6.1]
  def change
    create_table :biospheres do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.timestamps
    end
  end
end
