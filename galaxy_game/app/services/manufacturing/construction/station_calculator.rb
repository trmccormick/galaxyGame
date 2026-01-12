class Manufacturing::Construction::StationCalculator
  # Standard panel and beam sizes (meters)
  PANEL_SIZE = 5.0
  IBEAM_SPACING = 5.0
  # Default material multipliers (can be tuned per station type)
  MATERIAL_MULTIPLIERS = {
    "3d_printed_ibeams" => 1.0,
    "modular_panels" => 1.0,
        "sealant" => 1.0,
        "fasteners" => 1.0,
        "insulation" => 1.0
      }.freeze

      # Calculate required materials for a station
      # station: object with .radius (m), .length (m), .type ("depot", "hab", etc.)
      # blueprint: optional, for custom material lists
      def self.calculate_materials(station, blueprint = nil)
        radius = station.radius || 25.0 # meters
        length = station.length || 100.0 # meters
        type = station.type || "standard"

        # Surface area of a cylinder (side only, ignore end caps for now)
        side_area = 2 * Math::PI * radius * length
        end_area = Math::PI * radius**2
        total_area = side_area + 2 * end_area

        # I-beams: grid along length and circumference
        ibeam_count = ((length / IBEAM_SPACING).ceil + 1) * ((2 * Math::PI * radius / IBEAM_SPACING).ceil + 1)
        # Panels: cover total area
        panel_count = (total_area / (PANEL_SIZE**2)).ceil
        # Sealant: perimeter of all panels
        sealant_kg = total_area * 0.2 # 0.2kg per m^2
        # Fasteners: 8 per panel
        fastener_count = panel_count * 8
        # Insulation: 1kg per m^2
        insulation_kg = total_area * 1.0

        # Merge with blueprint if provided
        base_materials = {
          "3d_printed_ibeams" => (ibeam_count * MATERIAL_MULTIPLIERS["3d_printed_ibeams"]).to_i,
          "modular_panels" => (panel_count * MATERIAL_MULTIPLIERS["modular_panels"]).to_i,
          "sealant" => (sealant_kg * MATERIAL_MULTIPLIERS["sealant"]).ceil,
          "fasteners" => (fastener_count * MATERIAL_MULTIPLIERS["fasteners"]).to_i,
          "insulation" => (insulation_kg * MATERIAL_MULTIPLIERS["insulation"]).ceil
        }
        if blueprint&.materials
          blueprint.materials.each do |mat, amt|
            base_materials[mat.to_s] = base_materials.fetch(mat.to_s, 0) + amt.to_i
          end
        end
        base_materials
      end

      def self.estimate_construction_time(station, blueprint = nil)
        radius = station.radius || 25.0
        length = station.length || 100.0
        total_area = 2 * Math::PI * radius * length + 2 * Math::PI * radius**2
        base_hours = 48 # 2 days base
        area_factor = total_area / 50.0 # 1 hour per 50 m^2
        complexity = case station.type
          when "depot" then 1.1
          when "hab" then 1.3
          else 1.0
        end
        ((base_hours + area_factor) * complexity).ceil
      end
end