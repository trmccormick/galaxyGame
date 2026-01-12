class CreateClaimsClaimPayouts < ActiveRecord::Migration[7.0]
  def change
    create_table :claims_claim_payouts do |t|
      t.references :policy, null: false
      t.decimal :amount, precision: 15, scale: 2
      t.json :loss_details
      t.timestamps
    end
  end
end