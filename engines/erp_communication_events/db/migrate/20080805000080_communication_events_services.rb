class CommunicationEventsServices < ActiveRecord::Migration
  def self.up
    
    # Create communications_events
    unless table_exists?(:communication_events)
      create_table :communication_events do |t|
        t.column  :short_description,       :string      
        t.column  :status_type_id,          :integer
        t.column  :case_id,                 :integer
        t.column  :contact_mechanism_type,  :string
        t.column  :role_type_id_from,       :integer
        t.column  :role_type_id_to,         :integer
        t.column  :party_id_from,           :integer
        t.column  :party_id_to,             :integer
        t.column  :date_time_started,       :datetime
        t.column  :date_time_ended,         :datetime
        t.column  :notes,                   :string
        t.timestamps
      end
    end
    
    # Create comm_evt_purpose_types
    unless table_exists?(:comm_evt_purpose_types)
      create_table :comm_evt_purpose_types do |t|
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
    
    # Create comm_evt_purposes
    unless table_exists?(:comm_evt_purposes)
      create_table :comm_evt_purposes, :id => false do |t|
        t.column  :communication_event_id,    	:integer      
        t.column  :comm_evt_purpose_type_id,   	:integer
        t.timestamps
      end
    end
    
    # Create comm_evt_statuses
    unless table_exists?(:comm_evt_statuses)
      create_table :comm_evt_statuses do |t|
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
    
    # Create comm_evt_status_types
    unless table_exists?(:comm_evt_status_types)
      create_table :comm_evt_status_types do |t|
        t.timestamps
      end
    end
    
  end

  def self.down
    [
      :comm_evt_status_types, :comm_evt_statuses, :comm_evt_purposes, 
      :comm_evt_purpose_types, :communication_events
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
  
end
