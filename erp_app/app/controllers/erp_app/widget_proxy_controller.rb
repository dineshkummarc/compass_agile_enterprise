module ErpApp
	class WidgetProxyController < ErpApp::ApplicationController
	  attr_accessor :performed_redirect

	  def index
		  @widget_name   = params[:widget_name]
  		@widget_action = params[:widget_action]
  		@uuid          = params[:uuid]

  		#get widget params
  		widget_params = nil
  		widget_params = JSON.parse(params[:widget_params]) unless params[:widget_params].blank?

  		widget_obj = "::Widgets::#{@widget_name.camelize}::Base".constantize.new(self, @widget_name, @widget_action, @uuid, widget_params)
		
  		@action_results = widget_obj.send(@widget_action)
		
		  respond_to do |format|
		    format.html do
		      render :inline => @action_results, :layout => false
		    end
		    format.js
		  end
		end

	  def user
		current_user
	  end

	  def authenticated?
		authorized?
	  end
	  
	end
end
