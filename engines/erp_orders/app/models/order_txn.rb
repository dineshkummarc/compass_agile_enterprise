class OrderTxn < ActiveRecord::Base
  acts_as_biz_txn_event

	belongs_to :order_txn_record, :polymorphic => true, :dependent => :destroy
  has_many   :order_line_items, :dependent => :destroy
  has_many   :charge_lines, :as => :charged_item

	alias :line_items :order_line_items

  # validation
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :update, :allow_nil => true

  # get the total charges for an order.
  # The total will be returned as Money.
  # There may be multiple Monies assocated with an order, such as points and
  # dollars. To handle this, the method should return an array of Monies
  #
  def get_total_charges
    all_charges = []

    # get all of the charge lines associated with the order and order_lines
    total_hash = Hash.new
    all_charges.concat(charge_lines)
    order_line_items.each do |line_item|
      all_charges.concat(line_item.charge_lines)
    end
    # loop through all of the charges and combine charges for each money type
    all_charges.each do |charge|
      cur_money = charge.money_amount
      cur_total = total_hash[cur_money.currency.internal_identifier]
      if (cur_total.nil?)
        cur_total = cur_money.clone
      else
        cur_total.amount = 0 if cur_total.amount.nil?
        cur_total.amount += cur_money.amount if !cur_money.amount.nil?
      end
      total_hash[cur_money.currency.internal_identifier] = cur_total
    end
    return total_hash.values
  end

  def submit
    #Template Method
  end

  def add_line_item(object, reln_type = nil, to_role = nil, from_role = nil)
    class_name = object.class.name
    if object.is_a?(Array)
	    class_name = object.first.class.name
	  else
	    class_name = object.class.name
	  end

	  case class_name
    when 'ProductType'
      return add_product_type_line_item(object, reln_type, to_role, from_role)
    when 'ProductInstance'
      return add_product_instance_line_item(object, reln_type, to_role, from_role)
	  end
  end


	def add_product_type_line_item(product_type, reln_type = nil, to_role = nil, from_role = nil)

    li = OrderLineItem.new

    if(product_type.is_a?(Array))
      if (product_type.size == 0)
        return
      elsif (product_type.size == 1)
        product_type_for_line_item = product_type[0]
      else # more than 1 in the array, so it's a package
        product_type_for_line_item = ProductType.new
        product_type_for_line_item.description = to_role.description

        product_type.each do |product|
          # make a product-type-reln
          reln = ProdTypeReln.new
          reln.prod_type_reln_type = reln_type
          reln.role_type_id_from = from_role.id
          reln.role_type_id_to = to_role.id

          #associate package on the "to" side of reln
          reln.prod_type_to = product_type_for_line_item

          #assocation product_type on the "from" side of the reln
          reln.prod_type_from = product
          reln.save
        end
      end
    else
      product_type_for_line_item = product_type
    end

    li.product_type = product_type_for_line_item
    self.line_items << li
    li.save
    return li
	end

  def add_product_instance_line_item(product_instance, reln_type = nil, to_role = nil, from_role = nil)

    li = OrderLineItem.new

    if(product_instance.is_a?(Array))
      if (product_instance.size == 0)
        return
      elsif (product_instance.size == 1)
        product_instance_for_line_item = product_instance[0]
      else # more than 1 in the array, so it's a package
        product_instance_for_line_item = ProductInstance.new
        product_instance_for_line_item.description = to_role.description
        product_instance_for_line_item.save

        product_instance.each do |product|
          # make a product-type-reln
          reln = ProdInstanceReln.new
          reln.prod_instance_reln_type = reln_type
          reln.role_type_id_from = from_role.id
          reln.role_type_id_to = to_role.id

          #associate package on the "to" side of reln
          reln.prod_instance_to = product_instance_for_line_item

          #assocation product_instance on the "from" side of the reln
          reln.prod_instance_from = product
          reln.save
        end
      end
    else
      product_instance_for_line_item = product_instance
    end

    li.product_instance = product_instance_for_line_item
    self.line_items << li
    li.save
    return li
  end

  def find_party_by_role(role_type_iid)
    party = nil

    tpr = self.root_txn.biz_txn_party_roles.find(:first, :include => :biz_txn_party_role_type, :conditions => ['biz_txn_party_role_types.internal_identifier = ?',role_type_iid])
    party = tpr.party unless tpr.nil?

    party
  end

  def set_shipping_info(party)
    self.ship_to_first_name = arty.business_party.current_first_name
    self.ship_to_last_name = arty.business_party.current_last_name
    shipping_address = party.shipping_address || party.primary_address
    unless shipping_address.nil?
      self.ship_to_address = shipping_address.address_line_1
      self.ship_to_city = shipping_address.city
      self.ship_to_state = shipping_address.state
      self.ship_to_postal_code = shipping_address.zip
      self.ship_to_country_name = shipping_address.country_name
      self.ship_to_country = shipping_address.country
    end
  end

  def set_billing_info(party)
    self.email = party.primary_email_address.email_address unless party.primary_email_address.nil?
    self.phone_number = party.primary_phone_number.phone_number unless party.primary_phone_number.nil?

    self.bill_to_first_name = party.business_party.current_first_name
    self.bill_to_last_name = party.business_party.current_last_name
    billing_address = party.billing_address || party.primary_address
    unless billing_address.nil?
      self.bill_to_address = billing_address.address_line_1
      self.bill_to_city = billing_address.city
      self.bill_to_state = billing_address.state
      self.bill_to_postal_code = billing_address.zip
      #self.bill_to_country_name = billing_address.country_name
      #self.bill_to_country = billing_address.country
    end
  end

  def determine_txn_party_roles
    #Template Method
  end

  def determine_charge_elements
    #Template Method
  end

  def determine_charge_accounts
    #Template Method
  end

  ###############################################################################
  #BizTxnEvent Overrides
  ###############################################################################
  def create_dependent_txns
	  #Template Method
	end

  ################################################################
  ################################################################
  # Payment methods
  # these methods are used to capture payments on orders
  ################################################################
  ################################################################

  def authorize_payments(financial_txns, credit_card, gateway, gateway_options={}, use_delayed_jobs=true)
    all_txns_authorized = true
    authorized_txns = []
    gateway_message = nil

    #check if we are using delayed jobs or not
    unless use_delayed_jobs
      financial_txns.each do |financial_txn|
        financial_txn.authorize_payment(credit_card, gateway, gateway_options)
        if financial_txn.payments.empty?
          all_txns_authorized = false
          gateway_message = 'Unknown Protobase Error'
          break
        elsif !financial_txn.payments.first.success
          all_txns_authorized = false
          gateway_message = financial_txn.payments.first.payment_gateways.first.response
          break
        else
          authorized_txns << financial_txn
        end
      end
    else
      financial_txns.each do |financial_txn|
        #push into delayed job so we can fire off more payments if needed
        ErpTxnsAndAccts::DelayedJobs::PaymentGatewayJob.start(financial_txn, gateway, :authorize_payment, gateway_options, credit_card)
      end
      #wait till all payments are complete
      #wait a max of 120 seconds 2 minutes
      wait_counter = 0
      while !all_payment_jobs_completed?(financial_txns, :authorized)
        break if wait_counter == 40
        sleep 3
        wait_counter += 1
      end

      result, gateway_message, authorized_txns = all_payment_jobs_successful?(financial_txns)

      unless result
        all_txns_authorized = false
      end
    end
    return all_txns_authorized, authorized_txns, gateway_message
  end

  def capture_payments(authorized_txns, credit_card, gateway, gateway_options={}, use_delayed_jobs=true)
    all_txns_captured = true
    gateway_message = nil

    #check if we are using delayed jobs or not
    unless use_delayed_jobs
      authorized_txns.each do |financial_txn|
        result = financial_txn.finalize_payment(credit_card, gateway, gateway_options)
        unless(result[:success])
          all_txns_captured = false
          gateway_message   = result[:gateway_message]
          break
        end
      end
    else
      authorized_txns.each do |financial_txn|
        #push into delayed job so we can fire off more payments if needed
        ErpTxnsAndAccts::DelayedJobs::PaymentGatewayJob.start(financial_txn, gateway, :finalize_payment, gateway_options, credit_card)
      end

      #wait till all payments are complete
      #wait a max of 120 seconds 2 minutes
      wait_counter = 0
      while !all_payment_jobs_completed?(authorized_txns, :captured)
        break if wait_counter == 40
        sleep 3
        wait_counter += 1
      end

      result, gateway_message, authorized_txns = all_payment_jobs_successful?(authorized_txns)

      unless result
        all_txns_captured = false
      end
    end

    return all_txns_captured, gateway_message
  end

  def rollback_authorizations(authorized_txns, credit_card, gateway, gateway_options={}, use_delayed_jobs=true)
    all_txns_rolledback = true

    #check if we are using delayed jobs or not
    unless use_delayed_jobs
      authorized_txns.each do |financial_txn|
        result = financial_txn.reverse_authorization(credit_card, gateway, gateway_options)
        unless(result[:success])
          all_txns_rolledback = false
        end
      end
    else
      authorized_txns.each do |financial_txn|
        #push into delayed job so we can fire off more payments if needed
        ErpTxnsAndAccts::DelayedJobs::PaymentGatewayJob.start(financial_txn, gateway, :reverse_authorization, gateway_options, credit_card)
      end

      #wait till all payments are complete
      #wait a max of 120 seconds 2 minutes
      wait_counter = 0
      while !all_payment_jobs_completed?(authorized_txns, :authorization_reversed)
        break if wait_counter == 40
        sleep 3
        wait_counter += 1
      end

      result, gateway_message, authorized_txns = all_payment_jobs_successful?(authorized_txns)

      unless result
        all_txns_rolledback = false
      end
    end

    all_txns_rolledback
  end

  def all_payment_jobs_completed?(financial_txns, state)
    result = true

    #check the financial txns as they come back
    financial_txns.each do |financial_txn|
      payments = financial_txn.payments(true)
      if payments.empty? || payments.first.current_state.to_sym != state
        result = false
        break
      end
    end

    result
  end

  def all_payment_jobs_successful?(financial_txns)
    result = true
    message = nil
    authorized_txns = []

    #check the financial txns to see all were successful, if not get message
    financial_txns.each do |financial_txn|
      payments = financial_txn.payments(true)
      if payments.empty? || !payments.first.success
        result = false
        unless payments.empty?
          message = financial_txn.payments.first.payment_gateways.first.response
        else
          message = "Unknown Protobase Error"
        end
      else
        authorized_txns << financial_txn
      end
    end

    return result, message, authorized_txns
  end

end
