class WebsiteInquiry < ActiveRecord::Base
  belongs_to :website
  belongs_to :user

  def send_email
    WebsiteInquiryMailer.deliver_inquiry(self)
  end
end
