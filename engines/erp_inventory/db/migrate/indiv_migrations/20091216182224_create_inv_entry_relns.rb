class CreateInvEntryRelns < ActiveRecord::Migration
  def self.up
    create_table :inv_entry_relns do |t|

      t.column  :inv_entry_reln_type_id, :integer
      t.column  :description, :string 
      
      t.column  :inv_entry_id_from, :integer
      t.column  :inv_entry_id_to, :integer

      t.column  :role_type_id_from, :integer
      t.column  :role_type_id_to, :integer

      t.column  :status_type_id, :integer
      t.column  :from_date, :date
      t.column  :thru_date, :date 

      t.timestamps
    end
  end

  def self.down
    drop_table :inv_entry_relns
  end
end
