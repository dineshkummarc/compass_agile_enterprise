class CreateDesktopAppScaffold
  def self.up
    app = DesktopApplication.create(
      :description => 'Scaffold',
      :icon => 'icon-data',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Scaffold',
      :internal_identifier => 'scaffold',
      :shortcut_id => 'scaffold-win'
    )
    
    PreferenceType.iid('desktop_shortcut').preferenced_records << app
    PreferenceType.iid('autoload_application').preferenced_records << app

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','hello_world'])
  end
end
