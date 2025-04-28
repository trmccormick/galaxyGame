class CreateBlueprints < ActiveRecord::Migration[7.0]
  def change
    create_table :blueprints do |t|
      t.string :name
      t.text :description
      t.json :input_resources
      t.json :output_resources
      t.integer :production_time
      t.integer :gcc_cost
      
      # Add the new fields
      t.references :player, null: false, foreign_key: true
      t.boolean :purchased, default: false
      t.integer :current_research_level, default: 0
      t.float :material_efficiency, default: 0.0
      t.float :time_efficiency, default: 0.0

      t.timestamps
    end
  end
end

