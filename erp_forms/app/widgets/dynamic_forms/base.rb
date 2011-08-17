class ErpApp::Widgets::DynamicForms::Base < ErpApp::Widgets::Base
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

  #should not be modified
  #modify at your own risk
  self.view_paths = File.join(File.dirname(__FILE__),"/views")
  
  def locate
    File.dirname(__FILE__)
  end
  
  class << self
    def title
      "Dynamic Forms"
    end
    
    def widget_name
      File.basename(File.dirname(__FILE__))
    end
    
    def base_layout
      begin
        file = File.join(File.dirname(__FILE__),"/views/layouts/base.html.erb")
        IO.read(file)
      rescue
        return nil
      end
    end
  end
  
end
