require 'spec_helper'

describe User do

  before(:all) do
    @user = Factory(:user)
  end

  it "should allow you to add and remove roles" do
    role = Role.create(:internal_identifier => 'employee')
    @user.add_role(role)
    @user.has_role?(role).should eq true
    @user.remove_role(role)
    @user.has_role?(role).should eq false
  end

  it "should allow you to add instance attributes" do
    @user.add_instance_attribute(:test, 'result')
    @user.instance_attributes[:test].should eq 'result'
  end

  after(:all) do
    User.destroy_all
    Role.destroy_all
  end

end