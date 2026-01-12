# app/models/structures/habitation_facility.rb
module Structures
  class HabitationFacility < BaseStructure
    # A structure designed for human habitation
    # Contains sleeping quarters, common areas, life support connections
    
    private
    
    def set_structure_type
      self.structure_type = 'habitation_facility'
      self.structure_name = 'Habitation Facility'
    end
    
    def needs_atmosphere?
      true # People need air
    end
    
    def atmosphere_type
      'artificial' # Controlled environment
    end
  end
end