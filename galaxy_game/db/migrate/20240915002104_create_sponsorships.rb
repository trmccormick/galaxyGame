class CreateSponsorships < ActiveRecord::Migration[6.1]
  def change
    create_table :sponsorships do |t|
      t.string :name
      t.references :sponsorable, polymorphic: true, index: true
      t.timestamps
    end
  end
end
