class CreateDesktopAppKnitkit
  def self.up
    app = DesktopApplication.create(
      :description => 'KnitKit',
      :icon => 'icon-globe',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.Knitkit',
      :internal_identifier => 'knitkit',
      :shortcut_id => 'knitkit-win'
    )
    
    PreferenceType.iid('desktop_shortcut').preferenced_records << app
    PreferenceType.iid('autoload_application').preferenced_records << app

    app.save
  end

  def self.down
    DesktopApplication.destroy_all(:conditions => ['internal_identifier = ?','hello_world'])
  end
end
