module Admin
  class OrganizationsController < ApplicationController
    def index
      # Load NPC Organizations (Development Corps + NPC Service Corps)
      @npc_organizations = Organizations::BaseOrganization
        .where(organization_type: [:development_corporation, :corporation])
        .includes(:accounts)
        .select(&:is_npc?)
        .sort_by(&:name)
      
      # Load Player Organizations (Player-owned corporations only)
      @player_organizations = Organizations::BaseOrganization
        .where(organization_type: :corporation)
        .includes(:accounts)
        .reject(&:is_npc?)
        .sort_by(&:name)
      
      # Load Consortiums (separate from individual organizations)
      @consortiums = Organizations::BaseOrganization
        .where(organization_type: :consortium)
        .includes(:accounts)
        .order(:name)
      
      @total_npc_count = @npc_organizations.count
      @total_player_count = @player_organizations.count
      @total_consortium_count = @consortiums.count
      
      # Count active logistics contracts for all organizations
      @active_contracts_count = Logistics::Contract.active.count
      
      # Load settlements owned by all organizations
      all_org_ids = @npc_organizations.pluck(:id) + @player_organizations.pluck(:id) + @consortiums.pluck(:id)
      @settlements_by_org = Settlement::BaseSettlement
        .where(owner_type: 'Organizations::BaseOrganization', owner_id: all_org_ids)
        .includes(:location)
        .group_by(&:owner_id)
      
      # Load active contracts for all organizations
      settlement_ids = Settlement::BaseSettlement
        .where(owner_type: 'Organizations::BaseOrganization', owner_id: all_org_ids)
        .pluck(:id)
      
      @active_contracts = Logistics::Contract.active
        .where('from_settlement_id IN (?) OR to_settlement_id IN (?)', settlement_ids, settlement_ids)
        .includes(:from_settlement, :to_settlement, :provider)
        .group_by { |c| [c.from_settlement&.owner_id, c.to_settlement&.owner_id].compact.first }
    end
    
    def operations
      # Load specific DC operations
      @dc = Organizations::BaseOrganization.find(params[:id])
      @settlements = Settlement::BaseSettlement.where(owner: @dc).includes(:location, :structures, :base_units)
      @active_contracts = Logistics::Contract.active
        .where('from_settlement_id IN (?) OR to_settlement_id IN (?)', @settlements.pluck(:id), @settlements.pluck(:id))
        .includes(:from_settlement, :to_settlement, :provider)
      @production_data = calculate_production_capabilities(@settlements)
    end
    
    private
    
    def calculate_production_capabilities(settlements)
      capabilities = []
      
      settlements.each do |settlement|
        # Count production structures
        structures = settlement.structures.group_by(&:structure_type)
        units = settlement.base_units.group_by(&:unit_type)
        
        capabilities << {
          settlement_name: settlement.name,
          location: settlement.location&.name,
          structures: structures.transform_values(&:count),
          units: units.transform_values(&:count),
          total_capacity: structures.sum { |_, v| v.count } + units.sum { |_, v| v.count }
        }
      end
      
      capabilities
    end
  end
end
