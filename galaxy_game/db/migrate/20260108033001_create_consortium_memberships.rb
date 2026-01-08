class CreateConsortiumMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :consortium_memberships do |t|
      t.references :consortium, null: false, foreign_key: { to_table: :organizations }
      t.references :member, null: false, foreign_key: { to_table: :organizations }
      t.decimal :investment_amount, precision: 20, scale: 2
      t.decimal :ownership_percentage, precision: 5, scale: 2
      t.integer :voting_power
      t.string :membership_status, default: 'active'
      t.datetime :joined_at
      t.json :membership_terms
      t.timestamps
    end
    add_index :consortium_memberships, [:consortium_id, :member_id], unique: true
  end
end