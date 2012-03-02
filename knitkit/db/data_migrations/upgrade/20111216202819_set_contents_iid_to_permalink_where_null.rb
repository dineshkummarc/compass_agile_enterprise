class SetContentsIidToPermalinkWhereNull < ActiveRecord::Migration
  
  def self.up
    #insert data here
    execute "UPDATE contents SET internal_identifier=permalink WHERE internal_identifier IS NULL"
  end
  
  def self.down
    #remove data here
  end

end
