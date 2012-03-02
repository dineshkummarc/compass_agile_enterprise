class AddFromToNumbersToCmmEvt < ActiveRecord::Migration
  def up
    unless column_exists? :communication_events, :from_contact_mechanism_id
      add_column :communication_events, :from_contact_mechanism_id, :integer
      add_column :communication_events, :from_contact_mechanism_type, :string

      add_index :communication_events, [:from_contact_mechanism_id, :from_contact_mechanism_type], :name => 'from_contact_mech_idx'
    end

    unless column_exists? :communication_events, :to_contact_mechanism_id
      add_column :communication_events, :to_contact_mechanism_id, :integer
      add_column :communication_events, :to_contact_mechanism_type, :string

      add_index :communication_events, [:to_contact_mechanism_id, :to_contact_mechanism_type], :name => 'to_contact_mech_idx'
    end
  end

  def down
    if column_exists? :communication_events, :from_contact_mechanism_id
      remove_column :communication_events, :from_contact_mechanism_id
      remove_column :communication_events, :from_contact_mechanism_type

      remove_index :communication_events, 'from_contact_mech_idx'
    end

    if column_exists? :communication_events, :to_contact_mechanism_id
      remove_column :communication_events, :to_contact_mechanism_id
      remove_column :communication_events, :to_contact_mechanism_type

      remove_index :communication_events, 'to_contact_mech_idx'
    end
  end
end
