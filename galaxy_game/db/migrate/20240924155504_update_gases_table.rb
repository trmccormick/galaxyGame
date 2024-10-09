class UpdateGasesTable < ActiveRecord::Migration[7.0]
  def change
    remove_reference :gases, :celestial_body, index: true, foreign_key: true
    add_reference :gases, :atmosphere, null: false, foreign_key: true
  end
end

