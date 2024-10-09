class Diplomacy < ApplicationRecord
    belongs_to :colony
    belongs_to :other_colony, class_name: 'Colony'
  
    enum status: { neutral: 0, friendly: 1, hostile: 2 }
  
    # Adjust diplomacy based on actions (trades, agreements)
    def adjust_status(new_status)
      update(status: new_status)
    end
end