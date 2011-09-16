module Widgets
  module ProductCatalog
    class Base < ErpApp::Widgets::Base
      def index
        render
      end

      def show
        @product_type = ProductType.find(params[:id])
        render
      end

      def add_to_cart
        @product_type   = ProductType.find(params[:id])
        @cart_items_url = params[:cart_items_url]
        ErpApp::Widget::ShoppingCart::Helpers::Order.new(self).add_to_cart(@product_type)
    
        render
      end
  
      #should not be modified
      #modify at your own risk
      self.view_paths = File.join(File.dirname(__FILE__),"/views")
  
      def locate
        File.dirname(__FILE__)
      end
  
      class << self
        def title
          "Product Catalog"
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
  end#ProductCatalog
end#Widgets

