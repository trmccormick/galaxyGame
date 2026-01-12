module CelestialBodies
  module MinorBodies
    class KuiperBeltObject < Comet
      # KBOs are large, icy bodies from the Kuiper Belt

      # Override activity: KBOs are not active unless perturbed
      def active?
        false
      end

      # Always set source region to Kuiper Belt
      def determine_source_region
        'Kuiper Belt'
      end

      # Example mining method for extracting volatiles
      def mine_volatiles(amount)
        return {} unless mass.present? && amount > 0
        extractable = [amount, mass].min
        # Reduce mass
        self.mass -= extractable
        save!
        # Return typical composition breakdown
        composition = {}
        TYPICAL_COMPOSITION.each do |k, v|
          composition[k] = extractable * (v / 100.0)
        end
        composition
      end
    end
  end
end
