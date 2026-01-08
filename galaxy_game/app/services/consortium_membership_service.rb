class ConsortiumMembershipService
  def self.apply_for_membership(applicant, consortium, investment_amount)
    # Only corporations can apply
    unless applicant.is_a?(Organizations::BaseOrganization) && applicant.organization_type == 'corporation'
      return { success: false, reason: 'Only corporations can be consortium members' }
    end

    # Check eligibility
    return { success: false, reason: 'Insufficient investment' } if investment_amount < 1_000_000

    # Calculate new ownership stakes
    current_total = consortium.operational_data['total_capital']
    new_total = current_total + investment_amount
    new_ownership = (investment_amount.to_f / new_total * 100).round(2)

    # Dilute existing members proportionally
    dilution_factor = current_total.to_f / new_total
    consortium.member_relationships.active.each do |membership|
      membership.update(
        ownership_percentage: membership.ownership_percentage * dilution_factor,
        voting_power: (membership.ownership_percentage * dilution_factor * 100).to_i
      )
    end

    # Create new membership
    ConsortiumMembership.create!(
      consortium: consortium,
      member: applicant,
      investment_amount: investment_amount,
      ownership_percentage: new_ownership,
      voting_power: (new_ownership * 100).to_i,
      joined_at: Time.current,
      membership_terms: {
        founding_member: false,
        seat_on_board: new_ownership >= 5.0  # Board seat if >5% ownership
      }
    )

    # Update consortium capital
    consortium.operational_data['total_capital'] = new_total
    consortium.save!

    { success: true, ownership: new_ownership }
  end
end
