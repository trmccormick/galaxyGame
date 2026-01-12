module HasSettlementLease
  extend ActiveSupport::Concern

  included do
    # Defines the location of the Unit (where it is physically installed)
    belongs_to :host_location, polymorphic: true, optional: true, class_name: 'Settlement::BaseSettlement'
    
    # Store dynamic data related to the lease/connection
    store_accessor :operational_data, :is_connected, :connection_type, :lease_cost_gcc
    
    after_initialize :set_default_connection_status
  end

  # Public API to check if the Unit is operational and connected.
  def operational_connected?
    is_connected == true && host_location.present?
  end
  
  # Method to initiate the connection process (e.g., paying a one-time connection fee
  # or setting up a recurring lease payment).
  def establish_connection_to_host!
    return false unless host_location.present? && owner.present?

    # Define the cost (example: 50,000 GCC one-time connection fee)
    cost = self.lease_cost_gcc || 50_000.00
    
    # Check if the owner (e.g., Astrolift) can afford the connection fee
    if owner.can_afford?(cost)
      # Debit the owner's GCC account
      owner.pay_for_connection(host_location, cost, "Unit #{self.name} Connection Fee")
      
      # Credit the settlement owner (LDC) for providing the infrastructure
      host_location.owner.receive_connection_fee(cost) 
      
      self.is_connected = true
      self.save!
      Rails.logger.info "#{owner.name} unit #{name} successfully connected to #{host_location.name}."
      true
    else
      Rails.logger.warn "#{owner.name} failed to pay connection fee of #{cost} GCC."
      self.is_connected = false
      self.save!
      false
    end
  end
  
  private

  def set_default_connection_status
    self.is_connected ||= false
  end
end