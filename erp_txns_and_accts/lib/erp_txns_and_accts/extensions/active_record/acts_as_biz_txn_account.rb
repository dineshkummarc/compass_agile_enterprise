module ErpTxnsAndAccts
	module Extensions
		module ActiveRecord
			module ActsAsBizTxnAccount
			
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_biz_txn_account
            extend ActsAsBizTxnAccount::SingletonMethods
            include ActsAsBizTxnAccount::InstanceMethods

            after_initialize :initialize_biz_txn_account
            after_create :save_biz_txn_account
            after_update :save_biz_txn_account
            after_destroy :destroy_biz_txn_account

            has_one :biz_txn_acct_root, :as => :biz_txn_acct

            [
              :biz_txn_acct_type,
              :biz_txn_events,
              :biz_txn_acct_party_roles,
              :txn_events,
              :description,:description=,
              :txns,
              :account_type
            ].each do |m| delegate m, :to => :biz_txn_acct_root end

          end
        end

        module InstanceMethods
          def account_root
            biz_txn_acct_root
          end

          def initialize_biz_txn_account
            if (self.biz_txn_acct_root.nil?)
              t = BizTxnAcctRoot.new
              self.biz_txn_acct_root = t
              t.biz_txn_acct = self
            end
          end

          def save_biz_txn_account
            self.biz_txn_acct_root.save
          end

          def destroy_biz_txn_account
					  self.biz_txn_acct_root.destroy if (self.biz_txn_acct_root && !self.biz_txn_acct_root.frozen?)
					end
        end
        
        module SingletonMethods
        end
        
      end#ActsAsBizTxnAccount
    end#ActiveRecord
  end#Extensions
end#ErpTxnsAndAccts