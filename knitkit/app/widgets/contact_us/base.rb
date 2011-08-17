module Widgets
    module ContactUs
      class Base < ErpApp::Widgets::Base
        def index
          @use_dynamic_form = params[:use_dynamic_form]

          render
        end

        def new
          @website = Website.find_by_host(request.host_with_port)
          @website_inquiry = WebsiteInquiry.new
          @website_inquiry.website_id = @website.id
          @website_inquiry.data.created_with_form_id = params[:dynamic_form_id] if params[:is_html_form].blank?
    
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

        #should not be modified
        #modify at your own risk
        self.view_paths = File.join(File.dirname(__FILE__),"/views")
        
        def locate
          File.dirname(__FILE__)
        end
        
        class << self
          def title
            "Contact Us"
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
