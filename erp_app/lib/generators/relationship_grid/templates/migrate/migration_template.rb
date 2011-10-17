class Create<%=class_name %>RelationshipGrid
  def self.up
    app = Application.where('internal_identifier = ?', 'crm').first
    widget = Widget.create(:description => '<%=description %>',
                  :internal_identifier => '<%=file_name %>',
                  :xtype => '<%=file_name %>')
    app.widgets << widget
  end

  def self.down
    Widget.destroy_all(:conditions => ['internal_identifier = ?', '<%=file_name %>'])
  end

end
