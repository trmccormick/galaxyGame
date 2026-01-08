class CreateRouteProposalVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :route_proposal_votes do |t|
      t.references :proposal, null: false, foreign_key: { to_table: :route_proposals }
      t.references :voter, null: false, foreign_key: { to_table: :organizations }
      t.string :vote, null: false
      t.integer :voting_power
      t.timestamps
    end
  end
end