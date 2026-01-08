class ConsortiumMembership < ApplicationRecord
  belongs_to :consortium, 
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :consortium_id

  belongs_to :member, 
    class_name: 'Organizations::BaseOrganization',
    foreign_key: :member_id

  validates :investment_amount, numericality: { greater_than: 0 }
  validates :ownership_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  validate :member_must_be_corporation

  scope :active, -> { where(membership_status: 'active') }
  scope :founding, -> { where("membership_terms->>'founding_member' = 'true'") }

  private
  def member_must_be_corporation
    unless member&.organization_type == 'corporation'
      errors.add(:member, 'must be a corporation')
    end
  end
end
