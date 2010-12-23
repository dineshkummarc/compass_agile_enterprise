class UniqueUsersPartyId < ActiveRecord::Migration
  def self.up
    # add_index :users, :party_id, :unique => true
  end

  def self.down
    #remove_index :users, :party_id
  end
end
