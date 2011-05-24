class ErpApp::WidgetProxyController < ErpApp::ApplicationController
  attr_accessor :performed_redirect

  def index
    @widget_name   = params[:widget_name]
    @widget_action = params[:widget_action]

    widget_klass = "ErpApp::Widgets::#{@widget_name.camelize}::Base".constantize.new(self, @widget_name, @widget_action)
    
    action_results = widget_klass.send(@widget_action)
    
    respond_to do |format|
      format.html do
        render :inline => action_results, :layout => false
      end
      format.js do
        render :update do |page|          
          page.replace_html 'result', :inline => action_results, :layout => false
        end
      end
    end

  end

  def user
    current_user
  end

  def authenticated?
    authorized?
  end
   
end
