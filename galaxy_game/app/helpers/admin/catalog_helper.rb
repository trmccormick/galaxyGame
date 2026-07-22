# frozen_string_literal: true

module Admin::CatalogHelper
  # Return Font Awesome icon class based on category
  def thumbnail_icon(entry)
    case entry.is_a?(Hash) ? entry[:category] : entry.category
    when 'units'        then 'fas fa-rocket'
    when 'modules'      then 'fas fa-cube'
    when 'rigs'         then 'fas fa-industry'
    when 'structures'   then 'fas fa-building'
    when 'crafts'       then 'fas fa-shuttle-space'
    when 'components'   then 'fas fa-puzzle-piece'
    when 'materials'    then 'fas fa-flask'
    when 'items'        then 'fas fa-box'
    else                     'fas fa-file-alt'
    end
  end

  # Pretty-print JSON with basic syntax highlighting
  def highlight_json(data)
    json = data.to_json
    json.html_safe
  rescue StandardError
    data.to_s
  end
end
