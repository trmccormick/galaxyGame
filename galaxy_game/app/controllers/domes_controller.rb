class DomesController < ApplicationController
    def show
      @dome = Dome.find(params[:id])
      @units = @dome.units
    end
  
    # Other actions...
end