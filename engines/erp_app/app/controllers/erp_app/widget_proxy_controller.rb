class ErpApp::WidgetProxyController < ErpApp::ApplicationController
  attr_accessor :performed_redirect

  def index
    @widget_name   = params[:widget_name]
    @widget_action = params[:widget_action]

    widget_klass = "ErpApp::Widgets::#{@widget_name.camelize}::Base".constantize.new(self, @widget_name, @widget_action)
    
    action_results = widget_klass.send(@widget_action)
    render :inline => action_results, :layout => false

  end

  def user
    current_user
  end

  def authenticated?
    authorized?
  end
 
end
