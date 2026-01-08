class CreateRouteProposals < ActiveRecord::Migration[7.0]
  def change
    create_table :route_proposals do |t|
      t.references :proposer, null: false, foreign_key: { to_table: :organizations }
      t.references :consortium, null: false, foreign_key: { to_table: :organizations }
      t.string :target_system
      t.text :justification
      t.integer :estimated_traffic
      t.decimal :proposal_fee_paid, precision: 20, scale: 2
      t.timestamps
    end
  end
end
