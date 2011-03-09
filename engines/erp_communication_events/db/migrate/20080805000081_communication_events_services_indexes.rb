class CommunicationEventsServicesIndexes < ActiveRecord::Migration
  def self.up
    add_index :communication_events, :status_type_id
    add_index :communication_events, :case_id
    
    add_index :comm_evt_purpose_types, :parent_id
    
    add_index :comm_evt_purposes, :communication_event_id
    add_index :comm_evt_purposes, :comm_evt_purpose_type_id
    
    add_index :comm_evt_statuses, :parent_id
  end

  def self.down
    remove_index :communication_events, :status_type_id
    remove_index :communication_events, :case_id
    
    remove_index :comm_evt_purpose_types, :parent_id
    
    remove_index :comm_evt_purposes, :communication_event_id
    remove_index :comm_evt_purposes, :comm_evt_purpose_type_id
    
    remove_index :comm_evt_statuses, :parent_id
  end
end
