# app/services/insurance/insurance_service.rb
module Insurance
  class InsuranceService
    INSURANCE_TIERS = {
      basic:    { coverage: 0.5, premium: 0.05, deductible: 0.1 },  # 50% coverage, 5% premium, 10% deductible
      standard: { coverage: 0.75, premium: 0.10, deductible: 0.05 }, # 75% coverage, 10% premium, 5% deductible
      premium:  { coverage: 0.9, premium: 0.15, deductible: 0.02 }   # 90% coverage, 15% premium, 2% deductible
    }

    def self.calculate_premium(contract_value, tier, risk_factors = {})
      tier_data = INSURANCE_TIERS[tier.to_sym]
      return 0 unless tier_data

      base_premium = contract_value * tier_data[:premium]

      # Adjust for risk factors
      risk_multiplier = calculate_risk_multiplier(risk_factors)
      base_premium * risk_multiplier
    end

    def self.create_policy(insurance_corp, contract, contractor, tier)
      tier_data = INSURANCE_TIERS[tier.to_sym]
      return nil unless tier_data

      contract_value = contract.respond_to?(:value) ? contract.value : contract.quantity * 100 # Estimate

      premium = calculate_premium(contract_value, tier, assess_risk_factors(contract, contractor))

      InsurancePolicy.create!(
        insurance_corporation: insurance_corp,
        policy_holder: contractor,
        covered_contract: contract,
        policy_type: :logistics,
        coverage_amount: contract_value * tier_data[:coverage],
        premium_amount: premium,
        deductible: contract_value * tier_data[:deductible],
        coverage_percentage: tier_data[:coverage],
        risk_factors: assess_risk_factors(contract, contractor),
        status: :active
      )
    end

    def self.process_claim(policy, loss_amount, loss_details)
      return unless policy.active?

      payout = policy.payout_amount(loss_amount)
      return if payout <= 0

      policy.insurance_corporation.assess_claim(policy, loss_details.merge('loss_amount' => loss_amount))
    end

    def self.available_insurers
      Organizations::InsuranceCorporation.where('solvency_ratio >= ?', 0.1)
    end

    private

    def self.calculate_risk_multiplier(risk_factors)
      multiplier = 1.0

      # Route risk
      multiplier *= 1.5 if risk_factors['route_risk'].to_f > 0.7
      multiplier *= 1.2 if risk_factors['route_risk'].to_f > 0.5

      # Contractor reliability
      multiplier *= 0.8 if risk_factors['contractor_reliability'].to_f > 0.9
      multiplier *= 1.3 if risk_factors['contractor_reliability'].to_f < 0.5

      # Cargo value
      multiplier *= 1.2 if risk_factors['cargo_value'].to_f > 10000

      multiplier
    end

    def self.assess_risk_factors(contract, contractor)
      {
        route_risk: calculate_route_risk(contract),
        contractor_reliability: calculate_contractor_reliability(contractor),
        cargo_value: calculate_cargo_value(contract),
        contract_duration: calculate_contract_duration(contract)
      }
    end

    def self.calculate_route_risk(contract)
      # Simplified route risk calculation
      from_body = contract.from_settlement&.location&.celestial_body
      to_body = contract.to_settlement&.location&.celestial_body

      if from_body == to_body
        0.2 # Same body, low risk
      elsif from_body&.parent_body == to_body&.parent_body
        0.4 # Same system, medium risk
      else
        0.8 # Different systems, high risk
      end
    end

    def self.calculate_contractor_reliability(contractor)
      # Simplified reliability - would check past performance
      0.7 # Default neutral reliability
    end

    def self.calculate_cargo_value(contract)
      # Estimate cargo value
      contract.quantity * 100 # Simplified pricing
    end

    def self.calculate_contract_duration(contract)
      # Estimate duration in days
      7 # Default 7 days
    end
  end
end