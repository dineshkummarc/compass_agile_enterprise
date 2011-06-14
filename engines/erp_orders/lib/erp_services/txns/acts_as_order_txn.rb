module ErpServices::Txns
	module ActsAsOrderTxn

		def self.included(base)
        	base.extend(ClassMethods)
    end

		module ClassMethods

  		def acts_as_order_txn

        has_one :order_txn, :as => :order_txn_record

        #from OrderTxn
        [ :bill_to_address,:bill_to_address=,
          :bill_to_city,:bill_to_city=,
          :bill_to_country,:bill_to_country=,
          :bill_to_country_name,:bill_to_country_name=,
          :bill_to_first_name,:bill_to_first_name=,
          :bill_to_last_name,:bill_to_last_name=,
          :bill_to_postal_code,:bill_to_postal_code=,
          :bill_to_state,:bill_to_state=,
          :Company,:Company=,
          :credit_card_id,:credit_card_id=,
          :customer_ip,:customer_ip=,
          :email,:email=,
          :error_message,:error_message=,
          :Fax,:Fax=,
          :description,:description=,
          :order_number,:order_number=,
          :order_txn_type_id,:order_txn_type_id=,
          :payment_gateway_txn_id,:payment_gateway_txn_id=,
          :Phone2,:Phone2=,
          :phone_number,:phone_number=,
          :Salutation,:Salutation=,
          :ship_to_address,:ship_to_address=,
          :ship_to_city,:ship_to_city=,
          :ship_to_country,:ship_to_country=,
          :ship_to_country_name,:ship_to_country_name=,
          :ship_to_first_name,:ship_to_first_name=,
          :ship_to_last_name,:ship_to_last_name=,
          :ship_to_postal_code,:ship_to_postal_code=,
          :ship_to_state,:ship_to_state=,
          :state_machine,:state_machine=,
          :status,:status=,
          :add_line_item,
          :line_items,
          :order_line_items,
          :determine_txn_party_roles,
          :determine_charge_elements,
          :determine_charge_accounts,
          :process,
          :set_shipping_info,
          :set_billing_info,
          :authorize_payments,
          :capture_payments,
          :rollback_authorizations,
          :submit
        ].each { |m| delegate m, :to => :order_txn }

         #from OrderTxn And BizTxnEvent
         [:biz_txn,
          :biz_txn_event,
          :root_txn,
          :find_party_by_role,
          :txn_type,:txn_type=,
          :txn_type_iid,:txn_type_iid=,:create_dependent_txns,
          :account,:account=].each { |m| delegate m, :to => :order_txn }

        extend ErpServices::Txns::ActsAsOrderTxn::SingletonMethods
			  include ErpServices::Txns::ActsAsOrderTxn::InstanceMethods

		  end

	  end


		module SingletonMethods
		end

		module InstanceMethods
      def order
        self.order_txn
      end

      # called after object initilized (either via .new or after loaded from the DB)
      def after_initialize()
        #puts "after_initialize: #{self.class.name} #{self.id}"
        if self.new_record? && self.order_txn == nil
          #puts "after_initialize: making new OrderTxn"
          self.order_txn = OrderTxn.new
        end
      end

      # Is called after Base.save on existing objects that have a record.
      def after_update
        #puts "after_update: #{self.class.name} #{self.id}"
        #puts "saving the order #{self.order_txn.id}"
				#there is lot of bad data that prevents us from falidating the email address
      	#self.order_txn.save_with_validation!
      	self.order_txn.save
      end

      # Is called after Base.destroy (and all the attributes have been frozen).
      def after_destroy
        if self.order && !self.order.frozen?
          self.order.destroy
        end
      end

		end


	end
end

ActiveRecord::Base.send(:include, ErpServices::Txns::ActsAsOrderTxn)
