class BizTxnEvent < ActiveRecord::Base

	belongs_to :biz_txn_acct_root
	belongs_to :biz_txn_record, :polymorphic => true 
  has_many :biz_txn_party_roles, :dependent => :destroy 
  has_many :biz_txn_event_descs, :dependent => :destroy
  has_many :base_txn_contexts, :dependent => :destroy
  has_many :biz_txn_agreement_roles
  has_many :agreements, :through => :biz_txn_agreement_roles
  	
  #wrapper for...
  #belongs_to :biz_txn_type
  belongs_to_erp_type :biz_txn_type
	#syntactic sugar
	alias :txn_type :biz_txn_type
	alias :txn_type= :biz_txn_type=
	alias :txn :biz_txn_record
	alias :txn= :biz_txn_record=
	alias :account :biz_txn_acct_root
	alias :account= :biz_txn_acct_root=
	alias :descriptions :biz_txn_event_descs


	#helps when looping through transactions comparing types
	def txn_type_iid
		biz_txn_type.internal_identifier if biz_txn_type
	end
 
	def account_root
		biz_txn_acct_root
	end
	
	def amount
  	if biz_txn_record.respond_to? :amount
  		biz_txn_record.amount
  	else
  		nil
  	end   		
	end 
  	
	def amount_string
		if biz_txn_record.respond_to? :amount_string
			biz_txn_record.amount_string
		else
			"n/a"
		end 
	end
	
	def create_dependent_txns
	  #Template Method
	end

	def to_label
    "#{description}"
	end

	def to_s
    "#{description}"
	end

end
