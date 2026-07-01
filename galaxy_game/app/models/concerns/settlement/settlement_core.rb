module Settlement
  module SettlementCore
    extend ActiveSupport::Concern

    included do
      include GameConstants
      include FinancialManagement

      belongs_to :owner, polymorphic: true, optional: true
      belongs_to :colony,
                 class_name: 'Colony',
                 foreign_key: 'colony_id',
                 optional: true

      has_one :account,
              as: :accountable,
              class_name: 'Financial::Account',
              dependent: :destroy
      has_many :accounts,
               as: :accountable,
               class_name: 'Financial::Account'
      has_many :structures,
               class_name: 'Structures::BaseStructure',
               foreign_key: 'settlement_id'
      has_many :missions,
               class_name: 'Mission',
               foreign_key: 'settlement_id'

      has_one :inventory, as: :inventoryable, dependent: :destroy

      validates :name, presence: true
      validates :current_population,
                numericality: {
                  only_integer: true,
                  greater_than_or_equal_to: 0
                }
    end

    def orbital?
      is_a?(Settlement::OrbitalSettlement)
    end

    def gcc_account
      accounts.find_or_create_by(
        currency: Financial::Currency.find_by(symbol: 'GCC')
      )
    end

    def age_in_days
      ((Time.current - created_at) / 1.day).to_i
    end

    def accessible_by?(user)
      owner == user || (colony && colony.accessible_by?(user))
    end
  end
end
