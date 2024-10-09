# app/controllers/materials_controller.rb
class MaterialsController < ApplicationController
    def show
      service = MaterialLookupService.new
      @material = service.find_material(params[:name])
  
      if @material
        render json: @material
      else
        render json: { error: 'Material not found' }, status: :not_found
      end
    end
end