class RailsDbAdminApplication
  
  def self.up
    rails_db_admin_app = DesktopApplication.create(
      :description => 'RailsDbAdmin',
      :icon => 'icon-rails_db_admin',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.RailsDbAdmin',
      :internal_identifier => 'rails_db_admin',
      :shortcut_id => 'rails_db_admin-win'
    )

    rails_db_admin_app.preference_types << PreferenceType.iid('desktop_shortcut')
    rails_db_admin_app.preference_types << PreferenceType.iid('autoload_application')
    rails_db_admin_app.save
    
    admin_user = User.find_by_username('admin')
    admin_user.desktop.applications << rails_db_admin_app
    admin_user.save
    
    truenorth_user = User.find_by_username('truenorth')
    truenorth_user.desktop.applications << rails_db_admin_app
    truenorth_user.save
  end
  
  def self.down
    DesktopApplication.find_by_internal_identifier('rails_db_admin').destroy
  end

end
