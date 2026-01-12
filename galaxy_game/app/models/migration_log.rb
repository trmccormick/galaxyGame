class MigrationLog < ApplicationRecord
  belongs_to :unit
  belongs_to :robot
end
