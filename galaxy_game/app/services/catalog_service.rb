# frozen_string_literal: true

# Service for loading, indexing, and querying blueprint + operational_data entries
class CatalogService
  # Base path: uses existing GalaxyGame::Paths::JSON_DATA (RAILS_ROOT.join('app', 'data'))
  def base_path
    @base_path ||= GalaxyGame::Paths::JSON_DATA
  end

  # All entries (lazy-loaded, cached per request)
  def entries
    @entries ||= load_entries
  end

  # Create a paginated result object from an array of entries
  def paginated_result(entries_array, page: nil, per_page: 24)
    total = entries_array.size
    page_num = (page || 1).to_i
    offset = (page_num - 1) * per_page
    items = entries_array[offset, per_page] || []

    OpenStruct.new(
      total_count: total,
      total_pages: (total.to_f / per_page).ceil,
      current_page: page_num,
      per_page: per_page,
      limit_value: per_page,
      offset_value: offset,
      size: items.size,
      first_page?: page_num == 1,
      last_page?: page_num >= (total.to_f / per_page).ceil,
      offset: offset,
      each: items.each,
      to_a: items,
      empty?: items.empty?
    )
  end

  # Find entry by ID (category/filename_without_ext)
  def find_entry(id)
    entries.find { |e| e[:id] == id }
  end

  # Find operational_data entry by blueprint filename
  def find_operational_data_by_name(blueprint_filename)
    # Strip .json extension, then remove _bp suffix if present
    base = File.basename(blueprint_filename, '.json').sub(/_bp$/, '')
    entries.find do |e|
      e[:source_type] == 'operational_data' &&
        (File.basename(e[:file_path], '.json') == base ||
         File.basename(e[:file_path], '.json').start_with?(base))
    end
  end

  # Find blueprint entry by operational_data filename
  def find_blueprint_by_name(op_filename)
    # Strip .json extension, then remove _data suffix if present
    base = File.basename(op_filename, '.json').sub(/_data$/, '')
    entries.find do |e|
      e[:source_type] == 'blueprint' &&
        (File.basename(e[:file_path], '.json') == base ||
         File.basename(e[:file_path], '.json').start_with?(base))
    end
  end

  # Filtered query builder
  def entries_for(category: nil, subcategory: nil, search: nil)
    result = entries
    result = result.select { |e| e[:category] == category } if category
    result = result.select { |e| e[:subcategory] == subcategory } if subcategory
    result = result.select { |e| e[:name].downcase.include?(search.downcase) || e[:type].downcase.include?(search.downcase) } if search
    result
  end

  private

  def load_entries
    return [] unless base_path.exist?

    entries = []

    # Load blueprints using GalaxyGame::Paths
    if GalaxyGame::Paths::BLUEPRINTS_PATH.exist?
      Dir.glob(GalaxyGame::Paths::BLUEPRINTS_PATH.join('**/*.json')).each do |f|
        entry = build_entry(f, 'blueprint')
        entries << entry if entry
      end
    end

    # Load operational_data using GalaxyGame::Paths
    od_path = base_path.join('operational_data')
    if od_path.exist?
      Dir.glob(od_path.join('**/*.json')).each do |f|
        entry = build_entry(f, 'operational_data')
        entries << entry if entry
      end
    end

    # Sort by category then name (use empty string for nil subcategory to avoid comparison errors)
    entries.sort_by { |e| [e[:category], e[:subcategory] || '', e[:name]] }
  end

  def build_entry(file_path, source_type)
    begin
      data = JSON.parse(File.read(file_path))
    rescue => e
      Rails.logger.warn("CatalogService: Failed to parse #{file_path}: #{e.message}")
      return nil
    end

    relative = Pathname.new(file_path).relative_path_from(base_path)
    parts = relative.to_s.split('/')  # ["blueprints", "crafts", "space", "probes", "thermal_probe_bp.json"]
    
    # Category is always parts[1] (first dir after source type: blueprints/ or operational_data/)
    category = parts[1].to_s if parts.size > 1
    
    # Subcategory only exists at depth >= 4 (blueprints/cat/subcat/file.json)
    # At depth 3, parts[2] IS the filename, not a subdirectory
    subcategory = parts[2].to_s if parts.size > 3

    # Extract name from filename
    filename = File.basename(file_path, '.json')
    name = filename.sub(/_bp$/, '').split('_').map(&:capitalize).join(' ')

    # Get type from data if available
    entry_type = data['type'] || data['craft_type'] || data['unit_type'] || data['structure_type'] || category&.capitalize || ''

    # ID: relative path from source type dir with .json and _bp stripped
    # e.g., blueprints/crafts/space/probes/thermal_probe_bp.json → crafts/space/probes/thermal_probe
    id = relative.to_s.sub("#{parts[0]}/", '').sub('.json', '').sub(/_bp$/, '')

    {
      id: id,
      name: name,
      type: entry_type,
      category: category,
      subcategory: subcategory,
      source_type: source_type,
      file_path: file_path.to_s,
      has_image: image_exists?(relative),
      thumbnail_path: relative.to_s.gsub('.json', '.png'),
      data: data,
      created_at: File.mtime(file_path)
    }
  rescue => e
    Rails.logger.warn("CatalogService: Error building entry for #{file_path}: #{e.message}")
    nil
  end

  def image_exists?(relative_path)
    img_path = base_path.join('images', relative_path.to_s.gsub('.json', '.png'))
    img_path.exist?
  end
end
