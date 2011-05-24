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

  def page
    offset = params[:start].to_f
    
    if offset > 0
      return (offset / params[:limit].to_f).to_i + 1
    else 
      return 1
    end
  end
  
  def per_page
    if !params[:limit].nil?
      return params[:limit].to_i
    else
      return 20
    end
  end
   
end
