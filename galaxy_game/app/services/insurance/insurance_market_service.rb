# app/services/insurance/insurance_market_service.rb
module Insurance
  class InsuranceMarketService
    def self.update_market_rates
      # Adjust NPC insurer rates based on market conditions
      Organizations::InsuranceCorporation.find_each do |insurer|
        next unless insurer.insurance_corporation? # Only process insurance corps

        market_share = calculate_market_share(insurer)
        loss_ratio = calculate_loss_ratio(insurer)

        # Adjust rates based on performance
        pricing_models = insurer.pricing_models || {}

        if loss_ratio > 1.2  # Losing money
          pricing_models['base_premium'] = (pricing_models['base_premium'] || 0.08) * 1.05
        elsif market_share < 0.1  # Losing market share
          pricing_models['base_premium'] = (pricing_models['base_premium'] || 0.08) * 0.98
        end

        insurer.update(pricing_models: pricing_models)
        insurer.manage_reserves
      end
    end

    def self.handle_insurer_bankruptcy(insurer)
      # Transfer policies to competing insurers
      active_insurers = Organizations::InsuranceCorporation.where.not(id: insurer.id)

      insurer.insurance_policies.active.each do |policy|
        # Find replacement insurer
        replacement = active_insurers.min_by { |i| calculate_distance_from_rates(i, insurer) }
        next unless replacement

        # Transfer policy
        policy.update(insurance_corporation: replacement)

        # Notify policy holder
        Rails.logger.info "[Insurance] Policy #{policy.id} transferred from bankrupt #{insurer.name} to #{replacement.name}"
      end

      # Pay out remaining reserves proportionally
      distribute_remaining_reserves(insurer)

      # Mark as bankrupt
      insurer.update(status: :bankrupt)
    end

    def self.seed_npc_insurers
      npc_insurers = [
        {
          name: "Galactic Insurance Consortium",
          identifier: "gic_insurance",
          organization_type: :insurance_corporation,
          risk_models: { logistics_risk: 0.02, cargo_risk: 0.05 },
          pricing_models: { base_premium: 0.08, risk_multiplier: 1.2 },
          reserve_requirements: { minimum_ratio: 0.15 },
          operational_data: { founded: Time.current, headquarters: "Luna" }
        },
        {
          name: "Luna Risk Management Corp",
          identifier: "lrmc_insurance",
          organization_type: :insurance_corporation,
          risk_models: { logistics_risk: 0.03, cargo_risk: 0.04 },
          pricing_models: { base_premium: 0.10, risk_multiplier: 1.1 },
          reserve_requirements: { minimum_ratio: 0.20 },
          operational_data: { founded: Time.current, headquarters: "Luna" }
        },
        {
          name: "Earth Transport Underwriters",
          identifier: "etu_insurance",
          organization_type: :insurance_corporation,
          risk_models: { logistics_risk: 0.025, cargo_risk: 0.045 },
          pricing_models: { base_premium: 0.09, risk_multiplier: 1.15 },
          reserve_requirements: { minimum_ratio: 0.18 },
          operational_data: { founded: Time.current, headquarters: "Earth" }
        }
      ]

      npc_insurers.each do |insurer_data|
        insurer = Organizations::InsuranceCorporation.find_or_create_by!(identifier: insurer_data[:identifier]) do |i|
          i.assign_attributes(insurer_data)
        end

        # Create financial accounts for the insurer
        create_insurer_accounts(insurer)
      end
    end

    private

    def self.calculate_market_share(insurer)
      total_policies = InsurancePolicy.count
      return 0 if total_policies == 0

      insurer.insurance_policies.count.to_f / total_policies
    end

    def self.calculate_loss_ratio(insurer)
      total_premiums = insurer.insurance_policies.sum(:premium_amount)
      total_claims = Claims::ClaimPayout.where(policy: insurer.insurance_policies).sum(:amount)

      return 0 if total_premiums == 0
      total_claims.to_f / total_premiums
    end

    def self.calculate_distance_from_rates(insurer_a, insurer_b)
      # Calculate how similar pricing models are
      a_rate = insurer_a.pricing_models['base_premium'] || 0.08
      b_rate = insurer_b.pricing_models['base_premium'] || 0.08

      (a_rate - b_rate).abs
    end

    def self.distribute_remaining_reserves(insurer)
      return unless insurer.reserve_account

      remaining_balance = insurer.reserve_account.balance
      return if remaining_balance <= 0

      # Distribute proportionally to policy holders
      active_policies = insurer.insurance_policies.active
      return if active_policies.empty?

      per_policy_amount = remaining_balance / active_policies.count

      active_policies.each do |policy|
        next unless per_policy_amount > 0

        Financial::Account.transaction do
          insurer.reserve_account.with_lock do
            policy.policy_holder.account.with_lock do
              transfer_amount = [per_policy_amount, insurer.reserve_account.balance].min

              insurer.reserve_account.balance -= transfer_amount
              policy.policy_holder.account.balance += transfer_amount

              insurer.reserve_account.save!
              policy.policy_holder.account.save!
            end
          end
        end
      end
    end

    def self.create_insurer_accounts(insurer)
      # Create reserve account
      reserve_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: insurer,
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )
      reserve_account.update(balance: 100000) # Starting reserves

      # Create premium account
      premium_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: insurer,
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )

      # Note: Accounts are accessed via methods on the insurer, not stored as attributes
    end
  end
end