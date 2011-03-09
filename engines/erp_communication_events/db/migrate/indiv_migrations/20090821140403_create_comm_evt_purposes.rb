class CreateCommEvtPurposes < ActiveRecord::Migration
  def self.up
    create_table :comm_evt_purposes, :id => false do |t|

      t.column  :communication_event_id,    	:integer      
      t.column  :comm_evt_purpose_type_id,   	:integer

      t.timestamps

    end
  end

  def self.down
    drop_table :comm_evt_purposes
  end
end
