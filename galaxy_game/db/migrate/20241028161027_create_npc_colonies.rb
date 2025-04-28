class CreateNpcColonies < ActiveRecord::Migration[7.0]
  def change
    create_table :npc_colonies do |t|
      t.string :name, null: false
      t.integer :population_capacity
      t.json :initial_resources, default: {}  # Store initial resources as JSON
      t.json :ai_manager, default: {}  # Optionally store AI manager state as JSON
      t.json :trade_routes, default: []  # Store trade routes as an array of JSON objects

      t.timestamps
    end
  end
end
