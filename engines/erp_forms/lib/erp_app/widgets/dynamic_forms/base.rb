class ErpApp::Widgets::DynamicForms::Base < ErpApp::Widgets::Base

  def self.title
    "Dynamic Forms"
  end

  def index
    render
  end

  def new
    @website = Website.find_by_host(request.host_with_port)

    DynamicFormDocument.declare(params[:model_name])
    @form_data = params[:model_name].constantize.new
    @form_data.data.created_with_form_id = params[:dynamic_form_id]
    
    params[:website_id] = @website.id
    params.each do |k,v|
      @form_data.data.send(DynamicDatum::DYNAMIC_ATTRIBUTE_PREFIX + k + '=', v) unless ErpApp::Widgets::Base::IGNORED_PARAMS.include?(k.to_s)
    end
    
    @form_data.data.created_by = current_user unless current_user.nil?
    
    if @form_data.valid?
      @form_data.save

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
