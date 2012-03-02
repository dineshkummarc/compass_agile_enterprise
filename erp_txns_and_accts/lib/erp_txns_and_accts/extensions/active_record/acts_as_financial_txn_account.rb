module ErpTxnsAndAccts
	module Extensions
		module ActiveRecord
			module ActsAsFinancialTxnAccount

        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def acts_as_financial_txn_account
            extend ActsAsFinancialTxnAccount::SingletonMethods
            include ActsAsFinancialTxnAccount::InstanceMethods

            after_initialize :initialize_financial_txn_account
            after_create :save_financial_txn_account
            after_update :save_financial_txn_account
            after_destroy :destroy_financial_txn_account

            has_one :financial_txn_account, :as => :financial_account

            [
              :biz_txn_acct_type,
              :biz_txn_events,
              :biz_txn_acct_party_roles,
              :txn_events,:txns,
              :biz_txn_acct_root,:biz_txn_acct_root=,
              :account_type,
              :agreement,:agreement=,
              :balance,:balance=,
              :account_number,:account_number=,
              :calculate_balance,:calculate_balance=,
              :balance_date,:balance_date=,
              :due_date,:due_date=,
              :account_root,
              :external_id_source,:external_id_source=,
              :external_identifier,:external_identifier=,
              :add_party_with_role,:find_parties_by_role,
              :created_at,:updated_at,
              :payment_due,:payment_due=,
              :description,:description=,
              :account_delinquent?,:financial_txns,
              :authorize_payment_txn,:finalize_payment_txn,:rollback_last_txn,
              :financial_txns,:financial_txns=
            ].each do |m| delegate m, :to => :financial_txn_account end
          end
        end

        module InstanceMethods

          def initialize_financial_txn_account
            if (self.financial_txn_account.nil?)
              f = FinancialTxnAccount.new
              self.financial_txn_account = f
              f.financial_account = self
            end
          end

          def save_financial_txn_account
            self.financial_txn_account.save
          end

          def destroy_financial_txn_account
					  self.financial_txn_account.destroy if (self.financial_txn_account && !self.financial_txn_account.frozen?)
					end

        end

        module SingletonMethods
        end

      end
    end
  end
end