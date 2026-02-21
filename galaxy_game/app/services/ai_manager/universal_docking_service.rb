module AIManager
  class UniversalDockingService
    # Universal docking handshake between any two entities (craft, station, base)
    def dock(entity_a, entity_b)
      return false unless compatible_ports?(entity_a, entity_b)
      return false unless interface_match?(entity_a, entity_b)
      return false unless entity_a.has_available_docking_port? && entity_b.has_available_docking_port?
      # Assign docking relationship
      entity_a.docked_at = entity_b
      entity_a.save!
      # Hitchhiker logic for larger vessel (Cycler/Depot) based on physical size
      a_props = entity_a.respond_to?(:physical_properties) ? entity_a.physical_properties : {}
      b_props = entity_b.respond_to?(:physical_properties) ? entity_b.physical_properties : {}
      # Calculate volume as a proxy for size (length * width * height)
      a_volume = [a_props[:length_m], a_props[:width_m], a_props[:height_m]].all? ? a_props[:length_m].to_f * a_props[:width_m].to_f * a_props[:height_m].to_f : 0
      b_volume = [b_props[:length_m], b_props[:width_m], b_props[:height_m]].all? ? b_props[:length_m].to_f * b_props[:width_m].to_f * b_props[:height_m].to_f : 0
      if a_volume > 0 && b_volume > 0 && a_volume < b_volume && ["Long-Hull Cycler", "Orbital Depot", "Cycler", "Depot"].any? { |type| entity_b.craft_name&.include?(type) || entity_b.class.name.include?(type) }
        entity_a.enter_hitchhiker_state!(parent: entity_b)
        entity_a.save!
      end
      true
    end

    # Capability-based port validation
    def compatible_ports?(a, b)
      (a.blueprint_ports & b.blueprint_ports).any? { |port| port =~ /docking|external_module/ }
    end

    # Interface match for Standard_I_Beam_Ring
    def interface_match?(a, b)
      (a.interface_adapters & b.interface_adapters).include?('Standard_I_Beam_Ring')
    end

    # Universal payload handover: cargo, personnel, equipment
    def transfer_payload(from:, to:)
      transfer_cargo(from, to)
      transfer_personnel(from, to)
      transfer_equipment(from, to)
    end

    def transfer_cargo(from, to)
      return unless from.inventory.present? && to.inventory.present? && to.can_process_volatiles?
      # Transfer all items in manifest, always use add_item for each removed
      from.inventory.items.each do |item|
        next unless item.amount > 0
        amount = item.amount
        name = item.name
        from.inventory.remove_item(name, amount)
        to.inventory.add_item(name, amount, to.owner)
      end
    end

    def transfer_personnel(from, to, count = 1)
      from.transfer_personnel_to(to, count)
    end

    def transfer_equipment(from, to, equipment_id = nil)
      return unless equipment_id
      from.transfer_equipment_to(to, equipment_id)
    end
  end
end
