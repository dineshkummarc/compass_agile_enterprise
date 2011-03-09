class CreateAgreementRelnTypes < ActiveRecord::Migration
  def self.up
    create_table :agreement_reln_types do |t|
    	
      	t.column  	:parent_id,    :integer
      	t.column  	:lft,          :integer
      	t.column  	:rgt,          :integer

    #custom columns go here        
      
      	t.column  	:valid_from_role_type_id, :integer
      	t.column  	:valid_to_role_type_id, :integer
      	t.column  	:name, :string  
      	t.column  	:description, :string

		t.column 	:internal_identifier, 	:string
		
		t.column 	:external_identifier, 	:string
		t.column 	:external_id_source, 	:string

      	t.timestamps

    end
  end

  def self.down
    drop_table :agreement_reln_types
  end
end
