class Create<%=class_name %>OrganizerApplication
  def self.up
    OrganizerApplication.create(
      :description => '<%=description %>',
      :icon => '<%=icon %>',
      :javascript_class_name => 'Compass.ErpApp.Organizer.Applications.<%=class_name %>.Base',
      :internal_identifier => '<%=file_name %>'
    )
  end

  def self.down
    OrganizerApplication.destroy_all(:conditions => ['internal_identifier = ?','<%=file_name %>'])
  end
end
