class CreatePartyResourceAvailabilityTypes < ActiveRecord::Migration
  def self.up
    create_table :party_resource_availability_types do |t|
      t.string :description
      t.string :internal_identifier

      t.timestamps
    end
  end

  def self.down
    drop_table :party_resource_availability_types
  end
end
