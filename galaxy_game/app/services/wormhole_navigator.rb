class WormholeNavigator
  # Derived from original BFS implementation by Tracy McCormick, Nov 17, 1995.
  
  def self.find_shortest_path(start_system_id, target_system_id)
    queue = [start_system_id]
    visited = { start_system_id => true }
    predecessor = { start_system_id => nil }
    distance = { start_system_id => 0 }

    while queue.any?
      current_id = queue.shift
      return rebuild_path(predecessor, target_system_id) if current_id == target_system_id

      # This replaces the adjacency matrix lookup with a live DB query
      neighbors(current_id).each do |neighbor_id|
        unless visited[neighbor_id]
          visited[neighbor_id] = true
          predecessor[neighbor_id] = current_id
          distance[neighbor_id] = distance[current_id] + 1
          queue << neighbor_id
        end
      end
    end

    nil # No path found
  end

  private

  def self.neighbors(system_id)
    # This is where we plug in the "Physics Filter"
    # We only return connections that are ACTIVE and STABLE
    Wormhole.where(origin_system_id: system_id, status: :stable).pluck(:destination_system_id)
  end

  def self.rebuild_path(predecessor, target_id)
    path = []
    current = target_id
    while current
      path.unshift(current)
      current = predecessor[current]
    end
    path
  end
end