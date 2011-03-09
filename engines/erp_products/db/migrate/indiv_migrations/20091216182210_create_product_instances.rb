class CreateProductInstances < ActiveRecord::Migration
  def self.up
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

	  t.column	:product_type_id,				:integer

      t.timestamps
    end
  end

  def self.down
    drop_table :product_instances
  end
end
