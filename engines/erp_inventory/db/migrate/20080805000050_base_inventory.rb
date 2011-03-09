class BaseInventory < ActiveRecord::Migration
  def self.up
    
    unless table_exists?(:inventory_entries)
      create_table :inventory_entries do |t|
        t.column  :description,                 :string
        t.column  :inventory_entry_record_id,   :integer
        t.column  :inventory_entry_record_type, :string
        t.column 	:external_identifier, 	      :string
        t.column 	:external_id_source, 	        :string
        t.column  :product_type_id,             :integer
        t.column  :number_available,            :integer
        t.timestamps
      end
    end
    
    unless table_exists?(:inv_entry_reln_types)
      create_table :inv_entry_reln_types do |t|
        t.column    :parent_id,    :integer
        t.column    :lft,          :integer
        t.column    :rgt,          :integer
        #custom columns go here   
        t.column    :description,           :string
        t.column    :comments,              :string
        t.column    :internal_identifier,   :string
        t.column    :external_identifier,   :string
        t.column    :external_id_source,    :string
        t.timestamps
      end
    end
    
    unless table_exists?(:inv_entry_role_types)
      create_table :inv_entry_role_types do |t|
        t.column    :parent_id,    :integer
        t.column    :lft,          :integer
        t.column    :rgt,          :integer
        #custom columns go here   
        t.column    :description,           :string
        t.column    :comments,              :string
        t.column    :internal_identifier,   :string
        t.column    :external_identifier,   :string
        t.column    :external_id_source,    :string
        t.timestamps
      end
    end
    
    unless table_exists?(:inv_entry_relns)
      create_table :inv_entry_relns do |t|
        t.column  :inv_entry_reln_type_id,  :integer
        t.column  :description,             :string 
        t.column  :inv_entry_id_from,       :integer
        t.column  :inv_entry_id_to,         :integer
        t.column  :role_type_id_from,       :integer
        t.column  :role_type_id_to,         :integer
        t.column  :status_type_id,          :integer
        t.column  :from_date,               :date
        t.column  :thru_date,               :date 
        t.timestamps
      end
    end
    
    unless table_exists?(:prod_instance_inv_entries)
      create_table :prod_instance_inv_entries do |t|
        t.column  :product_instance_id,   :integer        
        t.column  :inventory_entry_id,    :integer  
        t.timestamps
      end
    end

  end

  def self.down
    [
      :prod_instance_inv_entries,:inv_entry_relns, 
      :inv_entry_role_types, :inv_entry_reln_types, :inventory_entries
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
  
end
