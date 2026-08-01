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

      # Check if file exists first
      unless File.exist?(asset_path)
        render status: :not_found, json: { error: 'Asset not found' }
        return
      end

      # Verify path is within ASSETS_PATH (prevent directory traversal)
      begin
        asset_path_obj = Pathname.new(asset_path).realpath
        assets_base = Pathname.new(GalaxyGame::Paths::ASSETS_PATH.to_s).realpath

        unless asset_path_obj.to_s.start_with?(assets_base.to_s)
          render status: :forbidden, json: { error: 'Access denied' }
          return
        end
      rescue StandardError => e
        Rails.logger.error("Path validation error: #{e.message}")
        render status: :forbidden, json: { error: 'Access denied' }
        return
      end

      send_file asset_path, disposition: 'inline'
    rescue StandardError => e
      Rails.logger.error("Asset serving error: #{e.message}")
      render status: :bad_request, json: { error: e.message }
    end
  end
end
