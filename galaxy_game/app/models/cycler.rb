class Cycler
  attr_accessor :docking_capacity, :processing_power, :energy_reserve, :panel_config, :docked_skimmers, :cargo

  def initialize(docking_capacity: 2, processing_power: 100, energy_reserve: 1000, panel_config: :rugged, cargo: {})
    @docking_capacity = docking_capacity
    @processing_power = processing_power
    @energy_reserve = energy_reserve
    @panel_config = panel_config
    @docked_skimmers = []
    @cargo = cargo
  end

  def dock(skimmer)
    return false if @docked_skimmers.size >= @docking_capacity
    @docked_skimmers << skimmer
    true
  end

  def undock(skimmer)
    @docked_skimmers.delete(skimmer)
  end
end
