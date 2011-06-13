class BaseProducts < ActiveRecord::Migration
  def self.up
    
    unless table_exists?(:product_types)
      create_table :product_types do |t|
        #these columns are required to support the behavior of the plugin 'better_nested_set'
        #ALL products have the ability to act as packages in a nested set-type structure
        #
        #The package behavior is treated differently from other product_relationship behavior
        #which is implemented using a standard relationship structure.
        #
        #This is to allow quick construction of highly nested product types.
        t.column  	:parent_id,    :integer
        t.column  	:lft,          :integer
        t.column  	:rgt,          :integer

        #custom columns go here   
        t.column  :description,                 :string			
        t.column  :product_type_record_id,      :integer
        t.column  :product_type_record_type,    :string
        t.column 	:external_identifier, 	      :string
        t.column 	:external_id_source, 	        :string
        t.column  :default_image_url,           :string
        t.column  :list_view_image_id,          :integer
        t.timestamps
      end
    end
    
    unless table_exists?(:product_instances)
      create_table :product_instances do |t|
        #these columns are required to support the behavior of the plugin 'better_nested_set'
        #ALL products have the ability to act as packages in a nested set-type structure
        #
        #The package behavior is treated differently from other product_relationship behavior
        #which is implemented using a standard relationship structure.
        #
        #This is to allow quick construction of highly nested product types.
        t.column  	:parent_id,    :integer
        t.column  	:lft,          :integer
        t.column  	:rgt,          :integer

        #custom columns go here   
        t.column  :description,                   :string	
	      t.column  :product_instance_record_id,    :integer
	      t.column  :product_instance_record_type,  :string
			  t.column 	:external_identifier, 	        :string
			  t.column 	:external_id_source, 	          :string
	      t.column	:product_type_id,				        :integer
	      t.column  :type,                          :string

        t.references :prod_availability_status_type

        t.timestamps
      end
    end
    
    unless table_exists?(:product_offers)
      create_table :product_offers do |t|
        t.column  :description,                 :string
	      t.column  :product_offer_record_id,     :integer
	      t.column  :product_offer_record_type,   :string
		  	t.column 	:external_identifier, 	      :string
		  	t.column 	:external_id_source, 	        :string
        t.timestamps
      end
    end
    
    unless table_exists?(:simple_product_offers)
      create_table :simple_product_offers do |t|
        t.column  :description,   :string
        t.column  :product_id,    :integer
        t.column  :base_price,    :float
        t.column  :uom,           :integer
        t.timestamps
      end
    end
    
    unless table_exists?(:prod_instance_reln_types)
      create_table :prod_instance_reln_types do |t|
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
    
    unless table_exists?(:prod_instance_role_types)
      create_table :prod_instance_role_types do |t|
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
    
    unless table_exists?(:prod_instance_relns)
      create_table :prod_instance_relns do |t|
        t.column  :prod_instance_reln_type_id,  :integer
        t.column  :description,                 :string 
        t.column  :prod_instance_id_from,       :integer
        t.column  :prod_instance_id_to,         :integer
        t.column  :role_type_id_from,           :integer
        t.column  :role_type_id_to,             :integer
        t.column  :status_type_id,              :integer
        t.column  :from_date,                   :date
        t.column  :thru_date,                   :date 
        t.timestamps
      end
    end
    
    unless table_exists?(:prod_type_reln_types)
      create_table :prod_type_reln_types do |t|
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
    
    unless table_exists?(:prod_type_role_types)
      create_table :prod_type_role_types do |t|
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
    
    unless table_exists?(:prod_type_relns)
      create_table :prod_type_relns do |t|
        t.column  :prod_type_reln_type_id,  :integer
        t.column  :description,             :string 
        t.column  :prod_type_id_from,       :integer
        t.column  :prod_type_id_to,         :integer
        t.column  :role_type_id_from,       :integer
        t.column  :role_type_id_to,         :integer
        t.column  :status_type_id,          :integer
        t.column  :from_date,               :date
        t.column  :thru_date,               :date 
        t.timestamps
      end
    end
    
    unless table_exists?(:product_instance_status_types)
        create_table :product_instance_status_types do |t|
          #better nested set colummns
          t.column :parent_id, :integer
          t.column :lft,       :integer
          t.column :rgt,       :integer
          
           t.column :description,             :string
           t.column :internal_identifier,     :string
           t.column :external_identifier,     :string
           t.column :external_id_source,      :string
          
          t.timestamps
        end
    end
    
    unless table_exists?(:prod_availability_status_types)
      create_table :prod_availability_status_types do |t|
        #better nested set colummns
        t.column :parent_id, :integer
        t.column :lft,       :integer
        t.column :rgt,       :integer
        
        t.column :description,             :string
        t.column :internal_identifier,     :string
        t.column :external_identifier,     :string
        t.column :external_id_source,      :string
        
        t.timestamps
      end
    end
    
    unless table_exists?(:prod_availability_status_types)
      create_table :prod_availability_status_types do |t|
        #better nested set colummns
        t.column :parent_id, :integer
        t.column :lft,       :integer
        t.column :rgt,       :integer
        
        t.column :description,             :string
        t.column :internal_identifier,     :string
        t.column :external_identifier,     :string
        t.column :external_id_source,      :string
        
        t.timestamps
      end
    end
    

  end

  def self.down
    [
      :prod_type_relns, :prod_type_role_types, :prod_type_reln_types, 
      :prod_instance_relns, :prod_instance_role_types, :prod_instance_reln_types, 
      :simple_product_offers, :product_offers, :product_instances, 
      :product_types,:prod_availability_status_types
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
end
