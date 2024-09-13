class CreateSuns < ActiveRecord::Migration[7.0]
  def change
    create_table :suns do |t|
      t.string :name
      t.string :type
      t.float :age
      t.float :mass
      t.float :radius
      t.float :solar_constant

      t.timestamps
    end
  end
end
