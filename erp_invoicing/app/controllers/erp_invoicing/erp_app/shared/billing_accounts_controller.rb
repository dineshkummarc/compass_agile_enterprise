module ErpInvoicing
  module ErpApp
    module Shared
      class BillingAccountsController < ::ErpApp::Desktop::BaseController
        @@date_format = "%m/%d/%Y"

        def index
          render :json => if request.put?
            update_billing_account
          elsif request.post?
            create_billing_account
          elsif request.get?
            get_billing_accounts
          elsif request.delete?
            delete_billing_account
          end
        end

        def get_billing_accounts
          result = {:success => true, :billing_accounts => [], :totalCount => 0}

          sort_hash      = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
          sort           = sort_hash[:sort] || 'created_at'
          dir            = sort_hash[:dir] || 'DESC'
          limit          = params[:limit] || 50
          start          = params[:start] || 0
          party_id       = params[:party_id] || nil

          billing_accounts = (party_id.blank? ? BillingAccount.scoped.includes(:financial_txn_account) : BillingAccount.scoped.includes(:financial_txn_account => {:biz_txn_acct_root => :biz_txn_acct_party_roles}))
          billing_accounts = billing_accounts.where(:financial_txn_accounts => {:account_number => params[:account_number]}) unless params[:account_number].blank?
          billing_accounts = billing_accounts.where(:financial_txn_accounts => {:biz_txn_acct_roots => {:biz_txn_acct_party_roles => {:party_id => party_id }}}) unless party_id.blank?
          billing_accounts = billing_accounts.order("financial_txn_accounts.#{sort} #{dir}").limit(limit).offset(start)
          result[:totalCount] = billing_accounts.count

          result.tap do |result_tap|
            result_tap[:billing_accounts] = billing_accounts.all.collect do |billing_account|
              billing_account.to_hash(:only => [], :methods => [:id,:send_paper_bills,:payable_online,:account_number,:calculate_balance,:payment_due,:balance,:balance_date,:due_date])
            end#end billing_accounts collect
            result_tap[:totalCount] = BillingAccount.count(:all)
          end#end result tap
        end

        def create_billing_account
          if params[:billingAccount]
            data = params[:billingAccount]
          else
            data = params
            data[:due_date] = Date.strptime(params[:due_date], @@date_format)
            data[:balance_date] = Date.strptime(params[:balance_date], @@date_format)
          end

          billing_account = BillingAccount.new
          billing_account.account_number = data[:account_number]
          billing_account.calculate_balance = data[:calculate_balance]
          billing_account.payment_due = data[:payment_due]
          billing_account.balance = data[:balance]
          billing_account.due_date = data[:due_date]
          billing_account.balance_date = data[:balance_date]
          billing_account.payable_online = data[:payable_online]
          billing_account.send_paper_bills = data[:send_paper_bills]

          if params[:party_id]
            party = Party.find(params[:party_id])
            primary_role_type = BizTxnAcctPtyRtype.find_by_internal_identifier('primary')
            billing_account.add_party_with_role(party, primary_role_type)
          end

          if billing_account.save
            {:success => true, :billing_accounts => billing_account.to_hash(:only => [], :methods => [:id,:send_paper_bills,:payable_online,:account_number,:calculate_balance,:payment_due,:balance,:balance_date,:due_date])}
          else
            {:success => false}
          end
        end

        def update_billing_account
          if params[:billingAccount]
            data = params[:billingAccount]
          else
            data = params
            data[:due_date] = Date.strptime(params[:due_date], @@date_format)
            data[:balance_date] = Date.strptime(params[:balance_date], @@date_format)
          end

          billing_account = BillingAccount.find(data[:id])
            
          billing_account.account_number = data[:account_number]
          billing_account.calculate_balance = data[:calculate_balance]
          billing_account.due_date = data[:due_date]
          billing_account.balance_date = data[:balance_date]
          billing_account.payable_online = data[:payable_online]
          billing_account.send_paper_bills = data[:send_paper_bills]
          billing_account.payment_due = data[:payment_due]
          billing_account.balance = data[:balance]

          if billing_account.save
            {:success => true, :billing_accounts => billing_account.to_hash(:only => [], :methods => [:id,:send_paper_bills,:payable_online,:account_number,:calculate_balance,:payment_due,:balance,:balance_date,:due_date])}
          else
            {:success => false}
          end
        end

        def delete_billing_account
          BillingAccount.find(params[:id]).destroy

          {:success => true}
        end

      end#BillingAccountsController
    end#Shared
  end#ErpApp
end#ErpInvoicing