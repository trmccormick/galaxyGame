class Admin::CatalogController < ApplicationController
  PER_PAGE = 24
  CATEGORIES = %w[units modules rigs structures crafts components materials items].freeze
  SUBCATEGORIES = {
    units:        %w[life_support propulsion energy mining construction medical],
    modules:      %w[habitation laboratory storage docking power_production],
    rigs:         %w[oil_gas helium3 methane ammonia hydrogen],
    structures:   %w[habitation industrial agricultural military commercial],
    crafts:       %w[ground space satellites probes landersrovers],
    components:   %w[sensors actuators processors batteries wiring structural],
    materials:    %w[metals polymers ceramics composites gases liquids],
    items:        %w[food medicine tools weapons parts raw_materials]
  }.freeze

  def index
    @categories = CATEGORIES
    @subcategories = SUBCATEGORIES
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
  end

  private

  def catalog_service
    @catalog_service ||= CatalogService.new
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
