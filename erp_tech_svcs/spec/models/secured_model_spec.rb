require 'spec_helper'

describe SecuredModel do

  it "can find models by Class and role" do
    admin_role = Role.create(:description => 'Admin', :internal_identifier => 'admin')
    admin_user = User.create(:username => "admin",:email => "admin@portablemind.com")
    admin_user.add_role('admin')

    admin_user.has_role?('admin').should eq true

    model = SecuredModel.find_models_by_klass_and_role(User, 'admin').first
    model.username.should eq 'admin'

    model = SecuredModel.find_models_by_klass_and_role('User', admin_role).first
    model.username.should eq 'admin'

    admin_user.destroy
    admin_role.destroy
  end

end