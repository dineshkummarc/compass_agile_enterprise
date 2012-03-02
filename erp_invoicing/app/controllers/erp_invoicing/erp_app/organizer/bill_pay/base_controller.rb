module ErpInvoicing
  module ErpApp
    module Organizer
      module BillPay
        class BaseController < ::ErpApp::Organizer::BaseController

          def menu
            menu = []

            menu << {:text => 'Bill Pay', :leaf => true, :iconCls => 'icon-creditcards', :applicationCardId => "billpay-application"}

            render :json => menu
          end

        end
      end#BillPay
    end#Organizer
  end#ErpApp
end#ErpInvoicing

  

