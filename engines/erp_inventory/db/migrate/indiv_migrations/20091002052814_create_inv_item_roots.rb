class CreateInvItemRoots < ActiveRecord::Migration
  def self.up
    create_table :inv_item_roots do |t|

      t.column :inv_item_type_id,      :integer
      t.column :description,           :string
      t.column :status,                :integer
		    			
      t.column :inv_item_record_id,    :integer
      t.column :inv_item_record_type,  :string

      t.column :external_identifier,   :string
      t.column :external_id_source,    :string

      t.timestamps

    end
  end

  def self.down
    drop_table :inv_item_roots
  end
end
