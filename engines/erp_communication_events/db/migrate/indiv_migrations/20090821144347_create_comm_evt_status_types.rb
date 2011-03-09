class CreateCommEvtStatusTypes < ActiveRecord::Migration
  def self.up
    create_table :comm_evt_status_types do |t|


      t.timestamps

    end
  end

  def self.down
    drop_table :comm_evt_status_types
  end
end
