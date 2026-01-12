# app/models/biology/life_form_parent.rb
module Biology
  class LifeFormParent < ApplicationRecord
    self.table_name = 'biology_life_form_parents'
    
    belongs_to :parent, class_name: 'Biology::BaseLifeForm'
    belongs_to :child, class_name: 'Biology::BaseLifeForm'
  end
end