class Create<%=class_name %>DesktopApplication
  def self.up
    app = DesktopApplication.create(
      :description => '<%=description %>',
      :icon => '<%=icon %>',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.<%=class_name %>',
      :internal_identifier => '<%=file_name %>',
      :shortcut_id => '<%=file_name %>-win'
    )
    pt1 = PreferenceType.iid('desktop_shortcut')
    pt1.preferenced_records << app
    pt1.save

    pt2 = PreferenceType.iid('autoload_application')
    pt2.preferenced_records << app
    pt2.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','<%=file_name %>'])
  end
end
