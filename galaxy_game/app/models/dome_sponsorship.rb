class DomeSponsorship < ApplicationRecord
    belongs_to :dome
    belongs_to :sponsorship
  
    validates :dome, presence: true
    validates :sponsorship, presence: true
end