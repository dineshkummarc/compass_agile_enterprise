class CreateDesktopAppRailsDbAdmin
  def self.up
    app = DesktopApplication.create(
      :description => 'RailsDbAdmin',
      :icon => 'icon-rails-db-admin',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.RailsDbAdmin',
      :internal_identifier => 'rails_db_admin',
      :shortcut_id => 'rails_db_admin-win'
    )
    
    PreferenceType.iid('desktop_shortcut').preferenced_records << app
    PreferenceType.iid('autoload_application').preferenced_records << app

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','rails_db_admin'])
  end
end
