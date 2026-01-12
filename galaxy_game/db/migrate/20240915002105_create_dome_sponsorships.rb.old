class CreateDomeSponsorships < ActiveRecord::Migration[6.1]
  def change
    create_table :dome_sponsorships do |t|
      t.references :dome, null: false, foreign_key: true
      t.references :sponsorship, null: false, foreign_key: true
      t.timestamps
    end
  end
end
