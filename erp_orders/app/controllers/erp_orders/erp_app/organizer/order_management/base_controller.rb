module ErpOrders
  module ErpApp
    module Organizer
      module OrderManagement
        class BaseController < ::ErpApp::Organizer::BaseController
  
          def menu
            menu = []

            menu << {:text => 'Orders', :leaf => true, :iconCls => 'icon-package', :applicationCardId => "orders_layout"}

            render :inline => menu.to_json
          end
          
        end#BaseController
      end#OrderManagement      
    end#Organizer         
  end#ErpApp
end#ErpOrders