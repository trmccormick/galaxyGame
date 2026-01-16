module Organizations
  class BaseOrganization < ApplicationRecord
    self.table_name = "organizations"
    # Enums
    enum organization_type: {
      development_corporation: 0,
      corporation: 1,
      consortium: 2,  # NEW!
      government: 3,
      tax_authority: 4,
      insurance_corporation: 5
    }
    # Consortium memberships (as member)
    has_many :consortium_memberships, 
      foreign_key: :member_id,
      dependent: :destroy
    has_many :consortiums, through: :consortium_memberships

    # Consortium members (when this org IS a consortium)
    has_many :member_relationships,
      class_name: 'ConsortiumMembership',
      foreign_key: :consortium_id,
      dependent: :destroy
    has_many :members, through: :member_relationships

    def consortium?
      organization_type == 'consortium'
    end

    def is_npc?
      # Development Corporations are NPCs by default
      return true if development_corporation?
      # Or explicitly marked as NPC in operational_data
      operational_data&.dig('is_npc') == true
    end

    # Associations
    has_many :accounts, as: :accountable, class_name: 'Financial::Account'
    attr_accessor :resources, :projects, :profits, :tax_rate

    def account
      accounts.first
    end

    after_initialize :set_game_defaults, if: :new_record?

    def fund_project(project)
      # Logic to fund a project and allocate resources
    end

    def generate_profit(amount)
      @profits += amount
    end

    def invest_in_research(research)
      # Logic for investing in technological advancements
    end

    def manage_resources
      # Logic for resource extraction and distribution
    end

    # Text-based dashboard for CLI/testing
    def consortium_dashboard_for(player_corp)
      return unless consortium?
      members = member_relationships.active.includes(:member).order('ownership_percentage DESC')
      routes = respond_to?(:routes) ? routes.active : [] # Adjust as needed for your association
      player_membership = members.find { |m| m.member == player_corp }

      lines = []
      lines << "╔" + "═" * 61 + "╗"
      lines << "║           WORMHOLE TRANSIT CONSORTIUM#{' ' * 26}║"
      lines << "╠" + "═" * 61 + "╣"
      status = operational_data['membership_status'] || operational_data['status']
      lines << "║ Status: #{status.to_s.ljust(8)}   Capital: #{operational_data['total_capital'].to_s.gsub(/\B(?=(...)+(?!\d))/, ',')} GCC#{' ' * 12}║"
      lines << "║ Routes: #{routes.count.to_s.ljust(2)}                Members: #{members.count.to_s.ljust(2)}#{' ' * 28}║"
      lines << "╠" + "═" * 61 + "╣"
      lines << "║ FOUNDING MEMBERS#{' ' * 47}║"
      lines << "║ ┌" + "─" * 53 + "┐   ║"
      members.each do |m|
        seat = m.membership_terms['seat_on_board'] ? '✓' : '—'
        lines << "║ │ #{m.member.name.ljust(24)} #{sprintf('%5.1f', m.ownership_percentage)}%    Board Seat  #{seat.ljust(2)}     │   ║"
      end
      lines << "║ └" + "─" * 53 + "┘   ║"
      lines << "╠" + "═" * 61 + "╣"
      lines << "║ ACTIVE ROUTES#{' ' * 50}║"
      routes.each do |route|
        lines << "║ #{route.origin} → #{route.destination}      Traffic: #{route.traffic} kg/day  Revenue: #{route.revenue}   ║"
      end
      lines << "╠" + "═" * 61 + "╣"
      lines << "║ YOUR MEMBERSHIP BENEFITS#{' ' * 43}║"
      if player_membership
        daily_profit = player_membership.respond_to?(:daily_profit) ? player_membership.daily_profit : '—'
        discount = player_membership.membership_terms['preferential_rates'] ? (player_membership.membership_terms['preferential_rates'] * 100).to_i : 0
        lines << "║ • Profit Share: #{player_membership.ownership_percentage}% (#{daily_profit} GCC/day)#{' ' * 18}║"
        lines << "║ • Transit Fee Discount: #{discount}%#{' ' * 23}║"
        lines << "║ • Voting Power: #{player_membership.voting_power}#{' ' * 36}║"
        lines << "║ • Board Seat: #{player_membership.membership_terms['seat_on_board'] ? 'Yes' : 'No'}#{' ' * 38}║"
      else
        lines << "║ • Not a member#{' ' * 49}║"
      end
      lines << "╚" + "═" * 61 + "╝"
      lines.join("\n")
    end

    def distribute_consortium_profits(consortium)
      return unless consortium.consortium?
      revenue = consortium.calculate_revenue
      costs = consortium.calculate_costs
      net_profit = revenue - costs
      return if net_profit <= 0
      consortium.member_relationships.active.each do |membership|
        member_share = net_profit * (membership.ownership_percentage / 100.0)
        FinancialTransaction.create!(
          from_organization: consortium,
          to_organization: membership.member,
          amount: member_share,
          transaction_type: 'profit_distribution',
          description: "Consortium profit share for period"
        )
      end
    end

    private

    def set_game_defaults
      self.resources ||= []
      self.projects ||= []
      self.profits ||= 0
      self.tax_rate ||= 0
    end
  end
end