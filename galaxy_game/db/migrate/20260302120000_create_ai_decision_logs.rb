class CreateAiDecisionLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_decision_logs do |t|
      t.references :celestial_body, null: false, foreign_key: true
      t.string :location_context, null: false
      t.string :decision_type, null: false
      t.text :reasoning, null: false
      t.text :constraints
      t.text :outcome
      t.jsonb :metadata
      t.timestamps
    end
    add_index :ai_decision_logs, [:celestial_body_id, :location_context], name: 'idx_aidlog_body_loc'
  end
end
