class RenameUserTypeColumn < ActiveRecord::Migration
  def self.up
    # if user_type does not exist do nothing
    if columns(:users).collect {|c| c.name }.include?('user_type')
      # if type already exists, drop user_type
      if columns(:users).collect {|c| c.name }.include?('type')
        remove_column :users, :user_type
      else
        # if type does not exist, rename user_type to type
        rename_column :users, :user_type, :type
      end    
    end
  end

  def self.down
    # no down method, do nothing
  end
end
