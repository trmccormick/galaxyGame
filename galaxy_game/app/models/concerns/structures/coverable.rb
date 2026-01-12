# app/models/concerns/structures/coverable.rb
module Structures
  module Coverable
    extend ActiveSupport::Concern
    include Structures::Enclosable  # Inherit all base functionality
    
    included do
      # Associations for construction tracking
      has_many :construction_jobs, as: :jobable, dependent: :destroy
      has_many :material_requests, through: :construction_jobs
      has_many :equipment_requests, through: :construction_jobs
      
      # Status tracking
      attribute :cover_status, :string, default: 'uncovered'
      attribute :panel_type, :string
      attribute :construction_date, :datetime
      attribute :estimated_completion, :datetime
    end
    
    # Enum for cover status
    # Note: If the model uses a different status attribute (like 'status'),
    # it should define its own enum
    def self.cover_statuses
      {
        natural: 0,
        uncovered: 1,
        materials_requested: 2,
        under_construction: 3,
        primary_cover: 4,
        full_cover: 5
      }
    end
    
    # ============================================================================
    # STATUS HELPERS
    # ============================================================================
    
    # Check if opening is uncovered
    # @return [Boolean]
    def uncovered?
      status_value == 'uncovered' || status_value == 'natural'
    end
    
    # Check if opening is covered
    # @return [Boolean]
    def covered?
      status_value == 'primary_cover' || status_value == 'full_cover' || 
      status_value == 'enclosed' || status_value == 'pressurized'
    end
    
    # Check if covering is under construction
    # @return [Boolean]
    def under_construction?
      status_value == 'under_construction'
    end
    
    # Check if materials have been requested
    # @return [Boolean]
    def materials_requested?
      status_value == 'materials_requested'
    end
    
    # ============================================================================
    # COVERING WORKFLOW
    # ============================================================================
    
    # Schedule covering construction
    # @param panel_type [String] type of panel to use
    # @param settlement [Settlement] settlement performing construction
    # @return [Hash] result with construction job
    def schedule_covering!(panel_type: 'transparent_cover_panel', settlement: nil)
      return { success: false, message: "Already covered" } if covered?
      return { success: false, message: "Settlement required" } unless settlement
      
      # Determine settlement if not provided
      settlement ||= determine_settlement
      return { success: false, message: "No settlement found" } unless settlement
      
      # Get blueprint
      blueprint = Blueprint.find_by(name: 'covering_construction')
      
      # Calculate materials
      materials = calculate_enclosure_materials(panel_type: panel_type)
      
      # Create construction job
      job = ConstructionJob.create!(
        jobable: self,
        settlement: settlement,
        blueprint: blueprint,
        status: 'materials_pending',
        target_values: {
          construction_type: 'covering',
          panel_type: panel_type,
          area_m2: area_m2
        }
      )
      
      # Create material requests
      # Note: Service expects (materials_hash, construction_job) - settlement is in job
      Manufacturing::MaterialRequest.create_material_requests_from_hash(
        materials,
        job
      )
      
      # Create equipment requests  
      equipment = calculate_equipment_needs(panel_type)
      Manufacturing::EquipmentRequest.create_equipment_requests(
        equipment,
        job
      )
      
      # Update status
      update_status('materials_requested')
      update!(panel_type: panel_type) if respond_to?(:panel_type=)
      
      # Update shell composition
      panels_needed = (area_m2 / 25.0).ceil
      update_shell_composition(panel_type, panels_needed, area_m2)
      
      {
        success: true,
        construction_job: job,
        materials: materials,
        estimated_time: estimate_covering_time(panel_type: panel_type),
        message: "Covering construction scheduled"
      }
    end
    
    # Complete covering construction
    # @return [Boolean] success
    def complete_covering!
      return false unless under_construction?
      
      update_status('primary_cover')
      
      # Set construction_date if attribute exists
      if respond_to?(:construction_date=)
        update!(construction_date: Time.current)
      else
        save!
      end
      
      true
    end
    
    # ============================================================================
    # CONSTRUCTION HELPERS
    # ============================================================================
    
    # Get active construction job
    # @return [ConstructionJob, nil]
    def active_construction_job
      construction_jobs.where(status: ['materials_pending', 'in_progress']).first
    end
    
    # Calculate required materials (without scheduling)
    # Uses Enclosable#calculate_enclosure_materials
    # @param panel_type [String] type of panel
    # @return [Hash] materials needed
    def calculate_covering_materials(panel_type: 'transparent_cover_panel')
      calculate_enclosure_materials(panel_type: panel_type)
    end
    
    # Estimate construction time
    # @param panel_type [String] type of panel
    # @return [Integer] time in hours
    def estimate_covering_time(panel_type: 'transparent_cover_panel')
      # Base time calculation
      base_hours = (area_m2 / 100.0).ceil # 1 hour per 100 m²
      
      # Panel type modifier
      panel_blueprint = load_panel_blueprint(panel_type)
      installation_time = panel_blueprint&.dig('installation', 'time_required')
      
      if installation_time
        time_per_panel = parse_time(installation_time)
        panels_needed = (area_m2 / 25.0).ceil
        time_per_panel * panels_needed
      else
        base_hours
      end
    end
    
    # Calculate equipment needs
    # @param panel_type [String] type of panel
    # @return [Array<Hash>] equipment requirements
    def calculate_equipment_needs(panel_type)
      panel_blueprint = load_panel_blueprint(panel_type)
      return [] unless panel_blueprint
      
      tools = panel_blueprint.dig('installation', 'tools_required') || []
      crew_size = panel_blueprint.dig('installation', 'crew_size') || 2
      
      tools.map { |tool| { name: tool, quantity: 1 } } +
        [{ name: 'construction_crew', quantity: crew_size }]
    end
    
    private
    
    # ============================================================================
    # PRIVATE HELPERS
    # ============================================================================
    
    # Get status value from appropriate attribute
    # @return [String]
    def status_value
      if respond_to?(:cover_status)
        cover_status
      elsif respond_to?(:status)
        status
      else
        'uncovered'
      end
    end
    
    # Update status (handles different attribute names)
    # @param new_status [String]
    def update_status(new_status)
      if respond_to?(:cover_status=)
        update!(cover_status: new_status)
      elsif respond_to?(:status=)
        update!(status: new_status)
      end
    end
    
    # Determine which settlement should perform construction
    # @return [Settlement, nil]
    def determine_settlement
      # Try to get settlement from associations
      if respond_to?(:settlement)
        settlement
      elsif respond_to?(:worldhouse) && worldhouse
        worldhouse.settlement
      elsif respond_to?(:location) && location&.celestial_body
        # Find nearest settlement on the celestial body
        location.celestial_body.settlements.first
      end
    end
    
    # Parse time string from blueprint
    # @param time_string [String] e.g., "1.2 hours per panel"
    # @return [Float] numeric time value
    def parse_time(time_string)
      time_string.to_s.scan(/[\d.]+/).first.to_f
    end
  end
end