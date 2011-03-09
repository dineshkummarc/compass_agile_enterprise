class CreateInventoryEntries < ActiveRecord::Migration
  def self.up
    create_table :inventory_entries do |t|

      t.column  :description,                 :string
      					
      t.column  :inventory_entry_record_id,     :integer
      t.column  :inventory_entry_record_type,   :string
      
      t.column 	:external_identifier, 	      :string
      t.column 	:external_id_source, 	        :string

      t.timestamps
    end
  end

  def self.down
    drop_table :inventory_entries
  end
end
