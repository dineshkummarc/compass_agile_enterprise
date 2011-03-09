class AddFacilityToWorkEffort < ActiveRecord::Migration
  def self.up
    add_column :work_efforts, :facility_type, :string
    add_column :work_efforts, :facility_id, :integer
  end

  def self.down
    remove_column :work_efforts, :facility_id
    remove_column :work_efforts, :facility_type
  end
end
