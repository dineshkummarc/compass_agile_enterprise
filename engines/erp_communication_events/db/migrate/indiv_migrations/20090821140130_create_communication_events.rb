class CreateCommunicationEvents < ActiveRecord::Migration
  def self.up
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

  def self.down
    drop_table :communication_events
  end
end
