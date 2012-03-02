class CommunicationEventsServices < ActiveRecord::Migration
  def self.up
    
    # Create communications_events
    unless table_exists?(:communication_events)
      create_table :communication_events do |t|
        t.integer  :from_contact_mechanism_id
        t.string   :from_contact_mechanism_type

        t.integer  :to_contact_mechanism_id
        t.string   :to_contact_mechanism_type

        t.integer  :role_type_id_from
        t.integer  :role_type_id_to

        t.integer  :party_id_from
        t.integer  :party_id_to

        t.string   :short_description
        t.integer  :status_type_id
        t.integer  :case_id
        t.datetime :date_time_started
        t.datetime :date_time_ended
        t.string   :notes
        t.string   :external_identifier
        t.string   :external_id_source
        
        t.timestamps
      end

      add_index :communication_events, :status_type_id
      add_index :communication_events, :case_id
      add_index :communication_events, :role_type_id_from
      add_index :communication_events, :role_type_id_to
      add_index :communication_events, :party_id_from
      add_index :communication_events, :party_id_to
      add_index :communication_events, [:to_contact_mechanism_id, :to_contact_mechanism_type], :name => 'to_contact_mech_idx'
      add_index :communication_events, [:from_contact_mechanism_id, :from_contact_mechanism_type], :name => 'from_contact_mech_idx'
    end
    
    # Create comm_evt_purpose_types
    unless table_exists?(:comm_evt_purpose_types)
      create_table :comm_evt_purpose_types do |t|
      	#awesome nested set columns
        t.integer  :parent_id
      	t.integer  :lft
      	t.integer  :rgt
        
        #custom columns go here   
      	t.string  :description
      	t.string  :comments
		    t.string 	:internal_identifier
		    t.string 	:external_identifier
		    t.string 	:external_id_source

      	t.timestamps
      end

      add_index :comm_evt_purpose_types, :parent_id
    end
    
    # Create comm_evt_purposes
    unless table_exists?(:comm_evt_purposes)
      create_table :comm_evt_purposes, :id => false do |t|
        t.integer  :communication_event_id
        t.integer  :comm_evt_purpose_type_id
        
        t.timestamps
      end

      add_index :comm_evt_purposes, :communication_event_id
      add_index :comm_evt_purposes, :comm_evt_purpose_type_id
    end
    
    # Create comm_evt_statuses
    unless table_exists?(:comm_evt_statuses)
      create_table :comm_evt_statuses do |t|
	  	  #awesome nested set columns
        t.integer  :parent_id
	  	  t.integer  :lft
	  	  t.integer  :rgt

        #custom columns go here
	  	  t.string  :description
	  	  t.string  :comments
		    t.string 	:internal_identifier
		    t.string 	:external_identifier
		    t.string 	:external_id_source
        
	  	  t.timestamps
      end
      
      add_index :comm_evt_statuses, :parent_id
    end
    
  end

  def self.down
    [
      :comm_evt_statuses, :comm_evt_purposes, 
      :comm_evt_purpose_types, :communication_events
    ].each do |tbl|
      if table_exists?(tbl)
        drop_table tbl
      end
    end
  end
  
end
