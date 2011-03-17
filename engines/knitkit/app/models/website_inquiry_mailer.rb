class WebsiteInquiryMailer < ActionMailer::Base

  def inquiry(website_inquiry)
    @recipients  = website_inquiry.website.email
    @from        = website_inquiry.website.email
    @sent_on     = Time.now
    @subject     = "#{website_inquiry.website.title} Inquiry"
    @body        = {
                    :website_inquiry => website_inquiry
                   }
  end
end