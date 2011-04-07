class CreateDesktopAppTenancy
  def self.up
    app = DesktopApplication.create(
      :description => 'Tenancy',
      :icon => 'icon-house',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Tenancy',
      :internal_identifier => 'tenancy',
      :shortcut_id => 'tenancy-win'
    )
    
    PreferenceType.iid('desktop_shortcut').preferenced_records << app
    PreferenceType.iid('autoload_application').preferenced_records << app

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','hello_world'])
  end
end
