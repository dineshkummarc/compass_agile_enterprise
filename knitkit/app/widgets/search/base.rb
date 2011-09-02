  module Widgets
    module Search
      class Base < ErpApp::Widgets::Base
        include ActionDispatch::Routing::UrlFor
        include Rails.application.routes.url_helpers
        include WillPaginate::ActionView
         
        def set_variables
          @results_permalink = params[:results_permalink]
          @section_permalink = params[:section_permalink]
          @content_type = params[:content_type]
          @per_page = params[:per_page]
          @css_class = params[:class]
        
          if @results_permalink.nil? or @results_permalink.blank?
            @ajax_results = true
          else
            @ajax_results = false
          end
        end

        def index
          set_variables
          render
        end

        def new
          set_variables
          @website = Website.find_by_host(request.host_with_port)

          options = {
            :website_id => @website.id,
            :query => params[:query],
            :content_type => params[:content_type],
            :section_permalink => params[:section_permalink],
            :page => (params[:page] || 1),
            :per_page => (params[:per_page] || 20)
          }
          @results = Content.do_search(options)

          render :view => :show
        end

        #should not be modified
        #modify at your own risk
        self.view_paths = File.join(File.dirname(__FILE__),"/views")
        
        def locate
          File.dirname(__FILE__)
        end
        
        class << self
          def title
            "Search"
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

