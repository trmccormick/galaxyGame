class AddFieldsToStars < ActiveRecord::Migration[6.0]
  def change
    add_column :stars, :solar_system_id, :integer
    add_column :stars, :luminosity, :float
    add_column :stars, :temperature, :float
    add_column :stars, :life, :float
    add_column :stars, :r_ecosphere, :float

    # Optional: If you want to enforce some constraints on the columns
    change_column_null :stars, :name, false
    change_column_null :stars, :type_of_star, false
    change_column_null :stars, :age, false
    change_column_null :stars, :mass, false
    change_column_null :stars, :radius, false

    add_index :stars, :solar_system_id
  end
end
