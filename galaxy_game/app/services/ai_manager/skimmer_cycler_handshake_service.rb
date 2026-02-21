module AIManager
  class SkimmerCyclerHandshakeService
    # Dock skimmer to cycler during high-speed transit
    def dock_skimmer(skimmer, cycler)
      return false unless compatible?(skimmer, cycler)
      return false unless cycler.has_unit?(:docking_hub)
      return false unless cycler.dock(skimmer)
      true
    end

    # In-route processing: process skimmer cargo using cycler energy and gas processing capability
    def process_cargo(skimmer, cycler)
      return false unless cycler.docked_at == skimmer || cycler.docked_at&.id == skimmer.id
      return false unless cycler.can_process_atmosphere?
      required_energy = skimmer.raw_cargo.values.sum * 2
      return false if cycler.energy_reserve < required_energy
      cycler.energy_reserve -= required_energy
      skimmer.processed_cargo = skimmer.raw_cargo.transform_values { |v| v * 0.9 }
      skimmer.raw_cargo = {}
      skimmer.available = true # Mark skimmer as available for next dive
      true
    end

    # Panel/I-Beam compatibility using Craft panel system
    def compatible?(skimmer, cycler)
      skimmer.panel_config == cycler.operational_data.dig('panel_config')
    end
  end
end
