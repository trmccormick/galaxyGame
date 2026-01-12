# app/models/organizations/insurance_corporation.rb
module Organizations
  class InsuranceCorporation < BaseOrganization
    # Risk management
    has_many :insurance_policies, dependent: :destroy
    has_many :claims, through: :insurance_policies

    # Financial reserves - accessed via methods, not associations
    # belongs_to :reserve_account, class_name: 'Financial::Account', optional: true
    # belongs_to :premium_account, class_name: 'Financial::Account', optional: true

    # Risk assessment
    serialize :risk_models, JSON      # Underwriting algorithms
    serialize :pricing_models, JSON   # Premium calculation
    serialize :reserve_requirements, JSON

    # Market position
    attribute :market_share, :float, default: 0.0
    attribute :reputation_score, :float, default: 1.0
    attribute :solvency_ratio, :float, default: 1.0

    validates :solvency_ratio, numericality: { greater_than_or_equal_to: 0.1 } # Minimum 10% solvency

    # Insurance-specific methods
    def calculate_premium(contract_value, risk_factors)
      base_rate = pricing_models['base_premium'] || 0.08
      risk_multiplier = pricing_models['risk_multiplier'] || 1.2

      # Adjust for risk factors
      adjusted_rate = base_rate
      adjusted_rate *= risk_multiplier if high_risk_route?(risk_factors)
      adjusted_rate *= 0.9 if reliable_contractor?(risk_factors)

      contract_value * adjusted_rate
    end

    def assess_claim(policy, loss_details)
      # AI-driven claim assessment
      risk_score = calculate_risk_score(loss_details)
      if risk_score < 0.3
        approve_claim(policy, loss_details)
      elsif risk_score < 0.7
        investigate_claim(policy, loss_details)
      else
        deny_claim(policy, loss_details)
      end
    end

    def manage_reserves
      # Ensure solvency requirements
      total_liabilities = insurance_policies.active.sum(:coverage_amount)
      current_ratio = total_liabilities > 0 ? reserve_account.balance / total_liabilities : 1.0

      min_ratio = reserve_requirements['minimum_ratio'] || 0.15
      if current_ratio < min_ratio
        raise_additional_capital
      end

      update(solvency_ratio: current_ratio)
    end

    def reserve_account
      @reserve_account ||= Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: self,
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )
    end

    def premium_account
      @premium_account ||= Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: self,
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )
    end

    private

    def high_risk_route?(risk_factors)
      # Simplified risk assessment
      risk_factors['route_risk'].to_f > 0.7
    end

    def reliable_contractor?(risk_factors)
      # Check contractor standing
      risk_factors['contractor_reliability'].to_f > 0.8
    end

    def calculate_risk_score(loss_details)
      # Simplified risk scoring
      base_score = 0.5

      # Adjust based on loss circumstances
      base_score -= 0.2 if loss_details['cargo_recovered']
      base_score += 0.3 if loss_details['contractor_abandoned']

      [0, [1, base_score].min].max
    end

    def approve_claim(policy, loss_details)
      payout = policy.payout_amount(loss_details['loss_amount'])
      process_payout(policy, payout, loss_details)
    end

    def investigate_claim(policy, loss_details)
      # Flag for manual review - for now, approve at reduced rate
      payout = policy.payout_amount(loss_details['loss_amount']) * 0.8
      process_payout(policy, payout, loss_details)
    end

    def deny_claim(policy, loss_details)
      # Create denial record
      Claims::ClaimDenial.create!(
        policy: policy,
        reason: 'High risk circumstances',
        loss_details: loss_details
      )
    end

    def process_payout(policy, amount, loss_details)
      return if amount <= 0

      Financial::Account.transaction do
        reserve_account.with_lock do
          if reserve_account.balance >= amount
            reserve_account.balance -= amount
            policy.policy_holder.account.balance += amount

            reserve_account.save!
            policy.policy_holder.account.save!

            # Record the payout
            Claims::ClaimPayout.create!(
              policy: policy,
              amount: amount,
              loss_details: loss_details
            )

            policy.update(status: :claimed)
          end
        end
      end
    end

    def raise_additional_capital
      # Simplified capital raising - in reality would involve market mechanisms
      # For now, just log the need
      Rails.logger.warn "[Insurance] #{name} needs additional capital. Current solvency: #{solvency_ratio}"
    end
  end
end