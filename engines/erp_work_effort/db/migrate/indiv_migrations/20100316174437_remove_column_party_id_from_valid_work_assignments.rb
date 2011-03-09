class RemoveColumnPartyIdFromValidWorkAssignments < ActiveRecord::Migration
  def self.up
    remove_column :valid_work_assignments, :party_id
  end

  def self.down
    add_column :valid_work_assignments, :party_id, :integer
  end
end