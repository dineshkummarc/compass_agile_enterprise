require 'spec_helper'

describe Widget do
  before(:all) do
    CapabilityType.create(:internal_identifier => 'test_type', :description => 'Test Type')
    Widget.create(:internal_identifier => "test_widget")
  end

  it "can add capabilities" do
    widget = Widget.find_by_internal_identifier('test_widget')
    admin_user = User.create(:username => 'admin_test', :email => 'admin@gmail.com')
    admin_user.add_role('admin')

    widget.add_capability(:test_type, 'Note', 'admin')
    admin_user.has_capability?(widget, :test_type, 'Note').should eq true
  end

  it "should limit access by capabilites" do
    widget = Widget.find_by_internal_identifier('test_widget')
    employee_user = User.create(:username => 'employee_test', :email => 'employee@gmail.com')
    admin_user = User.create(:username => 'admin_test', :email => 'admin@gmail.com')
    admin_user.add_role('admin')

    widget.add_capability(:test_type, 'Note', 'admin')

    admin_user.has_capability?(widget, :test_type, 'Note').should eq true
    employee_user.has_capability?(widget, 'test_type', 'Note').should eq false
  end

  it "can remove capabilities" do
    widget = Widget.find_by_internal_identifier('test_widget')
    admin_user = User.create(:username => 'admin_test', :email => 'admin@gmail.com')
    admin_user.add_role('admin')
    
    widget.add_capability(:test_type, 'Note', 'admin')

    admin_user.has_capability?(widget, :test_type, 'Note').should eq true
    widget.remove_capability('test_type', 'Note')
    lambda { admin_user.has_capability?(widget, :test_type, 'Note') }.should raise_error ErpTechSvcs::Utils::CompassAccessNegotiator::Errors::CapabilityDoesNotExist, "Capability does not exist."
  end

  after(:all) do
    Widget.destroy_all("internal_identifier = 'test_widget'")
    User.destroy_all("username = 'admin_test'")
    User.destroy_all("username = 'employee_test'")
    CapabilityType.destroy_all("internal_identifier = 'test_type'")
  end
end