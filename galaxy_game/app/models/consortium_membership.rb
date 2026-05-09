class ConsortiumMembership < ApplicationRecord
  belongs_to :consortium, 
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :consortium_id

  belongs_to :member, 
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :member_id

  validates :investment_amount, numericality: { greater_than: 0 }
  validates :ownership_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 100 }



  scope :active, -> { where(membership_status: 'active') }
  scope :founding, -> { where("membership_terms->>'founding_member' = 'true'") }

  # Removed member_must_be_corporation validation to allow any BaseOrganization as member
end
