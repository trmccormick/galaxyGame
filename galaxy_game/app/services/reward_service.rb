# app/services/reward_service.rb
class RewardService
  # Service for processing rewards from completed missions and contracts

  def self.pay_out(reward_data, recipient)
    return false unless reward_data && recipient

    case reward_data['type']
    when 'credits', 'gcc'
      pay_credits(reward_data, recipient)
    when 'resources'
      pay_resources(reward_data, recipient)
    when 'mixed'
      pay_mixed(reward_data, recipient)
    else
      Rails.logger.error "Unknown reward type: #{reward_data['type']}"
      false
    end
  end

  private

  def self.pay_credits(reward_data, recipient)
    amount = reward_data['amount'] || reward_data['credits']
    return false unless amount && amount > 0

    # Apply market adjustment if specified
    if reward_data['market_adjusted']
      amount = apply_market_adjustment(amount, reward_data)
    end

    # Create transaction record
    Transaction.create!(
      from_account: system_account,
      to_account: recipient_account(recipient),
      amount: amount,
      description: reward_data['description'] || 'Mission reward',
      transaction_type: :reward
    )

    true
  rescue StandardError => e
    Rails.logger.error "Failed to pay credits reward: #{e.message}"
    false
  end

  def self.pay_resources(reward_data, recipient)
    resources = reward_data['resources']
    return false unless resources.is_a?(Hash) && !resources.empty?

    settlement = find_recipient_settlement(recipient)
    return false unless settlement

    resources.each do |resource_name, quantity|
      settlement.add_inventory(resource_name, quantity)
    end

    true
  rescue StandardError => e
    Rails.logger.error "Failed to pay resources reward: #{e.message}"
    false
  end

  def self.pay_mixed(reward_data, recipient)
    # Handle mixed rewards (credits + resources)
    pay_credits(reward_data, recipient) && pay_resources(reward_data, recipient)
  end

  def self.apply_market_adjustment(base_amount, reward_data)
    # Apply market-based adjustments to reward amounts
    # This could factor in current market conditions, inflation, etc.
    adjustment_factor = reward_data['adjustment_factor'] || 1.0

    # Could integrate with market analysis here
    (base_amount * adjustment_factor).round(2)
  end

  def self.system_account
    # Return the system reward account
    @system_account ||= Account.find_or_create_by!(
      name: 'System Rewards',
      account_type: :system
    )
  end

  def self.recipient_account(recipient)
    case recipient
    when Player
      recipient.financial_account
    when Organization
      recipient.account
    else
      # For other entities, find or create an account
      Account.find_or_create_by!(
        name: "#{recipient.class.name} #{recipient.id}",
        account_type: :entity
      )
    end
  end

  def self.find_recipient_settlement(recipient)
    case recipient
    when Player
      recipient.primary_settlement
    when AIManager
      recipient.settlement
    else
      nil
    end
  end
end