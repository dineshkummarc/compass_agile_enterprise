class CreateCompassDriveDesktopApplication
  def self.up
    app = DesktopApplication.create(
      :description => 'CompassDrive',
      :icon => 'icon-harddrive',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.CompassDrive',
      :internal_identifier => 'compass_drive',
      :shortcut_id => 'compass_drive-win'
    )
    pt1 = PreferenceType.iid('desktop_shortcut')
    pt1.preferenced_records << app
    pt1.save

    pt2 = PreferenceType.iid('autoload_application')
    pt2.preferenced_records << app
    pt2.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','compass_drive'])
  end
end
