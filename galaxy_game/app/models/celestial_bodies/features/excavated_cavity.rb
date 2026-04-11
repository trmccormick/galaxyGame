# app/models/celestial_bodies/features/excavated_cavity.rb
module CelestialBodies
  module Features
    class ExcavatedCavity < BaseFeature
      # Asteroid/Moon cavities are accessed via airlocks/shafts.
      include HasNaturalOpenings
      
      belongs_to :settlement, class_name: 'Settlement::BaseSettlement', optional: true
      
      # Link back to the physical rock to check its spin (Asteroid or SmallMoon)
      belongs_to :host_body, polymorphic: true, foreign_key: 'celestial_body_id'

      # DELEGATION: Essential for the physics logic below
      delegate :typical_rotation_period, to: :host_body, allow_nil: true
      
      # Set feature_type automatically
      before_validation :set_feature_type, on: :create
      
      # ============================================
      # DIMENSION ACCESSORS
      # ============================================
      # These define the "Internal Volume" for the Worldhouse to manage.
      
      def length_m
        static_data&.dig('dimensions', 'length_m') || 0
      end
      
      def width_m
        static_data&.dig('dimensions', 'width_m') || 0
      end
      
      def height_m
        static_data&.dig('dimensions', 'height_m') || 0
      end
      
      def estimated_volume_m3
        # Direct lookup or calculated fallback
        static_data&.dig('dimensions', 'estimated_volume_m3') || (length_m * width_m * height_m)
      end
      
      # ============================================
      # PHYSICS & ROTATION LOGIC
      # ============================================

      def structural_stress_factor
        # If no host body or rotation data, default to neutral stress
        return 1.0 if typical_rotation_period.blank?

        # Logic: If spin is high (short period), stress increases.
        # This affects the "Loss Rate" of materials like CNT panels.
        period_hours = typical_rotation_period * 24.0
        
        case period_hours
        when 0..2   then 2.5   # Critical stress (Fast spin)
        when 2..8   then 1.2   # High stress
        when 8..24  then 1.0   # Standard/Optimal
        else 1.5               # Low spin/Tidally locked (Affects specialized centrifuges)
        end
      end

      # ============================================
      # CONVERSION & SUITABILITY
      # ============================================
      
      def conversion_suitability
        static_data&.dig('conversion_suitability') || {}
      end
      
      def suitability_rating
        # Modified by physics
        rating = conversion_suitability['habitat'] || 0.9
        (rating * (1.0 / structural_stress_factor)).round(2)
      end
      
      def estimated_cost_multiplier
        # Base cost modified by stress (Higher stress = more expensive construction)
        base_multiplier = conversion_suitability['estimated_cost_multiplier'] || 1.0
        (base_multiplier * structural_stress_factor).round(2)
      end
      
      def advantages
        conversion_suitability['advantages'] || []
      end
      
      def challenges
        # Dynamic challenges based on rotation
        list = conversion_suitability['challenges'] || []
        list << "centrifugal_instability" if structural_stress_factor > 1.0
        list << "low_gravity_sedimentation" if structural_stress_factor > 1.4
        list.uniq
      end
      
      # ============================================
      # STRATEGIC & AI LOGIC
      # ============================================
      
      def priority
        static_data&.dig('priority')
      end
      
      def strategic_value
        static_data&.dig('strategic_value') || []
      end
      
      # ============================================
      # STATUS & UTILITY
      # ============================================
      
      def can_pressurize?
        # Matches LavaTube logic: must be enclosed and all structural openings sealed.
        enclosed? && all_openings_sealed?
      end

      def natural_shielding
        static_data&.dig('attributes', 'natural_shielding')
      end

      def thermal_stability
        static_data&.dig('attributes', 'thermal_stability')
      end

      private
      
      def set_feature_type
        self.feature_type = 'excavated_cavity'
      end
    end
  end
end