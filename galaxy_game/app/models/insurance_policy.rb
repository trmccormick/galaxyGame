# app/models/insurance_policy.rb
class InsurancePolicy < ApplicationRecord
  belongs_to :insurance_corporation, class_name: 'Organizations::InsuranceCorporation'
  belongs_to :policy_holder, polymorphic: true  # Contractor taking out insurance
  belongs_to :covered_contract, polymorphic: true  # Contract being insured

  enum policy_type: { logistics: 0, cargo: 1, liability: 2 }
  enum status: { active: 0, expired: 1, claimed: 2, cancelled: 3 }

  # Policy terms
  attribute :coverage_amount, :float
  attribute :premium_amount, :float
  attribute :deductible, :float, default: 0.0
  attribute :coverage_percentage, :float  # 0.0 to 1.0

  # Risk assessment
  serialize :risk_factors, JSON
  serialize :underwriting_data, JSON

  # Dates
  attribute :effective_date, :datetime
  attribute :expiration_date, :datetime

  validates :coverage_amount, :premium_amount, :coverage_percentage,
            numericality: { greater_than: 0 }
  validates :coverage_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 1 }

  before_create :set_dates

  def payout_amount(loss_amount)
    covered_loss = [loss_amount - deductible, 0].max
    [covered_loss * coverage_percentage, coverage_amount].min
  end

  def expired?
    Time.current > expiration_date
  end

  def active?
    status == 'active' && !expired?
  end

  private

  def set_dates
    self.effective_date ||= Time.current
    self.expiration_date ||= effective_date + 30.days  # Default 30-day policy
  end
end