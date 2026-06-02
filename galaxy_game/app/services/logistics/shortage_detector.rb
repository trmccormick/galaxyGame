# frozen_string_literal: true

module Logistics
  class ShortageDetector < BaseService
    
    # Detects shortages based on operational targets vs current inventory
    def self.detect_shortages(settlement)
      # 1. Check ISRU viability first (can't have shortages if not viable yet)
      viable = ISRUCapabilityManager.has_basic_isru?(settlement)
      
      return { 
        viable: false, 
        survival_shortages: [], 
        expansion_shortages: [] 
      } unless viable
      
      # 2. Retrieve Targets from operational_data hash
      survival_targets = settlement.operational_data[:survival_targets] || {}
      expansion_targets = settlement.operational_data[:expansion_targets] || {}
      
      # 3. Build current inventory map (Hash of MaterialType -> Quantity)
      current_stock = {}
      settlement.items.each do |item|
        next unless item.material_type # Skip if material_type is nil
        current_stock[item.material_type] = item.amount
      end
      
      survival_shortages = []
      expansion_shortages = []
      
      # 4. Process Survival Shortages (Critical)
      survival_targets.each do |material, target_qty|
        current = current_stock[material] || 0
        if current < target_qty
          survival_shortages << { 
            material: material, 
            need: target_qty, 
            have: current, 
            priority: 'critical'
          }
        end
      end
      
      # 5. Process Expansion Shortages (Only if surviving target met but expansion not)
      expansion_targets.each do |material, target_qty|
        current = current_stock[material] || 0
        survival_target_for_this = survival_targets[material] || 0
        
        # Only report expansion shortage if we are currently surviving (current >= survival_target)
        if current < target_qty && current >= survival_target_for_this
          expansion_shortages << { 
            material: material, 
            need: target_qty, 
            have: current, 
            priority: 'expansion'
          }
        end
      end
      
      # Sort by priority (critical first)
      all_shortages = survival_shortages + expansion_shortages
      all_shortages.sort_by! { |s| s[:priority] == 'critical' ? 0 : 1 }
      
      { 
        viable: true, 
        survival_shortages: survival_shortages, 
        expansion_shortages: expansion_shortages,
        total_shortages: all_shortages
      }
    end
    
    def self.has_basic_isru?(settlement)
      ISRUCapabilityManager.has_basic_isru?(settlement)
    end
  end
end
