class RemoveFileSystemLoaderColumn < ActiveRecord::Migration
  def up
    remove_column :applications, :resource_loader if column_exists? :applications, :resource_loader
  end

  def down
    add_column :applications, :resource_loader, :default => "ErpApp::ApplicationResourceLoader::FileSystemLoader" unless column_exists? :applications, :resource_loader
  end
end
