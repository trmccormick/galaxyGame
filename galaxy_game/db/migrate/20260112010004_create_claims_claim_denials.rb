class CreateClaimsClaimDenials < ActiveRecord::Migration[7.0]
  def change
    create_table :claims_claim_denials do |t|
      t.references :policy, null: false
      t.string :reason
      t.json :loss_details
      t.timestamps
    end
  end
end