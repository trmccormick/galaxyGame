class Admin::CatalogController < ApplicationController
  PER_PAGE = 24

  def index
    @categories = catalog_service.entries.map { |e| e[:category] }.uniq.sort
    @subcategories = catalog_service.entries.map { |e| e[:subcategory] }.compact.uniq.sort
    @selected_category = params[:category].presence
    @selected_subcategory = params[:subcategory].presence
    @search_query = params[:q].presence

    # Build filtered collection
    filtered = catalog_service.entries
    filtered = filtered.select { |e| e[:category] == @selected_category } if @selected_category
    filtered = filtered.select { |e| e[:subcategory] == @selected_subcategory } if @selected_subcategory
    if @search_query
      query = @search_query.downcase
      filtered = filtered.select { |e| e[:name].downcase.include?(query) || e[:type].downcase.include?(query) }
    end

    @total_entries = filtered.size

    # Manual pagination on filtered results
    page_num = (params[:page] || 1).to_i
    @entries = catalog_service.paginated_result(filtered, page: page_num, per_page: PER_PAGE)
  end

  def show
    @entry = catalog_service.find_entry(params[:id])
    redirect_to admin_catalog_path, alert: "Entry not found: #{params[:id]}" and return unless @entry

    # Find cross-reference (blueprint ↔ operational_data)
    @cross_ref = find_cross_reference(@entry)

    # C3: Wire B2 catalog presentation contract for RH-400 vertical slice
    @catalog_contract = catalog_data_for_entry(@entry)
  end

  private

  def catalog_service
    @catalog_service ||= CatalogService.new
  end

  # C3 — Resolve asset_id from entry and assemble B2 catalog presentation contract
  def catalog_data_for_entry(entry)
    return nil unless entry

    # Map blueprint_id → asset_id via AssetRegistry lookup
    asset_id = resolve_asset_id_for_blueprint(entry[:data])
    return nil unless asset_id

    catalog_service.catalog_data(asset_id)
  end

  # Resolve asset_id from blueprint data (C2 wiring)
  def resolve_asset_id_for_blueprint(blueprint_data)
    return nil unless blueprint_data.is_a?(Hash)

    blueprint_id = blueprint_data['id'] || blueprint_data['blueprint_id']
    return nil unless blueprint_id

    # Check AssetRegistry for known mappings
    registry = AssetRegistry.new
    # Try direct asset_id lookup by blueprint_id match
    if registry.respond_to?(:find_asset_by_blueprint_id)
      registry.find_asset_by_blueprint_id(blueprint_id)&.dig(:entry, :asset_id)
    else
      # Fallback: check known RH-400 mapping
      if blueprint_id == AssetRegistry::RH400_BLUEPRINT_ID
        AssetRegistry::RH400_ASSET_ID
      end
    end
  end

  def find_cross_reference(entry)
    case entry[:source_type]
    when 'blueprint'
      # Look for matching operational_data (same name, different category path)
      base_name = File.basename(entry[:file_path], '.json')
      catalog_service.find_operational_data_by_name(base_name)
    when 'operational_data'
      # Look for matching blueprint
      base_name = File.basename(entry[:file_path], '.json')
      catalog_service.find_blueprint_by_name(base_name)
    end
  end
end
