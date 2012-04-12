class UpdateAppContainer < ActiveRecord::Migration
  def up
    unless columns(:app_containers).collect {|c| c.name}.include?('type')
      add_column :app_containers, :type, :string

      execute("UPDATE app_containers SET type = app_container_record_type")

      remove_column :app_containers, :app_container_record_id
      remove_column :app_containers, :app_container_record_type

      add_index :app_containers, :type

      drop_table :desktops
      drop_table :organizers
    end
  end

  def down
  end
end
