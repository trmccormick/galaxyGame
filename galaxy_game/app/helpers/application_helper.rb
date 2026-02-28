module ApplicationHelper
  # Checks if an asset exists in the asset pipeline (for images, etc.)
  def asset_exists?(path)
    if Rails.application.assets
      Rails.application.assets.find_asset(path).present?
    else
      # For production (precompiled assets)
      manifest_path = Rails.root.join('public', 'assets', 'manifest.json')
      if File.exist?(manifest_path)
        manifest = JSON.parse(File.read(manifest_path))
        manifest.values.any? { |v| v.include?(path) }
      else
        false
      end
    end
  end
end
