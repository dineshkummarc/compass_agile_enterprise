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
            #get configuration

            @message = nil

            #get subscription selection if it is there
            @subscription_selection = get_subscription_selection if params[:subscription_selection]

            #get convenience_fee if it is there
            @convenience_fee = get_convenience_fee if params[:convenience_fee]

            #get additional payments
            #@aditional_payments = get_additional_payments

            @billing_account_payment_amts = get_billing_account_amounts
            Rails.logger.debug("##### Billing Acct Payments: #{@billing_account_payment_amts}")
            @payment_account_root = BizTxnAcctRoot.find(params[:payment_account_id])
            @payment_account = @payment_account_root.account
            @payment_date = params[:payment_date]
            @total_payment = params[:total_payment]

            money = Money.create(
              :amount => @total_payment.to_f,
              :description => "Online Payment",
              :currency => Currency.usd
            )
            financial_txn = FinancialTxn.create(
              :apply_date => Date.strptime(@payment_date,"%m/%d/%Y"),
              :money => money
            )
            financial_txn.description = "Online Payment"
            financial_txn.account = @payment_account_root
            financial_txn.save

            @billing_account_payment_amts.each do |hash|
              amount = hash[:amount].to_f rescue 0
              if amount > 0
                comment = (params[:short_payment_comment] and hash[:short_payment]) ? params[:short_payment_comment] : nil
                PaymentApplication.create(
                  :financial_txn => financial_txn,
                  :payment_applied_to => hash[:billing_account],
                  :money => Money.create(:amount => hash[:amount].to_f),
                  :comment => comment
                )
              end
            end

            if financial_txn.apply_date == Date.today
              case @payment_account.class.to_s
              when "BankAccount"
                financial_txn.txn_type = BizTxnType.ach_sale
                financial_txn.save
                result = @payment_account.purchase(financial_txn, ErpCommerce::Config.active_merchant_gateway_wrapper)
                if !result[:payment].nil? and result[:payment].success
                  @authorization_code = result[:payment].authorization_code
                else
                  @message = result[:message]
                end
              when "CreditCardAccount"
                financial_txn.txn_type = BizTxnType.cc_sale
                financial_txn.save
                result = @payment_account.purchase(financial_txn, params[:cvv], ErpCommerce::Config.active_merchant_gateway_wrapper)
                if !result[:payment].nil? and result[:payment].success
                  @authorization_code = result[:payment].authorization_code
                else
                  @message = result[:message]
                end
              end
            end

            if @message.nil?
              render :json => {:success => true, :message => "Payment Successful!" }
            else 
              render :json => {:success => false, :message => @message }
            end
          end

          def payment_accounts
            party = Party.find(params[:party_id])

            results = party.accounts.map do |acct|
              if acct.biz_txn_acct_type == "CreditCardAccount" || acct.biz_txn_acct_type == 'BankAccount'
                { :id => acct.id,
                  :description => acct.description,
                  :account_type => acct.biz_txn_acct_type
                }
              end
            end

            results.reject!{|x| x.nil?}

            render :json => results
          end

          def generate_statement

          end
          def get_billing_account_amounts
            billing_account_payment_amts = []
            billing_account = BillingAccount.find(params["billing_account_id"])
            amount = params[:total_payment]
            billing_account_payment_amts << {:billing_account => billing_account, :amount => amount, :short_payment => (amount.to_f < billing_account.balance)}

            billing_account_payment_amts
          end

        end
      end#BillPay
    end#Organizer
  end#ErpApp
end#ErpInvoicing



