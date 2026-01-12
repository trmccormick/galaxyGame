# app/models/claims/claim_payout.rb
module Claims
  class ClaimPayout < ApplicationRecord
    belongs_to :policy, class_name: 'InsurancePolicy'

    attribute :amount, :float
    serialize :loss_details, JSON

    validates :amount, numericality: { greater_than: 0 }
  end
end