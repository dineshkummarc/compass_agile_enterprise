class CreateTenatesTable < ActiveRecord::Migration
  def self.up
    unless table_exists?(:tenates)
      create_table :tenates do |t|
        t.string :domain
        t.string :schema
        t.string :route
        
    	  t.timestamps
      end
    end
  end

  def self.down
    if table_exists?(:tenates)
      drop_table :tenates
    end
  end
end
