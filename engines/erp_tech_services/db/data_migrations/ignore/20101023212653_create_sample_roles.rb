class CreateSampleRoles

  def self.up
    Role.create(:description => 'admin', :internal_identifier => 'admin')
    Role.create(:description => 'employee', :internal_identifier => 'employee')
  end

  def self.down
    ['admin', 'employee'].each do |name|
      role = Role.iid(name)
      role.destroy unless role.nil?
    end
  end

end