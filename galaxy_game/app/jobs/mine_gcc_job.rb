class MineGccJob < ApplicationJob
    queue_as :default
  
    def perform(colony)
      colony.mine_gcc
    end
end