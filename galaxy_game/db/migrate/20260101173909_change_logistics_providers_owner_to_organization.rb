class ChangeLogisticsProvidersOwnerToOrganization < ActiveRecord::Migration[7.0]
  def change
    # Remove the polymorphic owner reference
    remove_reference :logistics_providers, :owner, polymorphic: true, null: false
    
    # Add organization reference
    add_reference :logistics_providers, :organization, null: false, foreign_key: { to_table: :organizations }
  end
end