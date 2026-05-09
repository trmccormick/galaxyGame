## NOTE: This concern is currently unused in the codebase.
#
# All storage logic is handled via operational_data['storage'] and manager classes (see BaseUnit and StorageManager).
# If you want to use this concern, refactor it to read/write from operational_data['storage'] instead of direct attributes.
# Otherwise, consider removing it to avoid confusion.
#
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
  
  
  