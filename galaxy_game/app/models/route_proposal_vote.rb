class RouteProposalVote < ApplicationRecord
  belongs_to :proposal, class_name: 'RouteProposal'
  belongs_to :voter,
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :voter_id
  validates :vote, inclusion: { in: %w[approve reject abstain] }
end
