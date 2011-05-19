class ErpApp::Widgets::<%= class_name %>::Base < ErpApp::Widgets::Base
  def index
    render
  end

  <% unless in_erp_app? %>
  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
  <% end %>
end
