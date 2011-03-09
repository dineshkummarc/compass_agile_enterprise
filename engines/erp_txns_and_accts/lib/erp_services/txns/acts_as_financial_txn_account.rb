module ErpServices::Txns
	module ActsAsFinancialTxnAccount
		
		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_financial_txn_account
    								
			  has_one :financial_txn_account, :as => :financial_account
			  
			  [
			    :biz_txn_acct_type,
			    :biz_txn_events,
			    :biz_txn_acct_party_roles,
			    :txn_events,
			    :txns,
			    :biz_txn_acct_root,:biz_txn_acct_root=,
			    :account_type,
			    :agreement,:agreement=,
			    :balance,:balance=,
			    :account_number,:account_number=,
			    :due_date,:due_date=,
			    :created_at,:updated_at,
			    :payment_due,:payment_due=,
			    :description,:description=,
          :account_delinquent?,:financial_txns,
          :authorize_payment_txn,:finalize_payment_txn,:rollback_last_txn,
			    :financial_txns,:financial_txns=
			  ].each do |m| delegate m, :to => :financial_txn_account end
			  
			  extend ErpServices::Txns::ActsAsBizTxnAccount::SingletonMethods
			  include ErpServices::Txns::ActsAsBizTxnAccount::InstanceMethods												
							     			
		  end

		end
		
		module InstanceMethods
		  def after_update
      	self.financial_txn_account.save
      end  

      def after_initialize()
        if (self.financial_txn_account.nil?)
          f = FinancialTxnAccount.new
          self.financial_txn_account = f
          f.financial_account = self
        end
      end
        
      def after_create
        self.financial_txn_account.save
      end
		
		end
		
		module SingletonMethods
		end
		
	end
end

ActiveRecord::Base.send(:include, ErpServices::Txns::ActsAsFinancialTxnAccount)