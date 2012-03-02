module Widgets
  module Orders
    class Base < ErpApp::Widgets::Base
      def index
        @orders = OrderTxn.find_by_party_role('payor', current_user.party)
        @orders = @orders.select{|order| order.status != "Initialized"}
        render
      end

      #should not be modified
      #modify at your own risk
      def locate
        File.dirname(__FILE__)
      end

      class << self
        def title
          "Orders"
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
  end#Orders
end#Widgets