class AgreementsServices < ActiveRecord::Migration
  def self.up
    
    # Create agreements
    unless table_exists?(:agreements)
      create_table :agreements do |t|
        t.column  :description,       :string
        t.column  :agreement_type_id, :integer      
        t.column  :agreement_status,  :string
        t.column  :product_id,        :integer 
        t.column  :agreement_date,    :date   
        t.column  :from_date,         :date
        t.column  :thru_date,         :date
	      t.column 	:external_identifier, :string
	      t.column 	:external_id_source, 	:string
	      
        t.timestamps
      end  
    end
    
    # Create agreement types
    unless table_exists?(:agreement_types)
      create_table :agreement_types do |t|
      	t.column  :parent_id,    			:integer
      	t.column  :lft,          			:integer
      	t.column  :rgt,          			:integer

        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
		    
      	t.timestamps
      end
    end
    
    # Create agreement items
    unless table_exists?(:agreement_items)
      create_table :agreement_items do |t|
        t.column  :agreement_id,                :integer
        t.column  :agreement_item_type_id,      :integer
        t.column  :agreement_item_value,        :string
        t.column  :description,                 :string
        t.column  :agreement_item_rule_string,  :string
        
        t.timestamps
      end
    end
    
    # Create agreement item types
    unless table_exists?(:agreement_item_types)
      create_table :agreement_item_types do |t|
      	t.column  :parent_id,    			   :integer
      	t.column  :lft,          			   :integer
      	t.column  :rgt,          			   :integer

        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
		    
      	t.timestamps
      end
    end
    
    # Create agreement_party_roles
    unless table_exists?(:agreement_party_roles)
      create_table :agreement_party_roles do |t|
        t.column  :description,   	    :string 
        t.column  :agreement_id,     	  :integer  
        t.column  :party_id,         	  :integer    
        t.column  :role_type_id,     	  :integer
        t.column  :external_identifier, :string
        t.column  :external_id_source,  :string
        
        t.timestamps
      end
    end
    
    unless table_exists?(:agreement_relationships)
      create_table :agreement_relationships do |t|
        t.column  :agreement_reln_type_id,  :integer
        t.column  :description,             :string 
        t.column  :agreement_id_from,       :integer
        t.column  :agreement_id_to,         :integer
        t.column  :role_type_id_from,       :integer
        t.column  :role_type_id_to,         :integer
        t.column  :status_type_id,          :integer
        t.column  :from_date,               :date
        t.column  :thru_date,               :date 
        
        t.timestamps
      end
    end
    
    unless table_exists?(:agreement_reln_types)
      create_table :agreement_reln_types do |t|
      	t.column  	:parent_id,    :integer
      	t.column  	:lft,          :integer
      	t.column  	:rgt,          :integer
        #custom columns go here        
      	t.column  :valid_from_role_type_id,   :integer
      	t.column  :valid_to_role_type_id,     :integer
      	t.column  :name,                      :string  
      	t.column  :description,               :string
		    t.column 	:internal_identifier, 	    :string
		    t.column 	:external_identifier, 	    :string
		    t.column 	:external_id_source, 	      :string
		    
      	t.timestamps
      end
    end
    
    unless table_exists?(:agreement_role_types)
      create_table :agreement_role_types do |t|

      	t.column  	:parent_id,    			:integer
      	t.column  	:lft,          			:integer
      	t.column  	:rgt,          			:integer
        #custom columns go here   
      	t.column  :description,         :string
      	t.column  :comments,            :string
		    t.column 	:internal_identifier, :string
		    t.column 	:external_identifier, :string
		    t.column 	:external_id_source, 	:string
		    
        t.timestamps
      end  
    end
    
    unless table_exists?(:loyalty_program_codes)
      create_table :loyalty_program_codes do |t|
        t.string :identifier
        t.string :name
        t.string :description
        
        t.timestamps
      end  
    end
    
  end

  def self.down
    [
      :loyalty_program_codes, :agreement_role_types, :agreement_reln_types, 
      :agreement_relationships, :agreement_party_roles, :agreement_item_types, 
      :agreement_items, :agreements
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end

  end
end
