class ErpApp::Widgets::ContactUs::Base < ErpApp::Widgets::Base

  def self.title
    "Contact Us"
  end
  
  def index
    render
  end

  def new
    @website = Website.find_by_host(request.host_with_port)
    @website_inquiry = WebsiteInquiry.create(
      :email => params[:email],
      :first_name => params[:first_name],
      :last_name => params[:last_name],
      :inquiry => params[:inquiry]
    )
    if @website_inquiry.valid?
      @website_inquiry.website = @website
      @website_inquiry.user = self.controller.user unless self.controller.user.nil?
      @website_inquiry.save
      if @website.email_inquiries?
        @website_inquiry.send_email
      end
      render :view => :success
    else
      render :view => :error
    end
  end

  def self.name
    File.dirname(__FILE__).split('/')[-1]
  end

  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
end
