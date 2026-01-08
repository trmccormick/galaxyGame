class WormholeConsortiumFormationService
  def self.form_consortium
    consortium = Organizations::BaseOrganization.find_by(identifier: 'WH-CONSORTIUM')
    founding_investment = {
      'ASTROLIFT' => 10_000_000,
      'ZENITH'    =>  7_500_000,
      'VECTOR'    =>  5_000_000,
    }
    total_investment = founding_investment.values.sum
    founding_investment.each do |identifier, amount|
      member = Organizations::Corporation.find_by(identifier: identifier)
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
        'founding_members' => founding_investment.keys
      )
    )
    GameEvent.create!(
      event_type: 'major_infrastructure',
      title: 'Wormhole Transit Consortium Formed',
      description: <<~DESC
        The major logistics corporations have pooled resources to form the 
        Wormhole Transit Consortium. This multi-corporate entity will manage 
        artificial wormhole infrastructure across known space.
        Founding Members:
        - AstroLift Logistics (40%)
        - Zenith Orbital (30%)
        - Vector Hauling (20%)
        The Consortium is now accepting route petitions and membership applications.
      DESC
    )
  end
end
