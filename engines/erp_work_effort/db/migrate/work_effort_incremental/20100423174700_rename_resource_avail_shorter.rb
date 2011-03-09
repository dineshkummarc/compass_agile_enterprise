class RenameResourceAvailShorter < ActiveRecord::Migration
  def self.up
    rename_column :party_resource_availabilities, :party_resource_availability_type_id, :pra_type_id
  end

  def self.down
    rename_column :party_resource_availabilities, :pra_type_id, :party_resource_availability_type_id
  end
end
