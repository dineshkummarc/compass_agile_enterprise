class WebsiteInquiryMailer < ActionMailer::Base

  def inquiry(website_inquiry)
    @website_inquiry = website_inquiry
    mail( :to => website_inquiry.website.email,
          :from => website_inquiry.data.dyn_email,
          :subject => "#{website_inquiry.website.title} Inquiry",
          :content_type => 'text/plain'
         )
  end
end

