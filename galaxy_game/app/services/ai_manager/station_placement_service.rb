# StationPlacementService
# Places AWS 180° opposite a high-mass body for synthetic stability

module AIManager
  class StationPlacementService
    def place_aws(system)
      # Find the largest mass body in the system (e.g., gas giant)
      anchor_body = (system[:bodies] || []).max_by { |b| b[:mass] || 0 }
      return nil unless anchor_body
      {
        anchor_body_id: anchor_body[:id],
        position: (anchor_body[:position] + 180) % 360
      }
    end
  end
end
