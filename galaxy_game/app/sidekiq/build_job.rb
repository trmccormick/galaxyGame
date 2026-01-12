class BuildJob
  include Sidekiq::Job

  def perform(player_id, blueprint_id)
    player = Player.find(player_id)
    blueprint = Blueprint.find(blueprint_id)
    
    service = Manufacturing::Processing.new(player, blueprint)
    result = service.process
    
    # Log the result or handle it as needed
    puts result
  end
end
