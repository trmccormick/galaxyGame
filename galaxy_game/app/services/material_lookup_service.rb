class MaterialLookupService
  def initialize
    @materials = load_raw_materials # Assuming you load YAML files here
  end

  def find_material(name)
    # Find a material by name across all loaded materials
    @materials.each do |category, items|
      # search by name
      item = items.find { |i| i['name'].casecmp?(name) }
      return item if item

      # search by chemical_formula
      item = items.find { |i| i['chemical_formula'].casecmp?(name) }
      return item if item

      # search by aliases
      item = items.find { |i| i['aliases'].map(&:downcase).include?(name.downcase) }
      return item if item
    end
    nil # Return nil if not found
  end

  private

  def load_raw_materials
    # Load materials from YAML files and combine them into a single hash
    materials = {}
    %w[materials meteorites raw_ores].each do |file_name|
      materials.merge!(YAML.load_file(Rails.root.join('config', 'raw_materials', "#{file_name}.yml"))) do |key, old_val, new_val|
        old_val + new_val # Combine arrays if the keys are the same
      end
    end
    materials
  end  
end

  