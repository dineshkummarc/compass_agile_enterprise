class CreateCommEvtStatuses < ActiveRecord::Migration
  def self.up
    create_table :comm_evt_statuses do |t|

	  	t.column  	:parent_id,    			:integer
	  	t.column  	:lft,          			:integer
	  	t.column  	:rgt,          			:integer
	
	#custom columns go here   
	
	  	t.column  	:description, :string
	  	t.column  	:comments, :string
	
		t.column 	:internal_identifier, 	:string
		
		t.column 	:external_identifier, 	:string
		t.column 	:external_id_source, 	:string
	
	  	t.timestamps

    end
  end

  def self.down
    drop_table :comm_evt_statuses
  end
end
