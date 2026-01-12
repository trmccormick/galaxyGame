module CelestialBodies
  class GasGiant < CelestialBody
      # Gas giants can't be terraformed in the traditional sense
      def terraformed?
        false
      end
    
      # Overriding habitability score for gas giants
      def habitability_score
        "Gas giants are not habitable."
      end

      # Access hydrogen concentration through atmosphere composition
      def hydrogen_concentration
        return nil unless atmosphere.present?
        
        # Check atmosphere composition first
        if atmosphere.composition && atmosphere.composition['H2']
          return atmosphere.composition['H2']['percentage'] || atmosphere.composition['H2']
        end
        
        # Check gases association
        hydrogen_gas = atmosphere.gases.find_by(name: 'Hydrogen') || atmosphere.gases.find_by(name: 'H2')
        return hydrogen_gas.concentration if hydrogen_gas&.respond_to?(:concentration)
        
        nil
      end

      # Access helium concentration through atmosphere composition
      def helium_concentration
        return nil unless atmosphere.present?
        
        # Check atmosphere composition first
        if atmosphere.composition && atmosphere.composition['He']
          return atmosphere.composition['He']['percentage'] || atmosphere.composition['He']
        end
        
        # Check gases association
        helium_gas = atmosphere.gases.find_by(name: 'Helium') || atmosphere.gases.find_by(name: 'He')
        return helium_gas.concentration if helium_gas&.respond_to?(:concentration)
        
        nil
      end
  end
end