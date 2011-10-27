module ErpApp
	class WidgetProxyController < ErpApp::ApplicationController
	  before_filter :set_website
    attr_accessor :performed_redirect

	  def index
		  @widget_name   = params[:widget_name]
  		@widget_action = params[:widget_action]
  		@uuid          = params[:uuid]

  		#get widget params
  		widget_params = nil
  		widget_params = JSON.parse(params[:widget_params]) unless params[:widget_params].blank?

  		widget_obj = "::Widgets::#{@widget_name.camelize}::Base".constantize.new(self, @widget_name, @widget_action, @uuid, widget_params)

  		render widget_obj.send(@widget_action)
		end

    protected
    def set_website
      @website = Website.find_by_host(request.host_with_port)
    end

    def current_themes
      @website.themes.active if @website
    end

    def current_theme_paths
      current_themes ? current_themes.map { |theme| {:path => theme.path.to_s, :url => theme.url.to_s}} : []
    end
	  
	end
end
