class RouteProposalVote < ApplicationRecord
  belongs_to :route_proposal
  belongs_to :voter,
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :voter_id
  validates :vote, inclusion: { in: %w[approve reject abstain] }
end
