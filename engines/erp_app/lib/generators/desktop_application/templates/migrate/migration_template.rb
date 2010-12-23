class CreateDesktopApp<%=class_name %>
  def self.up
    Application.create(
      :description => '<%=description %>',
      :icon => '<%=icon %>',
      :javascript_class_name => 'Compass.ErpApp.Desktop.Applications.<%=class_name %>',
      :internal_identifier => '<%=file_name %>',
      :shortcut_id => '<%=file_name %>-win',
      :javascript_src => 'module.js'
    )
  end

  def self.down
    Application.destroy_all(:conditions => 'internal_identifier = <%=file_name %>')
  end
end
