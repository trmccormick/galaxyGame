# app/models/concerns/storage.rb
module Storage
    extend ActiveSupport::Concern
  
    included do
      attr_accessor :storage_capacity
    end
  
    def initialize_storage(capacity)
      @storage_capacity = capacity
      puts "Storage unit initialized with a capacity of #{capacity} kg."
    end
  
    def can_store?(amount)
      (current_stock + amount) <= storage_capacity
    end
end
  
  
  