class CreateWebsiteRoleTypes
  
  def self.up
    RoleType.create(:description => 'Website Owner', :internal_identifier => 'website_owner')
    RoleType.create(:description => 'Website Member', :internal_identifier => 'website_member')
  end
  
  def self.down
    RoleType.website_owner.destroy
    RoleType.website_member.destroy
  end

end
