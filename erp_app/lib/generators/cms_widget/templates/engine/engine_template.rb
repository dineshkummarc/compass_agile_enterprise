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
          "<%= description %>"
        end
    
        def widget_name
          File.basename(File.dirname(__FILE__))
        end
      end
    end#Base
  end#<%= class_name %>
end#Widgets
