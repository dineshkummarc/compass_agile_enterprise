module Widgets
  module <%= class_name %>
    class Base < ErpApp::Widgets::Base
  
      def index
        render :view => :index
      end
  
      #should not be modified
      #modify at your own risk
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
    end#Base
  end#<%= class_name %>
end#Widgets
