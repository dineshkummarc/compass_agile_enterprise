class ErpApp::Widgets::ContactUs::Base < ErpApp::Widgets::Base

  def self.title
    "Contact Us"
  end
  
  def index
    render
  end

  def new
    @website = Website.find_by_host(request.host_with_port)

    @website_inquiry = WebsiteInquiry.new
    @website_inquiry.data.created_with_form_id = params[:dynamic_form_id]
    @website_inquiry.website_id = @website.id

    params.each do |k,v|
      @website_inquiry.data.send(DynamicDatum::DYNAMIC_ATTRIBUTE_PREFIX + k + '=', v) unless ErpApp::Widgets::Base::IGNORED_PARAMS.include?(k.to_s)
    end
    
    @website_inquiry.data.created_by = current_user unless current_user.nil?
    
    if @website_inquiry.valid?
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
