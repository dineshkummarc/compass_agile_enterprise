class AddFileManagerApplication
  
  def self.up
    file_manager_app = DesktopApplication.create(
      :description => 'File Manager',
      :icon => 'icon-folders',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.FileManager',
      :internal_identifier => 'file_manager',
      :shortcut_id => 'file_manager-win'
    )

    file_manager_app.preference_types << PreferenceType.iid('desktop_shortcut')
    file_manager_app.preference_types << PreferenceType.iid('autoload_application')
    file_manager_app.save
    
    admin_user = User.find_by_username('admin')
    admin_user.desktop.applications << file_manager_app
    admin_user.save
    
    truenorth_user = User.find_by_username('truenorth')
    truenorth_user.desktop.applications << file_manager_app
    truenorth_user.save
  end
  
  def self.down
    DesktopApplication.find_by_internal_identifier('file_manager').destroy
  end

end
