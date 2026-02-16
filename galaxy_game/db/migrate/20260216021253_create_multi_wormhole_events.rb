class CreateMultiWormholeEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :multi_wormhole_events do |t|
      t.references :trigger_system, foreign_key: { to_table: :solar_systems }, optional: true
      t.references :system_a, foreign_key: { to_table: :solar_systems }, optional: true
      t.references :system_b, foreign_key: { to_table: :solar_systems }, optional: true
      t.integer :event_status, default: 0
      t.integer :stability_window_hours
      t.json :system_assessments
      t.json :strategic_decisions
      t.json :stabilization_results
      t.json :learning_patterns
      t.json :event_characteristics
      t.datetime :triggered_at
      t.datetime :assessed_at
      t.datetime :decided_at
      t.datetime :executed_at
      t.datetime :completed_at
      t.datetime :failed_at
      t.string :failure_reason

      t.timestamps
    end
  end
end
