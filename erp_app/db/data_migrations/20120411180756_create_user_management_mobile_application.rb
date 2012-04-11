class CreateUserManagementMobileApplication

  def self.up
    app = MobileApplication.create(
      :description => 'User Management',
      :icon => 'icon-user',
      :internal_identifier => 'user_management',
      :base_url => '/erp_app/mobile/user_management/index'
    )

    app.save
  end

  def self.down
    MobileApplication.destroy_all("internal_identifier = 'user_management'")
  end

end