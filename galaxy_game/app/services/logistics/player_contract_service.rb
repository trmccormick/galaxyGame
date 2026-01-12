# app/services/logistics/player_contract_service.rb
module Logistics
  class PlayerContractService
    def self.create_logistics_contract(contract_data)
      contract = PlayerContract.create!(contract_data)

      # Offer insurance options for courier contracts
      if contract.courier?
        insurance_options = generate_insurance_options(contract)
        { contract: contract, insurance_options: insurance_options }
      else
        { contract: contract, insurance_options: [] }
      end
    end

    def self.generate_insurance_options(contract)
      available_insurers = Insurance::InsuranceService.available_insurers

      available_insurers.map do |insurer|
        Insurance::InsuranceService::INSURANCE_TIERS.map do |tier_name, tier_data|
          premium = Insurance::InsuranceService.calculate_premium(
            contract.value,
            tier_name,
            contract.risk_factors
          )

          {
            insurer: insurer,
            tier: tier_name,
            premium: premium,
            coverage: tier_data[:coverage],
            deductible: tier_data[:deductible]
          }
        end
      end.flatten
    end

    def self.accept_contract(contract, acceptor, insurance_choice = nil)
      return false unless contract.open?

      PlayerContract.transaction do
        contract.update(status: :accepted, acceptor: acceptor)

        # Purchase insurance if requested
        if insurance_choice.present?
          purchase_insurance(contract, acceptor, insurance_choice)
        end

        # Handle collateral if required
        setup_collateral(contract, acceptor)

        true
      end
    rescue
      false
    end

    def self.complete_contract(contract)
      return false unless contract.accepted?

      PlayerContract.transaction do
        # Release collateral
        release_collateral(contract)

        # Pay reward
        pay_reward(contract)

        # Expire insurance policy
        contract.insurance_policy&.update(status: :expired)

        contract.update(status: :completed)
        true
      end
    rescue
      false
    end

    def self.fail_contract(contract, failure_reason = {})
      return false unless contract.accepted?

      PlayerContract.transaction do
        contract.update(status: :failed)

        # Forfeit collateral
        forfeit_collateral(contract)

        # Process insurance claim if applicable
        if contract.insurance_policy&.active?
          loss_amount = calculate_loss_amount(contract, failure_reason)
          Insurance::InsuranceService.process_claim(
            contract.insurance_policy,
            loss_amount,
            failure_reason
          )
        end

        # Update contractor reputation
        update_contractor_reputation(contract.acceptor, failure_reason)

        true
      end
    rescue
      false
    end

    private

    def self.purchase_insurance(contract, acceptor, insurance_choice)
      insurer = Organizations::InsuranceCorporation.find(insurance_choice[:insurer_id])
      tier = insurance_choice[:tier]

      policy = Insurance::InsuranceService.create_policy(insurer, contract, acceptor, tier)

      # Deduct premium from acceptor
      if acceptor.account.balance >= policy.premium_amount
        Financial::Account.transaction do
          acceptor.account.with_lock do
            insurer.premium_account.with_lock do
              acceptor.account.balance -= policy.premium_amount
              insurer.premium_account.balance += policy.premium_amount

              acceptor.account.save!
              insurer.premium_account.save!
            end
          end
        end
      end
    end

    def self.setup_collateral(contract, acceptor)
      return unless contract.collateral.present?

      collateral_amount = contract.collateral['amount'].to_f
      return if collateral_amount <= 0

      # Create collateral account or use existing
      collateral_account = Financial::Account.find_or_create_for_entity_and_currency(
        accountable_entity: contract,
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )

      # Transfer collateral from acceptor
      if acceptor.account.balance >= collateral_amount
        Financial::Account.transaction do
          acceptor.account.with_lock do
            collateral_account.with_lock do
              acceptor.account.balance -= collateral_amount
              collateral_account.balance += collateral_amount

              acceptor.account.save!
              collateral_account.save!
            end
          end
        end

        contract.update(collateral_account: collateral_account)
      end
    end

    def self.release_collateral(contract)
      return unless contract.collateral_account

      collateral_amount = contract.collateral_account.balance

      if collateral_amount > 0
        Financial::Account.transaction do
          contract.collateral_account.with_lock do
            contract.acceptor.account.with_lock do
              contract.acceptor.account.balance += collateral_amount
              contract.collateral_account.balance = 0

              contract.acceptor.account.save!
              contract.collateral_account.save!
            end
          end
        end
      end
    end

    def self.forfeit_collateral(contract)
      return unless contract.collateral_account

      collateral_amount = contract.collateral_account.balance

      if collateral_amount > 0
        # Transfer collateral to contract issuer
        Financial::Account.transaction do
          contract.collateral_account.with_lock do
            contract.issuer.account.with_lock do
              contract.issuer.account.balance += collateral_amount
              contract.collateral_account.balance = 0

              contract.issuer.account.save!
              contract.collateral_account.save!
            end
          end
        end
      end
    end

    def self.pay_reward(contract)
      reward_amount = contract.reward['credits'].to_f

      if reward_amount > 0
        Financial::Account.transaction do
          contract.issuer.account.with_lock do
            contract.acceptor.account.with_lock do
              contract.issuer.account.balance -= reward_amount
              contract.acceptor.account.balance += reward_amount

              contract.issuer.account.save!
              contract.acceptor.account.save!
            end
          end
        end
      end
    end

    def self.calculate_loss_amount(contract, failure_reason)
      case failure_reason['type']
      when 'cargo_lost'
        contract.value * 0.8  # 80% of contract value
      when 'late_delivery'
        contract.value * 0.2  # 20% penalty
      when 'abandoned'
        contract.value        # Full value
      else
        contract.value * 0.5  # Default 50%
      end
    end

    def self.update_contractor_reputation(contractor, failure_reason)
      # Simplified reputation update - would integrate with reputation system
      penalty = case failure_reason['type']
                when 'abandoned' then 0.3
                when 'cargo_lost' then 0.2
                when 'late_delivery' then 0.1
                else 0.05
                end

      Rails.logger.info "[Contract] Contractor #{contractor.name} reputation decreased by #{penalty}"
    end
  end
end