class UpdateAppContainer < ActiveRecord::Migration
  def up
    add_column :app_containers, :type, :string

    AppContainer.all.each do |app_container|
      app_container.type = app_container.app_container_record_type
      app_container.save
    end

    remove_column :app_containers, :app_container_record_id
    remove_column :app_containers, :app_container_record_type

    drop_table :desktops
    drop_table :organizers
  end

  def down
  end
end
