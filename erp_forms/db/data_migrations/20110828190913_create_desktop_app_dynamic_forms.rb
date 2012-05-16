class CreateDesktopAppDynamicForms
  def self.up
#    app = DesktopApplication.create(
#      :description => 'Dynamic Forms',
#      :icon => 'icon-document',
#      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.DynamicForms',
#      :internal_identifier => 'dynamic_forms',
#      :shortcut_id => 'dynamic_forms-win'
#    )
#    app.preference_types << PreferenceType.iid('desktop_shortcut')
#    app.preference_types << PreferenceType.iid('autoload_application')
#    app.save #probably redundant
  end

  def self.down
    DesktopApplication.destroy_all(['internal_identifier = ?','dynamic_forms'])
  end
end
