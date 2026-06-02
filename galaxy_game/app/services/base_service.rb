# frozen_string_literal: true

# A minimal BaseService used as a common parent for namespaced service classes.
# Provides a simple `call` convention; expand if services rely on shared helpers.
class BaseService
  def self.call(*args)
    new(*args).call
  end
end
