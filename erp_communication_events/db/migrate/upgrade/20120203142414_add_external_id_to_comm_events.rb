class AddExternalIdToCommEvents < ActiveRecord::Migration
  def up
    unless column_exists? :communication_events, :external_identifier
      add_column :communication_events, :external_identifier, :string
    end
  end

  def down
    if column_exists? :communication_events, :external_identifier
      remove_column :communication_events, :external_identifier
    end
  end
end
