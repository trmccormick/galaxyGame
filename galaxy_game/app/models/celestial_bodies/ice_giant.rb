module CelestialBodies
  class IceGiant < CelestialBody
      # Ice giants can't be terraformed in the traditional sense
      def terraformed?
        false
      end
    
      # Overriding habitability score for ice giants
      def habitability_score
        "Ice giants are not habitable."
      end

      # Access methane concentration through atmosphere composition
      def methane_concentration
        return nil unless atmosphere.present?
        
        # Check atmosphere composition first
        if atmosphere.composition && atmosphere.composition['CH4']
          return atmosphere.composition['CH4']['percentage'] || atmosphere.composition['CH4']
        end
        
        # Check gases association
        methane_gas = atmosphere.gases.find_by(name: 'Methane') || atmosphere.gases.find_by(name: 'CH4')
        return methane_gas.concentration if methane_gas&.respond_to?(:concentration)
        
        nil
      end

      # Access ammonia concentration through atmosphere composition
      def ammonia_concentration
        return nil unless atmosphere.present?
        
        # Check atmosphere composition first
        if atmosphere.composition && atmosphere.composition['NH3']
          return atmosphere.composition['NH3']['percentage'] || atmosphere.composition['NH3']
        end
        
        # Check gases association
        ammonia_gas = atmosphere.gases.find_by(name: 'Ammonia') || atmosphere.gases.find_by(name: 'NH3')
        return ammonia_gas.concentration if ammonia_gas&.respond_to?(:concentration)
        
        nil
      end
  end
end