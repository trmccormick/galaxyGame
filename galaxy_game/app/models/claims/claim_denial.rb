# app/models/claims/claim_denial.rb
module Claims
  class ClaimDenial < ApplicationRecord
    belongs_to :policy, class_name: 'InsurancePolicy'

    attribute :reason, :string
    serialize :loss_details, JSON

    validates :reason, presence: true
  end
end