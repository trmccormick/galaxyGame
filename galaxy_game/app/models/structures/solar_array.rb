# Structures that don't need atmosphere can opt out:
module Structures
  class SolarArray < BaseStructure
    private
    
    def needs_atmosphere?
      false # Solar arrays don't need life support
    end
  end
end