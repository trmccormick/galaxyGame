class WormholeConsortiumFormationService
  def self.form_consortium
    consortium = Organizations::BaseOrganization.find_by(identifier: 'WH-CONSORTIUM')
    
    # Core logistics corporations (always included)
    logistics_corps = ['ASTROLIFT', 'ZENITH', 'VECTOR']
    
    # Find all existing development corporations
    development_corps = Organizations::BaseOrganization.where(
      organization_type: :corporation
    ).where.not(
      identifier: logistics_corps
    ).pluck(:identifier)
    
    # Combine all founding members
    founding_members = logistics_corps + development_corps
    
    # Equal investment per member for simplicity
    investment_per_member = 5_000_000
    total_investment = founding_members.count * investment_per_member
    
    founding_investment = {}
    founding_members.each do |identifier|
      founding_investment[identifier] = investment_per_member
    end
    total_investment = founding_investment.values.sum
    founding_investment.each do |identifier, amount|
      member = Organizations::BaseOrganization.where(organization_type: :corporation).find_by(identifier: identifier)
      ownership_pct = (amount.to_f / total_investment * 100).round(2)
      voting_power = (ownership_pct * 100).to_i
      ConsortiumMembership.create!(
        consortium: consortium,
        member: member,
        investment_amount: amount,
        ownership_percentage: ownership_pct,
        voting_power: voting_power,
        joined_at: Time.current,
        membership_terms: {
          founding_member: true,
          seat_on_board: true,
          preferential_rates: 0.10
        }
      )
      member.operational_data['consortium_memberships'] ||= []
      member.operational_data['consortium_memberships'] << 'WH-CONSORTIUM'
      member.save!
    end
    consortium.update(
      operational_data: consortium.operational_data.merge(
        'status' => 'active',
        'founding_date' => Time.current.to_s,
        'total_capital' => total_investment,
        'founding_members' => founding_members
      )
    )
    
    # Generate dynamic event description
    member_descriptions = founding_members.map do |identifier|
      percentage = (investment_per_member.to_f / total_investment * 100).round(0)
      corporation = Organizations::BaseOrganization.find_by(identifier: identifier)
      name = corporation&.name || identifier
      "- #{name} (#{percentage}%)"
    end.join("\n    ")
    
    # GameEvent.create!(
    #   event_type: 'major_infrastructure',
    #   title: 'Wormhole Transit Consortium Formed',
    #   description: <<~DESC
    #     The major corporations have pooled resources to form the 
    #     Wormhole Transit Consortium. This multi-corporate entity will manage 
    #     artificial wormhole infrastructure across known space.
    #     Founding Members:
    #     #{member_descriptions}
    #     The Consortium is now accepting route petitions and membership applications.
    #   DESC
    # )
  end
end
