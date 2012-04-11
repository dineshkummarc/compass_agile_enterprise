def self.up
  app = MobileApplication.create(
    :description => '<%=description %>',
    :icon => '<%=icon %>',
    :internal_identifier => '<%=file_name %>'
  )

  app.save

end

def self.down
  MobileApplication.destroy_all(['internal_identifier = ?','<%=file_name %>'])
end