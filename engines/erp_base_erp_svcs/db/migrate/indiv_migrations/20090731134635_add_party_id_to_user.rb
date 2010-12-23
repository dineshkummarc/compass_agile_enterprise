class AddPartyIdToUser < ActiveRecord::Migration
  def self.up

    add_column :users, :party_id, :integer
  	
  end

  def self.down
  	
    remove_column :users, :party_id	
  	
  end
end
