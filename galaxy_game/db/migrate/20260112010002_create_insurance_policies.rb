class CreateInsurancePolicies < ActiveRecord::Migration[7.0]
  def change
    create_table :insurance_policies do |t|
      t.references :insurance_corporation, null: false
      t.references :policy_holder, polymorphic: true, null: false
      t.references :covered_contract, polymorphic: true, null: false
      t.integer :policy_type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.decimal :coverage_amount, precision: 15, scale: 2
      t.decimal :premium_amount, precision: 15, scale: 2
      t.decimal :deductible, precision: 15, scale: 2, default: 0.0
      t.decimal :coverage_percentage, precision: 5, scale: 4
      t.json :risk_factors
      t.json :underwriting_data
      t.datetime :effective_date
      t.datetime :expiration_date
      t.timestamps
    end

    add_index :insurance_policies, [:policy_holder_type, :policy_holder_id], name: 'idx_ins_policies_holder'
    add_index :insurance_policies, [:covered_contract_type, :covered_contract_id], name: 'idx_ins_policies_contract'
    add_index :insurance_policies, :status
  end
end