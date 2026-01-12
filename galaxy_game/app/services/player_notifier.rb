class PlayerNotifier
  def self.notify_material_request(request)
    # TODO: Implement player notification logic
    # - ActionCable broadcast
    # - In-game UI update
    # - Email or push notification
    Rails.logger.info "[PlayerNotifier] New material request: #{request.material_name} x#{request.quantity} at #{request.settlement.name}"
  end
end