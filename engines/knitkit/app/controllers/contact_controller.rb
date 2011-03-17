class ContactController < BaseController
  def show
    @user = current_user
    @website_inquiry = WebsiteInquiry.new
  end
  
  def new
    ignored_params = %w{action controller}

    options = params
    options.delete_if{|k,v| ignored_params.include?(k.to_s)}
    options = options[:website_inquiry]

    @website_inquiry = WebsiteInquiry.create(options)
    if @website_inquiry.valid?
      @website_inquiry.website = @website
      @website_inquiry.user = current_user unless current_user.nil?
      @website_inquiry.save
      if @website.email_inquiries?
        @website_inquiry.send_email
      end
      @success = true
    end
  end

  #no section to set
  def set_section
    return false
  end
end
