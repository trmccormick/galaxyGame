class MissionTaskRunnerService
  def self.run(satellite:, tasks:, accounts:)
    return unless tasks

    puts "\n🔄 Running mission tasks..."
    
    tasks['tasks']&.each do |task|
      execute_task(satellite, task, accounts)
    end
  end

  private

  def self.execute_task(satellite, task, accounts)
    case task['action']
    when 'initialize_systems'
      puts "  ✅ Initializing satellite systems..."
      satellite.update(deployed: true) if satellite.respond_to?(:deployed)
    when 'calibrate_mining_modules'
      puts "  ✅ Calibrating mining modules..."
      # Recalculate mining efficiency
      satellite.recalculate_effects if satellite.respond_to?(:recalculate_effects)
    when 'mine_gcc'
      puts "  ✅ Starting GCC mining..."
      initial_gcc = satellite.mine_gcc if satellite.respond_to?(:mine_gcc)
      if initial_gcc&.positive?
        accounts[:ldc].deposit(initial_gcc, "Initial GCC mining from #{satellite.name}")
        puts "    Mined: #{initial_gcc} GCC"
      end
    else
      puts "  ⚠️ Unknown task action: #{task['action']}"
    end
  end
end