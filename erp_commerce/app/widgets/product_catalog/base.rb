module Widgets
  module ProductCatalog
    class Base < ErpApp::Widgets::Base      
      def index
        render
      end
      
      def back_to_catalog
        render :update => {:id => "#{@uuid}_result", :view => 'index'}
      end

      def show
        @product_type = ProductType.find(params[:id])
        render :update => {:id => "#{@uuid}_result", :view => 'show'}
      end  

      def add_to_cart
        @product_type   = ProductType.find(params[:id])
        @cart_items_url = params[:cart_items_url]
        ErpCommerce::OrderHelper.new(self).add_to_cart(@product_type)
    
        render :update => {:id => "#{@uuid}_result", :view => 'add_to_cart'}
      end
  
      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end
  
      class << self
        def title
          "Product Catalog"
        end

        def views_location
          File.join(File.dirname(__FILE__),"/views")
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

