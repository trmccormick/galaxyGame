class WormholeMaintenanceJob
  include Sidekiq::Job
  queue_as :default

  def perform
    # Update wormhole contract stability metrics
    update_wormhole_contract_metrics

    # Shift unstable wormholes
    Wormhole.fluctuating.find_each do |wormhole|
      WormholeShiftJob.perform_later(wormhole.id)
    end

    # Collapse old wormholes
    Wormhole.where(stability: :collapsing)
            .where("formation_date < ?", GameConstants::WORMHOLE_MAX_AGE.ago)
            .destroy_all

    # Schedule next maintenance
    WormholeMaintenanceJob.set(wait: GameConstants::WORMHOLE_MAINTENANCE_INTERVAL).perform_later
  end

  private

  def update_wormhole_contract_metrics
    contract_path = Rails.root.join('data', 'json-data', 'contract', 'wormhole_contract.json')
    return unless File.exist?(contract_path)

    contract = JSON.parse(File.read(contract_path))

    contract['link_registry'].each do |link|
      tax = link['stability_metrics']['maintenance_tax_em'].to_f
      
      # Apply Sabatier offset if active (reduces tax by 40% for local fuel production)
      if link['logistics'] && link['logistics']['sabatier_offset_active']
        tax *= 0.6  # 40% reduction
        Rails.logger.info "[WormholeMaintenance] Applied Sabatier offset to #{link['link_id']}: tax reduced to #{tax}"
      end
      
      environment = link['environment']

      if environment == 'Cold_Start'
        # Deduct from global expansion budget
        if contract['global_em_economy']['expansion_budget_em'].to_f >= tax
          contract['global_em_economy']['expansion_budget_em'] -= tax
        else
          # Not enough EM, perhaps mark as unstable or something
          Rails.logger.warn "[WormholeMaintenance] Insufficient EM for Cold_Start link #{link['link_id']}"
        end
      elsif environment == 'Hot_Start'
        # Deduct from residual EM
        residual = link['stability_metrics']['residual_em'].to_f
        if residual >= tax
          link['stability_metrics']['residual_em'] -= tax
        else
          # Switch to global budget or mark unstable
          if contract['global_em_economy']['expansion_budget_em'].to_f >= tax
            contract['global_em_economy']['expansion_budget_em'] -= tax
          else
            Rails.logger.warn "[WormholeMaintenance] Insufficient EM for Hot_Start link #{link['link_id']}"
          end
        end
      end

      # Update current burn rate
      contract['global_em_economy']['current_burn_rate_em'] += tax
    end

    # Save updated contract
    File.write(contract_path, JSON.pretty_generate(contract))
  end
end