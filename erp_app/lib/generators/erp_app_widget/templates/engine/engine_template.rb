class ErpApp::Widgets::<%= class_name %>::Base < ErpApp::Widgets::Base

  def self.title
    "<%= class_name %>"
  end

  def index
    render
  end

  def self.name
    File.dirname(__FILE__).split('/')[-1]
  end

  <% unless in_erp_app? %>
  #if module lives outside of erp_app plugin this needs to be overriden
  #get location of this class that is being executed
  def locate
    File.dirname(__FILE__)
  end
  <% end %>
end
