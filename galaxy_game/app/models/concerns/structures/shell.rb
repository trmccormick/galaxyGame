# app/models/concerns/structures/shell.rb
module Structures
  module Shell
    extend ActiveSupport::Concern
    include Structures::Enclosable  # Inherit all base functionality
    
    included do
      # Associations for construction tracking
      has_many :construction_jobs, as: :jobable, dependent: :destroy
      has_many :material_requests, through: :construction_jobs
      has_many :equipment_requests, through: :construction_jobs
      
      # Status tracking
      attribute :shell_status, :string
      attribute :panel_type, :string
      attribute :construction_date, :datetime
      attribute :estimated_completion, :datetime
    end
    
    # Enum for shell construction status
    def self.shell_statuses
      {
        planned: 0,
        framework_construction: 1,
        panel_installation: 2,
        sealed: 3,
        pressurized: 4,
        operational: 5
      }
    end
    
    # ============================================================================
    # STATUS ACCESSORS
    # ============================================================================
    
    # Get shell status (for compatibility)
    # @return [String]
    def shell_status
      # Force column loading for dynamically created test classes
      self.class.columns
      if self.class.columns_hash.key?('status')
        self.status || 'planned'
      else
        operational_data&.dig('shell', 'status') || 'planned'
      end
    end
    
    # Set shell status (for compatibility)
    # @param status [String]
    def shell_status=(status)
      # Force column loading for dynamically created test classes
      self.class.columns
      if self.class.columns_hash.key?('status')
        self.status = status
      else
        new_data = self.operational_data.dup || {}
        new_data['shell'] ||= {}
        new_data['shell']['status'] = status
        self.operational_data = new_data
        operational_data_will_change!
      end
    end
    
    # ============================================================================
    # STATUS HELPERS
    # ============================================================================
    
    # Check if shell construction is planned but not started
    # @return [Boolean]
    def shell_planned?
      shell_status == 'planned'
    end
    
    # Check if framework is under construction
    # @return [Boolean]
    def framework_construction?
      shell_status == 'framework_construction'
    end
    
    # Check if panels are being installed
    # @return [Boolean]
    def panel_installation?
      shell_status == 'panel_installation'
    end
    
    # Check if shell is designed to be sealed
    # @return [Boolean]
    def shell_sealed_design?
      operational_data&.dig('shell', 'sealed') || false
    end
    
    # Check if shell is sealed
    # @return [Boolean]
    def sealed?
      # Delegate to associated atmosphere if present, otherwise fallback
      return atmosphere.sealed? if respond_to?(:atmosphere) && atmosphere.present?
      shell_status == 'sealed' || shell_status == 'pressurized'
    end
    
    # Check if shell is pressurized
    # @return [Boolean]
    def pressurized?
      shell_status == 'pressurized'
    end
    
    # Check if shell construction is complete and operational
    # @return [Boolean]
    def shell_operational?
      shell_status == 'operational'
    end
    
    # Check if any construction is in progress
    # @return [Boolean]
    def shell_under_construction?
      ['framework_construction', 'panel_installation'].include?(shell_status)
    end
    
    # ============================================================================
    # SHELL CONSTRUCTION WORKFLOW
    # ============================================================================
    
    # Schedule shell construction
    # @param panel_type [String] type of panel to use
    # @param settlement [Settlement] settlement performing construction
    # @param sealed [Boolean] whether the shell should be sealed during construction
    # @return [Hash] result with construction job
    def schedule_shell_construction!(panel_type: 'structural_cover_panel', settlement: nil, sealed: false)
      return { success: false, message: "Shell already constructed" } if shell_status != 'planned'
      return { success: false, message: "Settlement required" } unless settlement
      
      # Determine settlement if not provided
      settlement ||= determine_settlement
      return { success: false, message: "No settlement found" } unless settlement
      
      # Get blueprint
      blueprint = Blueprint.find_by(name: 'shell_construction')
      return { success: false, message: "Shell construction blueprint not found" } unless blueprint
      
      # Calculate materials
      materials = calculate_enclosure_materials(panel_type: panel_type)
      
      # Create construction job
      job = ConstructionJob.create!(
        jobable: self,
        settlement: settlement,
        blueprint: blueprint,
        status: 'materials_pending',
        target_values: {
          construction_type: 'shell',
          panel_type: panel_type,
          area_m2: area_m2,
          volume_m3: calculate_volume
        }
      )
      
      # Create material requests
      MaterialRequestService.create_material_requests_from_hash(
        job,
        materials
      )
      
      # Create equipment requests
      equipment = calculate_equipment_needs(panel_type)
      EquipmentRequestService.create_equipment_requests(
        job,
        equipment
      )
      
      # Update status
      update_shell_status('framework_construction')
      update!(panel_type: panel_type, construction_date: Time.current)
      
      # Store sealing decision
      self.operational_data ||= {}
      self.operational_data['shell'] ||= {}
      self.operational_data['shell']['sealed'] = sealed
      
      # Update shell composition
      panels_needed = (area_m2 / 25.0).ceil
      self.operational_data['shell']['panels_needed'] = panels_needed
      update_shell_composition(panel_type, panels_needed, area_m2)
      
      {
        success: true,
        construction_job: job,
        materials: materials,
        estimated_time: estimate_shell_construction_time(panel_type: panel_type),
        message: "Shell construction scheduled"
      }
    end
    
    # Advance shell construction to next phase
    # @return [Boolean] success
    def advance_shell_construction!
      case shell_status
      when 'planned'
        update_shell_status('framework_construction')
      when 'framework_construction'
        update_shell_status('panel_installation')
      when 'panel_installation'
        if shell_sealed_design?
          update_shell_status('sealed')
          on_shell_sealed if respond_to?(:on_shell_sealed, true)
        else
          update_shell_status('operational')
          on_shell_operational if respond_to?(:on_shell_operational, true)
        end
      when 'sealed'
        update_shell_status('operational')
        on_shell_operational if respond_to?(:on_shell_operational, true)
      else
        return false
      end
      
      true
    end
    
    # Complete shell construction
    # @return [Boolean] success
    def complete_shell_construction!
      return false unless shell_under_construction?
      
      update_shell_status('sealed')
      
      # Trigger any post-construction hooks
      on_shell_sealed if respond_to?(:on_shell_sealed, true)
      
      true
    end
    
    # Seal the shell (make it airtight)
    # @return [Boolean] success
    def seal_shell!
      return false unless panel_installation?
      # Create or update atmosphere
      if respond_to?(:atmosphere)
        if atmosphere.present?
          # Atmosphere exists, just update shell status
        else
          create_shell_atmosphere(temp: 293.15, pressure: 0.0)
        end
      end
      update_shell_status('sealed')
      true
    end
    
    # Pressurize the shell
    # @return [Boolean] success
    def pressurize_shell!
      # Only allow pressurization if sealed
      return false unless sealed?
      return false if pressurized?
      
      if respond_to?(:atmosphere) && atmosphere.present?
        # Set pressure to a default value if not already pressurized
        atmosphere.update!(pressure: 101.325) if atmosphere.pressure.to_f < 1.0
      else
        create_shell_atmosphere(temp: 293.15, pressure: 101.325)
      end
      update_shell_status('pressurized')
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
    def calculate_shell_materials(panel_type: 'structural_cover_panel')
      calculate_enclosure_materials(panel_type: panel_type)
    end
    
    # Estimate shell construction time
    # @param panel_type [String] type of panel
    # @return [Integer] time in hours
    def estimate_shell_construction_time(panel_type: 'structural_cover_panel')
      # Base time calculation - shells take longer than covering
      base_hours = (area_m2 / 50.0).ceil # 1 hour per 50 m² (slower than covering)
      
      # Panel type modifier
      panel_blueprint = load_panel_blueprint(panel_type)
      installation_time = panel_blueprint&.dig('installation', 'time_required')
      
      if installation_time
        time_per_panel = parse_time(installation_time)
        panels_needed = (area_m2 / 25.0).ceil
        
        # Shell construction includes framework + panels
        framework_time = panels_needed * 0.5 # Framework takes 50% of panel time
        panel_time = time_per_panel * panels_needed
        
        (framework_time + panel_time).ceil
      else
        base_hours * 2 # Double base time for framework + panels
      end
    end
    
    # Calculate equipment needs
    # @param panel_type [String] type of panel
    # @return [Array<Hash>] equipment requirements
    def calculate_equipment_needs(panel_type)
      panel_blueprint = load_panel_blueprint(panel_type)
      
      base_equipment = [
        { name: 'space_construction_drone', quantity: 5 },
        { name: 'welding_equipment', quantity: 10 },
        { name: 'structural_assembly_system', quantity: 1 }
      ]
      
      return base_equipment unless panel_blueprint
      
      tools = panel_blueprint.dig('installation', 'tools_required') || []
      crew_size = panel_blueprint.dig('installation', 'crew_size') || 3
      
      base_equipment + 
        tools.map { |tool| { name: tool, quantity: 1 } } +
        [{ name: 'construction_crew', quantity: crew_size }]
    end
    
    # Calculate enclosed volume
    # @return [Float] volume in m³
    def calculate_volume
      # Override in specific implementations
      # Basic calculation: assume 3m height for rectangular, sphere for circular
      if diameter_m.present?
        # Spherical volume: (4/3) × π × r³
        (4.0 / 3.0) * Math::PI * (diameter_m / 2.0) ** 3
      else
        # Rectangular volume: area × assumed height
        area_m2 * 3.0 # Assume 3m height
      end
    end
    
    # ============================================================================
    # ATMOSPHERE INTEGRATION
    # ============================================================================
    
    # Create atmosphere for sealed shell
    # @param temp [Float] temperature in Kelvin
    # @param pressure [Float] pressure in kPa
    # @return [Atmosphere, nil]
    def create_shell_atmosphere(temp: 293.15, pressure: 0.0)
      return atmosphere if atmosphere.present?
      # Only create atmosphere if we're in a sealing phase or beyond
      return nil unless ['panel_installation', 'sealed', 'pressurized', 'operational'].include?(shell_status)
      
      create_atmosphere(
        temperature: temp,
        pressure: pressure,
        environment_type: 'enclosed',
        total_atmospheric_mass: 0.0,
        composition: {}
      )
    end
    
    private
    
    # ============================================================================
    # PRIVATE HELPERS
    # ============================================================================
    
    # Update shell status (handles different attribute names)
    # @param new_status [String]
    def update_shell_status(new_status)
      # Force column loading for dynamically created test classes
      self.class.columns
      if self.class.columns_hash.key?('status')
        update!(status: new_status)
      else
        self.shell_status = new_status
        save!
      end
    end
    
    # Determine which settlement should perform construction
    # @return [Settlement, nil]
    def determine_settlement
      # Try to get settlement from associations
      if respond_to?(:settlement)
        settlement
      elsif respond_to?(:location) && location&.celestial_body
        # Find nearest settlement on the celestial body
        location.celestial_body.settlements.first
      elsif respond_to?(:owner)
        # For settlements, self might be the constructor
        owner if owner.is_a?(Settlement::BaseSettlement)
      end
    end
    
    # Parse time string from blueprint
    # @param time_string [String] e.g., "1.2 hours per panel"
    # @return [Float] numeric time value
    def parse_time(time_string)
      time_string.to_s.scan(/[\d.]+/).first.to_f
    end
    
    # Hook methods that can be overridden by including classes
    # These are called at various stages of shell construction
    
    # Called when shell is sealed
    def on_shell_sealed
      # Override in including class if needed
    end
    
    # Called when shell is pressurized
    def on_shell_pressurized
      # Override in including class if needed
    end
    
    # Called when shell becomes operational
    def on_shell_operational
      # Override in including class if needed
    end
    
    public
    
    # ============================================================================
    # SOLAR PANEL MANAGEMENT (from structures/shell.rb)
    # ============================================================================
    
    def shell_composition
      operational_data['shell_composition'] ||= {}
      operational_data['shell_composition']
    end

    def total_power_generation
      return 0 unless shell_operational?

      composition = shell_composition['solar_cover_panel']
      return 0 unless composition

      total_panels = composition['count'] || 0
      health_percentage = composition['health_percentage'] || 100.0
      failed_count = composition['failed_count'] || 0

      effective_panels = (total_panels - failed_count) * (health_percentage / 100.0)
      effective_panels * 10.0 # 10 kW per panel
    end

    def simulate_panel_degradation(days)
      composition = shell_composition['solar_cover_panel']
      return unless composition

      degradation_rate = 0.004 # 0.4% per year
      daily_degradation = degradation_rate / 365.0
      total_degradation = daily_degradation * days

      current_health = composition['health_percentage'] || 100.0
      new_health = [current_health * (1 - total_degradation), 0].max

      composition['health_percentage'] = new_health
      save!
    end

    def repair_panels(panel_type, count)
      composition = shell_composition[panel_type]
      return { success: false } unless composition

      failed_count = composition['failed_count'] || 0
      repaired = [count, failed_count].min

      composition['failed_count'] = failed_count - repaired
      save!

      { success: true, repaired_count: repaired }
    end

    def replace_degraded_panels(panel_type, options = {})
      percentage = options[:percentage] || 10
      composition = shell_composition[panel_type]
      return { success: false } unless composition

      total_panels = composition['count'] || 0
      replace_count = (total_panels * percentage / 100.0).to_i

      # Improve health
      current_health = composition['health_percentage'] || 100.0
      new_health = [current_health + 10, 100].min
      composition['health_percentage'] = new_health
      save!

      { success: true }
    end

    def shell_status_report
      composition = shell_composition['solar_cover_panel'] || {}
      total_panels = composition['count'] || 0
      health_percentage = composition['health_percentage'] || 100.0
      failed_count = composition['failed_count'] || 0

      {
        total_panels: total_panels,
        average_health: health_percentage,
        power_generation: total_power_generation,
        composition_breakdown: shell_composition
      }
    end
  end
end