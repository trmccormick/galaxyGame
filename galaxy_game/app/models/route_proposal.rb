class RouteProposal < ApplicationRecord
  belongs_to :proposer, 
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :proposer_id
  belongs_to :consortium,
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :consortium_id
  has_many :votes, class_name: 'RouteProposalVote'

  def calculate_vote_outcome
    total_voting_power = consortium.member_relationships.active.sum(:voting_power)
    votes_in_favor = votes.where(vote: 'approve').sum(:voting_power)
    approval_percentage = votes_in_favor.to_f / total_voting_power
    threshold = consortium.operational_data['governance']['approval_threshold']
    approval_percentage >= threshold
  end
end
