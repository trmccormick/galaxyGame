module AIManager
  class Error < StandardError; end
  
  class MaterialShortageError < Error
    def initialize(message)
      super(message)
    end
  end
  
  class InfrastructureSequenceError < Error
    def initialize(message)
      super(message)
    end
  end
end
