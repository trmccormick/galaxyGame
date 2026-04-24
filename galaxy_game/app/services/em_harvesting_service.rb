class EmHarvestingService
  def initialize(infrastructure:, target:)
    @infra = infrastructure  # Satellite/NWA/AWS/MidSkimmer
    @target = target         # Wormhole/EmField
  end

  def harvest_cycle
    return 0 unless operational? && positioned?
      send("#{infra_type}_yield")
  end

  private

  def infra_type
    case @infra.id
    when /wormhole_stabilization_satellite/ then :satellite
    when /natural_wormhole_anchor/ then :nwa
    when /artificial_wormhole_station/ then :aws
    when /orbital_em_skimmer_mid/ then :mid_skimmer
    else
      raise "Unknown infrastructure type: #{@infra.id}"
    end
  end

  def operational?
    @infra.respond_to?(:operational?) ? @infra.operational? : true
  end

  def positioned?
    @infra.respond_to?(:positioned?) ? @infra.positioned?(@target) : true
  end

  def satellite_yield
    base = @infra.efficiency * @infra.capacity * @target.flux
    dual_bonus = @target.dual_connection? ? 2.5 : 1.0
    base * dual_bonus
  end

  def nwa_yield
    base = @infra.efficiency * @infra.capacity * @target.flux
    dual_bonus = @target.dual_connection? ? 2.5 : 1.0
    base * dual_bonus
  end

  def aws_yield
    base = @infra.efficiency * @infra.capacity * @target.flux
    dual_bonus = @target.dual_connection? ? 2.5 : 1.0
    base * dual_bonus
  end

  def mid_skimmer_yield
    base = @infra.efficiency * @infra.capacity * @target.flux
    dual_bonus = @target.dual_connection? ? 2.5 : 1.0
    base * dual_bonus
  end
end
