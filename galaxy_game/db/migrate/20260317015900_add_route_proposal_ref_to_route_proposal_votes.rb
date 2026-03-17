class AddRouteProposalRefToRouteProposalVotes < ActiveRecord::Migration[7.0]
  def change
    add_reference :route_proposal_votes, :route_proposal, null: false, foreign_key: true
  end
end
