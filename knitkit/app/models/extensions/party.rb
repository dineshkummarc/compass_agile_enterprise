Party.class_eval do
  has_many :website_party_roles, :dependent => :destroy
  has_many :websites, :through =>:website_party_roles do
    def owned
      where('role_type_id = ?',RoleType.website_owner).collect(&:website)
    end
  end

  def add_website_with_role(website, role_type)
    self.website_party_roles << WebsitePartyRole.create(:website => website, :role_type => role_type)
    self.save
  end
end
