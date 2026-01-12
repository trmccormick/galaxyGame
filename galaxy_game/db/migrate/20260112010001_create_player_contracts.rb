class CreatePlayerContracts < ActiveRecord::Migration[7.0]
  def change
    create_table :player_contracts do |t|
      t.references :issuer, polymorphic: true, null: false
      t.references :acceptor, polymorphic: true, null: true
      t.references :location, null: true
      t.integer :contract_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.json :requirements
      t.json :reward
      t.json :collateral
      t.references :collateral_account, null: true
      t.json :security_terms
      t.timestamps
    end

    add_index :player_contracts, [:contract_type, :status]
    add_index :player_contracts, :issuer_type
    add_index :player_contracts, :acceptor_type
  end
end