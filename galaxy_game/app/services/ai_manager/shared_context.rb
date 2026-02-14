# app/services/ai_manager/shared_context.rb
module AIManager
  class SharedContext
    attr_accessor :settlement, :system_data, :mission_queue, :resource_requests,
                  :scouting_results, :active_missions, :economic_state

    def initialize(settlement: nil, system_data: nil)
      @settlement = settlement
      @system_data = system_data
      @mission_queue = []
      @resource_requests = []
      @scouting_results = {}
      @active_missions = []
      @economic_state = {}
      @listeners = []
    end

    # Event notification system
    def add_listener(listener)
      @listeners << listener unless @listeners.include?(listener)
    end

    def remove_listener(listener)
      @listeners.delete(listener)
    end

    def notify_listeners(event_type, data = {})
      @listeners.each do |listener|
        listener.handle_event(event_type, data) if listener.respond_to?(:handle_event)
      end
    end

    # Mission management
    def queue_mission(mission_data)
      @mission_queue << mission_data
      notify_listeners(:mission_queued, mission_data)
    end

    def dequeue_mission
      mission = @mission_queue.shift
      notify_listeners(:mission_dequeued, mission) if mission
      mission
    end

    # Resource management
    def request_resource(material, quantity, priority = :normal)
      request = {
        material: material,
        quantity: quantity,
        priority: priority,
        timestamp: Time.current,
        status: :pending
      }
      @resource_requests << request
      notify_listeners(:resource_requested, request)
      request
    end

    def fulfill_resource_request(request, source = :unknown)
      request[:status] = :fulfilled
      request[:fulfilled_at] = Time.current
      request[:source] = source
      notify_listeners(:resource_fulfilled, request)
    end

    # Scouting results
    def store_scouting_result(system_id, result_data)
      @scouting_results[system_id] = result_data.merge(timestamp: Time.current)
      notify_listeners(:scouting_completed, system_id: system_id, result: result_data)
    end

    def get_scouting_result(system_id)
      @scouting_results[system_id]
    end

    # Active mission tracking
    def register_active_mission(mission_id, engine_instance)
      @active_missions << { id: mission_id, engine: engine_instance, started_at: Time.current }
      notify_listeners(:mission_started, mission_id: mission_id)
    end

    def unregister_active_mission(mission_id)
      mission = @active_missions.find { |m| m[:id] == mission_id }
      if mission
        mission[:completed_at] = Time.current
        @active_missions.delete(mission)
        notify_listeners(:mission_completed, mission_id: mission_id)
      end
    end

    def get_active_mission(mission_id)
      @active_missions.find { |m| m[:id] == mission_id }
    end

    # Economic state management
    def update_economic_state(key, value)
      @economic_state[key] = value
      notify_listeners(:economic_state_changed, key: key, value: value)
    end

    def get_economic_state(key)
      @economic_state[key]
    end

    # Context serialization for persistence
    def to_hash
      {
        settlement_id: @settlement&.id,
        system_data: @system_data,
        mission_queue: @mission_queue,
        resource_requests: @resource_requests,
        scouting_results: @scouting_results,
        active_missions: @active_missions.map { |m| m.except(:engine) }, # Don't serialize engine instances
        economic_state: @economic_state
      }
    end

    def self.from_hash(data, settlement = nil)
      context = new(settlement: settlement, system_data: data['system_data'])
      context.mission_queue = data['mission_queue'] || []
      context.resource_requests = data['resource_requests'] || []
      context.scouting_results = data['scouting_results'] || {}
      context.active_missions = data['active_missions'] || []
      context.economic_state = data['economic_state'] || {}
      context
    end
  end
end