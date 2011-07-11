module ErpServices::Txns
	module ActsAsBizTxnEvent

		def self.included(base)
      base.extend(ClassMethods)  	        	      	
    end

		module ClassMethods

  		def acts_as_biz_txn_event
        
  			has_one :biz_txn_event, :as => :biz_txn_record
		  	belongs_to :biz_txn_acct_root	

        #from BizTxnEvent
         [:txn_type,:txn_type=,
          :txn_type_iid,:txn_type_iid=,
          :description,:description=,
          :post_date,:post_date=,
          :created_at,:created_at=,
          :updated_at,:updated_at=,
          :create_dependent_txns,:account].each { |m| delegate m, :to => :biz_txn_event }

			  extend ErpServices::Txns::ActsAsBizTxnEvent::SingletonMethods
			  include ErpServices::Txns::ActsAsBizTxnEvent::InstanceMethods												
											     			
		  end

		end
  		
		module SingletonMethods
						
		end
				
		module InstanceMethods
			def root_txn
				self.biz_txn_event
			end
	
			#allow for a client to pass either an account root or a polymorphic subclass of
			#account root, but always set the account to the root
	  	def account=(acct)
	  		if acct.instance_of?(BizTxnAcctRoot)
	  			self.biz_txn_event.biz_txn_acct_root = (acct)
  			else
  				self.biz_txn_event.biz_txn_acct_root = (acct.biz_txn_acct_root)
  			end
	  	end

      def after_update
      	self.biz_txn_event.save
      end  

      def after_initialize()
        if (self.biz_txn_event.nil?)
          t = BizTxnEvent.new
          self.biz_txn_event = t
          t.biz_txn_record = self
        end
      end
        
      def after_create
      
        if (self.biz_txn_event.nil?)
          t = BizTxnEvent.new
          t.biz_txn_record = self

          t.save
          self.save
        end
        
      end
    	
		end

	end
  		
end

ActiveRecord::Base.send(:include, ErpServices::Txns::ActsAsBizTxnEvent)