module Docking
  # Docking concern provides pure logic for docking ports
  # Associations must be defined in the including model

  # Returns the number of available docking ports
  def available_docking_ports
    port_count = 1
    if respond_to?(:blueprint_ports)
      ports = blueprint_ports
      port_count = ports.is_a?(Array) ? ports.size : ports.to_i
      port_count = 1 if port_count < 1
    end
    docked = respond_to?(:docked_crafts) ? docked_crafts.size : 0
    [port_count - docked, 0].max
  end

  # Returns true if there is at least one available docking port
  def has_available_docking_port?
    available_docking_ports > 0
  end

  # Docking and undocking logic should be handled by the including model
  # This concern only provides port availability logic
end