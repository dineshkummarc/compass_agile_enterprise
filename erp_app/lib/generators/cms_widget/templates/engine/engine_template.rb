class Widgets::<%= class_name %>::Base < ErpApp::Widgets::Base
  
  def index
    render :view => :index
  end
  
  #should not be modified
  #modify at your own risk
  self.view_paths = File.join(File.dirname(__FILE__),"/views")
  
  def locate
    File.dirname(__FILE__)
  end
  
  class << self
    def title
      "<%= class_name %>"
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
