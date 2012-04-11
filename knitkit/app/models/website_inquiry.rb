class WebsiteInquiry < ActiveRecord::Base
  belongs_to :website
  belongs_to :user

  has_dynamic_forms
	has_dynamic_data

  def send_email(subject='')
    begin
      WebsiteInquiryMailer.inquiry(self, subject).deliver
    rescue Exception => e
      system_user = Party.find_by_description('Compass AE')
      AuditLog.custom_application_log_message(system_user, e)
    end
  end
end
