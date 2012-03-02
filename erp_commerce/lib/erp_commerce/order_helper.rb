module ErpCommerce
  class OrderHelper
    attr_accessor :widget
    delegate :params, :session, :request, :logger, :current_user, :to => :widget

    def initialize(widget)
      self.widget = widget
    end

    def get_order(create=nil)
      order = nil
      unless session['order_txn_id'].nil?
        order = OrderTxn.where('id = ?',session['order_txn_id']).first
        order = create_order if order.nil?
      else
        order = create_order if create
      end
      order
    end

    #add a product type to cart
    def add_to_cart(product_type)
      order = get_order(true)
  
      #see if we need to update quantity or create new line item
      order_line_item = get_line_item_for_product_type(product_type)
      if order_line_item.nil? || order_line_item.empty?
        #create order line item
        order_line_item = order.add_line_item(product_type)

        #get pricing plan and create charge lines
        pricing_plan = product_type.get_current_simple_plan
        money = Money.create(
          :description => pricing_plan.description,
          :amount => pricing_plan.money_amount,
          :currency => pricing_plan.currency)

        charge_line = ChargeLine.create(
          :charged_item => order_line_item,
          :money => money,
          :description => pricing_plan.description)
        charge_line.save
        order_line_item.charge_lines << charge_line
        order.status = 'Items Added'
        order.save
      else
        #update quantity
      end
      order
    end

    #set billing information
    def set_demographic_info(params)
      order = get_order

      #if biz txn party roles have not been setup set them up
      if order.root_txn.biz_txn_party_roles.nil? || order.root_txn.biz_txn_party_roles.empty?
        setup_biz_txn_party_roles(order)
      end

       party = self.current_user.party

      #set billing information on party
      #get geo codes
      geo_country = GeoCountry.find_by_iso_code_2(params[:bill_to_country])
      geo_zone = GeoZone.find_by_zone_code(params[:bill_to_state])
      party.update_or_add_contact_with_purpose(PostalAddress, ContactPurpose.billing,
        {
          :address_line_1 => params[:bill_to_address_line_1],
          :address_line_2 => params[:bill_to_address_line_2],
          :city => params[:bill_to_city],
          :state => geo_zone.zone_name,
          :zip => params[:bill_to_postal_code],
          :country => geo_country.name
        })
      billing_postal_address = party.find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.billing)
      billing_postal_address.geo_country = geo_country
      billing_postal_address.geo_zone = geo_zone
      billing_postal_address.save

      #set shipping information on party
      #same as billing us billing info
      if params[:ship_to_billing] == 'on'
        #get geo codes
        geo_country = GeoCountry.find_by_iso_code_2(params[:bill_to_country])
        geo_zone = GeoZone.find_by_zone_code(params[:bill_to_state])
        party.update_or_add_contact_with_purpose(PostalAddress, ContactPurpose.shipping,
          {
            :address_line_1 => params[:bill_to_address_line_1],
            :address_line_2 => params[:bill_to_address_line_2],
            :city => params[:bill_to_city],
            :state => geo_zone.zone_name,
            :zip => params[:bill_to_postal_code],
            :country => geo_country.name
          })
        shipping_postal_address = party.find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.shipping)
        shipping_postal_address.geo_country = geo_country
        shipping_postal_address.geo_zone = geo_zone
        shipping_postal_address.save
      else
        #get geo codes
        geo_country = GeoCountry.find_by_iso_code_2(params[:ship_to_country])
        geo_zone = GeoZone.find_by_zone_code(params[:ship_to_state])
        party.update_or_add_contact_with_purpose(PostalAddress, ContactPurpose.shipping,
          {
            :address_line_1 => params[:ship_to_address_line_1],
            :address_line_2 => params[:ship_to_address_line_2],
            :city => params[:ship_to_city],
            :state => geo_zone.zone_name,
            :zip => params[:ship_to_postal_code],
            :country => geo_country.name
          })
        shipping_postal_address = party.find_contact_mechanism_with_purpose(PostalAddress, ContactPurpose.shipping)
        shipping_postal_address.geo_country = geo_country
        shipping_postal_address.geo_zone = geo_zone
        shipping_postal_address.save
      end

      #set phone and email
      party.update_or_add_contact_with_purpose(PhoneNumber, ContactPurpose.billing, {:phone_number => params[:bill_to_phone]})
      party.update_or_add_contact_with_purpose(EmailAddress, ContactPurpose.billing, {:email_address => params[:bill_to_email]})

      #set billing and shipping info on order
      order.set_shipping_info(party)
      order.set_billing_info(party)

      #update status
      order.status = 'Demographics Gathered'
      order.save

      order
    end

    #complete the order
    def complete_order(params, charge_credit_card=true)
      success = true
      message = nil
      order = get_order

      if charge_credit_card
        #make credit financial txns and payment txns
        #create financial txn for order
        financial_txn = create_financial_txns(order)
        
        credit_card = CreditCard.new(
          :first_name_on_card => params[:first_name],
          :last_name_on_card => params[:last_name],
          :expiration_month => params[:exp_month],
          :expiration_year => params[:exp_year]
        )
        credit_card.card_number = params[:card_number]
        result = CreditCardAccount.new.purchase(financial_txn, params[:cvvs], ErpCommerce::ActiveMerchantWrappers::BrainTreeGatewayWrapper, {}, credit_card)

        #make sure cedit card payment was successful
        if result[:payment].nil? or !result[:payment].success
          success = false
          message = result[:message]
          order.status = 'Credit Card Failed'
        end
      end

      if success
        order.status = 'Pending Shipment'
        #update inventory counts
        #should be moved to model somewhere
        order.order_line_items.each do |oli|
          inventory_entry = oli.product_type.inventory_entries.first
          inventory_entry.number_available -= 1
          inventory_entry.number_sold += 1
          inventory_entry.save
        end
        #clear order from session
        clear_order
      end

      order.save
      return success, message, order, result[:payment]
    end

    #remove line item
    def remove_from_cart(order_line_item_id)
      order = get_order

      order.line_items.find(order_line_item_id).destroy

      order
    end

    private

    def get_line_item_for_product_type(product_type)
      order = get_order(true)
      order.line_items.select{|oli| oli.product_type == product_type.id}
    end

    def clear_order
      session['order_txn_id'] = nil
    end

    def create_order
      order = OrderTxn.create
      order.status = 'Initialized'
      order.order_number = (Time.now.to_i / (rand(100)+2)).round
      order.save
      session['order_txn_id'] = order.id
      setup_biz_txn_party_roles(order) unless self.current_user.nil?
      order
    end

    #sets up payor party role
    def setup_biz_txn_party_roles(order)
      payor_role = BizTxnPartyRoleType.find_by_internal_identifier('payor')
      biz_txn_event = order.root_txn
      tpr = BizTxnPartyRole.new
      tpr.biz_txn_event = biz_txn_event
      tpr.party = self.current_user.party
      tpr.biz_txn_party_role_type = payor_role
      tpr.save
    end

    #create financial_txn for charge lines
    def create_financial_txns(order)
      #total up all order line items charge lines
      total_payment = 0
      currency = nil
      order.get_total_charges.each do |money|
        total_payment += money.amount
        currency = money.currency
      end

      financial_txn = FinancialTxn.create(:money => Money.create(:description => 'Order Payment', :amount => total_payment, :currency => currency))
      financial_txn.description = 'Order Payment'
      financial_txn.txn_type = BizTxnType.iid('payment_txn')
      financial_txn.save

      order.get_all_charge_lines.each do |charge_line|
        charge_line.add_payment_txn(financial_txn)
        charge_line.save
      end

      financial_txn
    end

  end#ErpCommerce
end#OrderHelper
