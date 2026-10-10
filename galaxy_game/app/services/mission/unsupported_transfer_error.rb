# frozen_string_literal: true

# Raised by Mission::TransitEngine when a resolved endpoint (or endpoint pair)
# fails the Phase 1 topology proxy. See the topology-containment task.
class Mission::UnsupportedTransferError < StandardError; end
