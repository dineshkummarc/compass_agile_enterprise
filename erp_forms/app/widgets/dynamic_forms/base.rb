module Widgets
  module DynamicForms
    class Base < ErpApp::Widgets::Base
       def index
	     render
	   end

	  def new
		@website = Website.find_by_host(request.host_with_port)

		@myDynamicObject = DynamicFormModel.get_instance(params[:model_name])
		
		params[:created_by] = current_user unless current_user.nil?
		params[:created_with_form_id] = params[:dynamic_form_id] if params[:dynamic_form_id] and params[:is_html_form].blank?
		params[:website_id] = @website.id
		@myDynamicObject = DynamicFormModel.save_all_attributes(@myDynamicObject, params, ErpApp::Widgets::Base::IGNORED_PARAMS)
			
		if @myDynamicObject
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
  end
end
