class FixAccessPointsForeignKey < ActiveRecord::Migration[7.0]
  def change
    # Remove the incorrect foreign key constraint
    remove_foreign_key :access_points, :base_settlements, column: :lavatube_id

    # Add the correct foreign key constraint to adapted_features table
    add_foreign_key :access_points, :adapted_features, column: :lavatube_id
  end
end