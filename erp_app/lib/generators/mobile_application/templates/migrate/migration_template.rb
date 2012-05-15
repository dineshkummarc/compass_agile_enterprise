class Create<%=class_name %>MobileApplication
  def self.up
    app = MobileApplication.create(
      :description => '<%=description %>',
      :icon => '<%=icon %>',
      :internal_identifier => '<%=file_name %>',
      :base_url => '/erp_app/mobile/<%=file_name %>/index'
    )
  end

  def self.down
    MobileApplication.destroy_all("internal_identifier = '<%=file_name %>'")
  end
end