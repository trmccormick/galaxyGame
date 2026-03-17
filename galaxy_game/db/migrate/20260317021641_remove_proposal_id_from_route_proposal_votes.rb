class RemoveProposalIdFromRouteProposalVotes < ActiveRecord::Migration[7.0]
  def change
    remove_column :route_proposal_votes, :proposal_id, :integer
  end
end
