class CreateDesktopAppDynamicForms
  def self.up
    app = DesktopApplication.create(
      :description => 'Dynamic Forms',
      :icon => 'icon-document',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.DynamicForms',
      :internal_identifier => 'dynamic_forms',
      :shortcut_id => 'dynamic_forms-win'
    )
    app.save #probably redundant

    pt1 = PreferenceType.iid('desktop_shortcut')
    pt1.preferenced_records << app
    pt1.save

    pt2 = PreferenceType.iid('autoload_application')
    pt2.preferenced_records << app
    pt2.save
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','dynamic_forms'])
  end
end
