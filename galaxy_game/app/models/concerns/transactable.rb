module Transactable
  extend ActiveSupport::Concern
  
  included do
    has_one :account, as: :owner, dependent: :destroy
    
    after_create :create_default_account
  end
  
  private
  
  def create_default_account
    # Create an account for the transactable entity if one doesn't exist
    build_account.save unless account.present?
  end
end