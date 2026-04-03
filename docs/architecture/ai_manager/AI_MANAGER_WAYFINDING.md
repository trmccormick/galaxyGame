# AI_MANAGER_WAYFINDING.md

## Wormhole Network Wayfinding — McCormick 1995 BFS → Ruby 2026

---

### 1. Algorithmic Foundation
- **Original:** Tracy McCormick, Nov 17, 1995 — Turbo Pascal BFS, adjacency matrix, pred[]/distance[] arrays
- **Modern:** WormholeNavigator Ruby class — queue.shift BFS, DB-driven neighbors, physics filter (active/stable only)

---

### 2. Core Execution (Single Source Shortest Path)
```ruby
class WormholeNavigator
  def self.find_shortest_path(start_system_id, target_system_id)
    queue = [start_system_id]
    visited = { start_system_id => true }
    predecessor = { start_system_id => nil }
    distance = { start_system_id => 0 }

    while queue.any?
      current_id = queue.shift
      return rebuild_path(predecessor, target_system_id) if current_id == target_system_id
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

  # ...neighbors and rebuild_path as in code...
end
```
- **NODES:** Star systems (Eden, brown dwarfs, AWS hubs)
- **EDGES:** Wormholes (active/stable)
- **WEIGHTS:** Hop count (future: transit_time)
- **BASE:** L1 Earth-Moon (node 1)
- **OUTPUT:** pred[] → path reconstruction

---

### 3. AI Manager Integration
- **Hammer Protocol Targeting:**
```ruby
def hammer_target_selection(base_id, candidates)
  candidates.min_by { |tgt| WormholeNavigator.find_shortest_path(base_id, tgt)&.length || Float::INFINITY }
end
```
- **Consortium ROI Calculation:**
```ruby
def route_roi(origin, destination)
  path = WormholeNavigator.find_shortest_path(origin, destination)
  path_length = path.length - 1
  gcc_per_hop = l1_fuel_cost * path_length
  (belt_venture_profit / gcc_per_hop).round(2)
end
```
- **Scales:** 15 nodes (original) → full galactic network

---

### 4. Legacy & Modern Parity
- **Breath_First()**: queue.shift, visited[], pred[], distance[]
- **A[row,col]**: Wormhole.where(status: :stable)
- **Get_Path_Info()**: rebuild_path(predecessor)
- **Physics filter**: neighbors() only active/stable links

---

### 5. Production Status
- **30-year algorithm = checkmate for wormhole network wayfinding**
- **Directly powers Hammer Protocol, Consortium ROI, and all future galactic routing**
- **No further translation required — ready for Claude 5PM and beyond**

---

**Status:** WormholeNavigator is the canonical, production-grade wayfinding engine for the AI Manager. All expansion, targeting, and economic logic should route through this class.
