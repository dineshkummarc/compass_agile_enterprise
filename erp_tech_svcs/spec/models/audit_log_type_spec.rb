require 'spec_helper'

describe AuditLogType do

  it "should allow you to find_by_type_and_subtype_iid" do
    AuditLogType.find_by_type_and_subtype_iid('application','custom_message').description.should eq "Custom Message"
  end

end