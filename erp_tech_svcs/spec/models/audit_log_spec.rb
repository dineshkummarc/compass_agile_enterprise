require 'spec_helper'

describe AuditLog do
  before(:all) do
    @party = Factory(:party)
  end
  
  it "should allow you to create custom application log message" do
    custom_test_message = 'Custom Message'
    AuditLog.custom_application_log_message(@party, custom_test_message)
    audit_log = AuditLog.find_by_audit_log_type_id(AuditLogType.find_by_type_and_subtype_iid('application','custom_message').id)
    audit_log.description.should eq "#{@party.description}: #{custom_test_message}"
  end

  it "should allow you to log party login" do
    AuditLog.party_login(@party)
    audit_log = AuditLog.find_by_audit_log_type_id(AuditLogType.find_by_type_and_subtype_iid('application','successful_login').id)
    audit_log.description.should eq "#{@party.description} has logged in"
  end

  it "should allow you to log party logout" do
    AuditLog.party_logout(@party)
    audit_log = AuditLog.find_by_audit_log_type_id(AuditLogType.find_by_type_and_subtype_iid('application','successful_logout').id)
    audit_log.description.should eq "#{@party.description} has logged out"
  end

  it "should allow you to log when a party accesses an area" do
    url = 'www.test.com/home'
    AuditLog.party_access(@party, url)
    audit_log = AuditLog.find_by_audit_log_type_id(AuditLogType.find_by_type_and_subtype_iid('application','accessed_area').id)
    audit_log.description.should eq "#{@party.description} has accessed area #{url}"
  end

  it "should allow you to log when a party fails access" do
    url = 'www.test.com/access'
    AuditLog.party_failed_access(@party, url)
    audit_log = AuditLog.find_by_audit_log_type_id(AuditLogType.find_by_type_and_subtype_iid('application','accessed_area').id)
    audit_log.description.should eq "#{@party.description} has tried to access a restricted area #{url}"
  end

  it "should allow you to log on session timeout" do
    AuditLog.party_session_timeout(@party)
    audit_log = AuditLog.find_by_audit_log_type_id(AuditLogType.find_by_type_and_subtype_iid('application','session_timeout').id)
    audit_log.description.should eq "#{@party.description} session has expired"
  end

  
end