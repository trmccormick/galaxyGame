class ColoniesController < ApplicationController
    def show
      @colony = Colony.find(params[:id])
      @units = @colony.units
      @domes = @colony.domes
    end

    def mine
      @colony = Colony.find(params[:id])
      @colony.mine_gcc
      render json: { balance: @colony.account.balance, message: 'GCC mined successfully' }
    end    
  
    # Other actions...
end