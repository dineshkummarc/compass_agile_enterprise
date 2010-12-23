class CreateSiteUserRole < ActiveRecord::Migration
  def self.up
    role1 = Role.new
    #Admin role name should be "admin" for convenience
    role1.name = "site_user"
    role1.save(false)
  end

  def self.down
  end
end
