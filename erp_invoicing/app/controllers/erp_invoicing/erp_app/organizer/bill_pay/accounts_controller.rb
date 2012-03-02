module ErpInvoicing
  module ErpApp
    module Organizer
      module BillPay
        class AccountsController < ::ErpApp::Organizer::BaseController

          class Helper
            include Singleton
            include ActionView::Helpers::NumberHelper
          end

          def help
            Helper.instance
          end

          def index
            accounts = {:totalCount => 1, :accounts => [{
                  :id => 1,
                  :account_number => '123455667',
                  :payment_due => help.number_to_currency(33.45),
                  :billing_date => '10/31/2011',
                  :due_date => '11/15/2011',
                  :account_id => 1,
                  :party_id => 1
                }]}

            render :json => accounts
          end

          def transactions
            transactions = {:totalCount => 2, :transactions => [
                {
                  :date => '10/10/2011',
                  :description => 'Monthly Billing Amount',
                  :amount => help.number_to_currency(50.00)
                },
                {
                  :date => '10/15/2011',
                  :description => 'Payment Recieved',
                  :amount => help.number_to_currency(-50.00)
                }
              ]}

            render :json => transactions
          end

          def make_payment_on_account
            
            render :json => {:success => true}            
          end

          def payment_accounts
            #billing_account = BillingAccount.find(params[:billing_account_id])
            

            payment_accounts = {:payment_accounts => [
                {
                  :id => 1,
                  :description => 'My Bank Account',
                  :account_type => 'Bank Account',
                  :routing_number => '0123456',
                  :account_number => '9999321',
                  :edit_action => :edit_back_account
                },
                {
                  :id => 2,
                  :description => 'American Express',
                  :account_type => 'Credit Card',
                  :card_number => '1111222233334444',
                  :security_code => '123',
                  :exp_year => '9',
                  :exp_month => '2012',
                  :name_on_card => 'John Doe',
                  :edit_action => :edit_credit_card_account
                }
              ]}

            render :json => payment_accounts
          end

          def generate_statement
            
          end

        end
      end#BillPay
    end#Organizer
  end#ErpApp
end#ErpInvoicing

  

