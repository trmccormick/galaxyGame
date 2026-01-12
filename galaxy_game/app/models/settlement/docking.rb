# app/models/settlement/docking.rb
module Settlement
  module Docking
    extend ActiveSupport::Concern

    included do
      # Docking specific associations and validations
    end

    # Basic docking methods
    def docking_status
      'available'
    end
  end
end