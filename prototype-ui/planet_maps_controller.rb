# app/controllers/api/v1/planet_maps_controller.rb
module Api
  module V1
    class PlanetMapsController < ApplicationController
      before_action :set_planet, only: [:show, :create, :update]
      before_action :set_planet_map, only: [:show, :update, :destroy]
      
      # GET /api/v1/planets/:planet_id/map
      def show
        render json: @planet_map.to_map_json
      end
      
      # POST /api/v1/planets/:planet_id/map
      def create
        @planet_map = PlanetMap.new(planet_map_params)
        @planet_map.celestial_body = @planet
        
        # Calculate dimensions from planet size
        dimensions = PlanetMap.calculate_dimensions(@planet)
        @planet_map.width = dimensions[:width]
        @planet_map.height = dimensions[:height]
        
        # Generate the map
        @planet_map.generate_from_planet_data!
        
        render json: @planet_map.to_map_json, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
      
      # PATCH/PUT /api/v1/planets/:planet_id/map
      def update
        if @planet_map.update(planet_map_params)
          render json: @planet_map.to_map_json
        else
          render json: { errors: @planet_map.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end
      
      # DELETE /api/v1/planets/:planet_id/map
      def destroy
        @planet_map.destroy
        head :no_content
      end
      
      # GET /api/v1/planets/:planet_id/map/tile?x=10&y=20
      def tile
        @planet_map = @planet.planet_map
        
        x = params[:x].to_i
        y = params[:y].to_i
        
        tile = @planet_map.tile_at(x, y)
        render json: { x: x, y: y, tile: tile }
      end
      
      # PATCH /api/v1/planets/:planet_id/map/tile
      # Body: { x: 10, y: 20, tile: { terrain: 'modified', ... } }
      def update_tile
        @planet_map = @planet.planet_map
        
        x = params[:x].to_i
        y = params[:y].to_i
        tile_data = params[:tile].permit!.to_h
        
        @planet_map.set_tile_at(x, y, tile_data)
        
        if @planet_map.save
          render json: { x: x, y: y, tile: tile_data }
        else
          render json: { errors: @planet_map.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end
      
      # GET /api/v1/planets/:planet_id/map/region?x1=0&y1=0&x2=50&y2=50
      def region
        @planet_map = @planet.planet_map
        
        x1 = params[:x1].to_i
        y1 = params[:y1].to_i
        x2 = params[:x2].to_i
        y2 = params[:y2].to_i
        
        tiles = {}
        (y1..y2).each do |y|
          (x1..x2).each do |x|
            tiles["#{x},#{y}"] = @planet_map.tile_at(x, y)
          end
        end
        
        render json: {
          region: { x1: x1, y1: y1, x2: x2, y2: y2 },
          tiles: tiles
        }
      end
      
      private
      
      def set_planet
        @planet = CelestialBodies::CelestialBody.find(params[:planet_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Planet not found' }, status: :not_found
      end
      
      def set_planet_map
        @planet_map = @planet.planet_map
        
        unless @planet_map
          render json: { error: 'Map not generated for this planet' }, 
                 status: :not_found
        end
      end
      
      def planet_map_params
        params.permit(:seed, :noise_scale, :octaves)
      end
    end
  end
end

# Add to config/routes.rb
namespace :api do
  namespace :v1 do
    resources :planets, only: [] do
      resource :map, controller: 'planet_maps', only: [:show, :create, :update, :destroy] do
        get 'tile', on: :collection
        patch 'tile', action: :update_tile, on: :collection
        get 'region', on: :collection
      end
    end
  end
end