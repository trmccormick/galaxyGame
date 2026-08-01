# app/controllers/api/assets_controller.rb
# Serves game assets (images, sprites) from app/data/images using GalaxyGame::Paths

module Api
  class AssetsController < ApplicationController
    skip_authentication_check if respond_to?(:skip_authentication_check)

    # GET /api/assets/*path
    # Serves asset files from GalaxyGame::Paths::ASSETS_PATH
    # Example: /api/assets/terrain/dust/variant_01.png → app/data/images/terrain/dust/variant_01.png
    def get_asset
      asset_path_str = params[:path]

      # Construct full file path
      asset_path = GalaxyGame::Paths::ASSETS_PATH.join(asset_path_str).to_s

      # Verify file exists and is within ASSETS_PATH (prevent directory traversal)
      asset_path_obj = Pathname.new(asset_path).realpath
      assets_base = Pathname.new(GalaxyGame::Paths::ASSETS_PATH.to_s).realpath

      unless asset_path_obj.to_s.start_with?(assets_base.to_s)
        render status: :forbidden, json: { error: 'Access denied' }
        return
      end

      if File.exist?(asset_path)
        send_file asset_path, disposition: 'inline'
      else
        render status: :not_found, json: { error: 'Asset not found' }
      end
    rescue Errno::ENOENT
      render status: :not_found, json: { error: 'Asset not found' }
    rescue StandardError => e
      Rails.logger.error("Asset serving error: #{e.message}")
      render status: :bad_request, json: { error: e.message }
    end
  end
end
