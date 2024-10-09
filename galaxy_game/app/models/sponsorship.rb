class Sponsorship < ApplicationRecord
    belongs_to :sponsorable, polymorphic: true
    has_many :dome_sponsorships
    has_many :domes, through: :dome_sponsorships
  
    validates :name, presence: true
    validates :status, inclusion: { in: %w[active ended] }
    validates :end_action, inclusion: { in: %w[transfer sell] }
  
    def end_sponsorship
      case end_action
      when 'transfer'
        transfer_assets_to_colony
      when 'sell'
        sell_assets
      end
      update(status: 'ended')
    end
  
    private
  
    def transfer_assets_to_colony
      # Logic to transfer assets (e.g., domes) to the colony
      colonies.each do |colony|
        colony.domes += domes
        domes.clear
      end
    end
  
    def sell_assets
      # Logic to handle asset sale
      # e.g., Adding sale proceeds to the sponsor's account
      sale_proceeds = calculate_sale_proceeds
      sponsorable.account.credit(sale_proceeds)
      domes.clear
    end
end
  