class CreatePartyResourceAvailabilities < ActiveRecord::Migration
  def self.up
    create_table :party_resource_availabilities do |t|
      t.datetime :from_date
      t.datetime :to_date
      t.integer :party_id
      t.integer :party_resource_availability_type_id

      t.timestamps
    end
  end

  def self.down
    drop_table :party_resource_availabilities
  end
end
