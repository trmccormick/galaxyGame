class BlueprintDependencyGenerator
  def initialize(model = 'llama3')
    host = ENV['RAILS_ENV'] == 'production' ? 'http://ollama:11434' : 'http://ollama:11434'
    @client = OllamaAI::Client.new(host: host)
    @model = model
    @data_generator = GameDataGenerator.new(model)
    
    # Use container paths
    @base_path = "/home/galaxy_game/app/data"
    @templates_path = "#{@base_path}/templates"
  end
  
  def process_blueprint(blueprint_path, generate_dependencies = true)
    # Load the blueprint
    blueprint = JSON.parse(File.read(blueprint_path))
    
    # Extract all dependencies
    dependencies = extract_dependencies(blueprint)
    
    if generate_dependencies
      # Generate missing dependencies
      missing_deps = find_missing_dependencies(dependencies)
      generate_missing_dependencies(missing_deps)
    end
    
    # Return the list of dependencies
    dependencies
  end
  
  private
  
  def extract_dependencies(blueprint)
    dependencies = []
    
    # Extract units
    if blueprint["compatible_units"]
      blueprint["compatible_units"].each do |unit_id|
        dependencies << {type: "unit", id: unit_id}
      end
    end
    
    # Extract modules
    if blueprint["compatible_modules"]
      blueprint["compatible_modules"].each do |module_id|
        dependencies << {type: "module", id: module_id}
      end
    end
    
    # Extract recommended units
    if blueprint["recommended_units"]
      blueprint["recommended_units"].each do |unit|
        dependencies << {type: "unit", id: unit["id"]}
      end
    end
    
    # Extract materials
    if blueprint.dig("blueprint_data", "materials")
      blueprint["blueprint_data"]["materials"].each do |material|
        dependencies << {type: "material", id: material["id"]}
      end
    end
    
    # Extract research requirements
    if blueprint.dig("blueprint_data", "research_required")
      dependencies << {
        type: "technology", 
        id: blueprint["blueprint_data"]["research_required"]
      }
    end
    
    # Return unique dependencies
    dependencies.uniq {|d| [d[:type], d[:id]]}
  end
  
  def find_missing_dependencies(dependencies)
    missing = []
    
    dependencies.each do |dep|
      file_path = determine_file_path(dep[:type], dep[:id])
      missing << dep unless File.exist?(file_path)
    end
    
    missing
  end
  
  def determine_file_path(type, id)
    case type
    when "unit"
      "#{@base_path}/blueprints/units/#{id}_bp.json"
    when "module"
      "#{@base_path}/blueprints/modules/#{id}_bp.json"
    when "material"
      "#{@base_path}/materials/#{id}.json"
    when "technology"
      "#{@base_path}/tech_tree/#{id.downcase.gsub(' ', '_')}.json"
    else
      "#{@base_path}/#{type.pluralize}/#{id}.json"
    end
  end
  
  def determine_template_path(type)
    case type
    when "unit"
      "#{@templates_path}/base_unit.json"
    when "module"
      "#{@templates_path}/base_module.json"
    when "material"
      "#{@templates_path}/base_material.json"
    when "technology"
      "#{@templates_path}/base_technology.json"
    else
      "#{@templates_path}/base_#{type}.json"
    end
  end
  
  def generate_missing_dependencies(missing_deps)
    missing_deps.each do |dep|
      template_path = determine_template_path(dep[:type])
      output_path = determine_file_path(dep[:type], dep[:id])
      
      # Generate basic description based on the ID
      description = generate_description(dep[:type], dep[:id])
      
      # Generate the dependency file
      @data_generator.generate_item(
        template_path,
        output_path,
        {
          id: dep[:id],
          name: dep[:id].split('_').map(&:capitalize).join(' '),
          description: description
        }
      )
      
      puts "Generated #{dep[:type]}: #{dep[:id]}"
    end
  end
  
  def generate_description(type, id)
    # Use Ollama to generate a realistic description
    prompt = <<~PROMPT
      Generate a brief, realistic description for a #{type} called "#{id.gsub('_', ' ')}" 
      in a space exploration game. The description should be 1-2 sentences only.
    PROMPT
    
    response = @client.generate(
      model: @model,
      prompt: prompt,
      temperature: 0.7,
      max_tokens: 100
    )
    
    # Extract the description from the response
    response.body.strip
  end
end