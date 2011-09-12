class ErpApp::Desktop::OrderManager::BaseController < ErpApp::Desktop::BaseController

  class Helper
    include Singleton
    include ActionView::Helpers::NumberHelper
  end

  def help
    Helper.instance
  end

  def index
    buyer_role = BizTxnPartyRoleType.find_by_internal_identifier('buyer')
    result = {:success => true, :orders => [], :totalCount => 0, :results => 0}
    
    sort_hash     = params[:sort].blank? ? {} : Hash.symbolize_keys(JSON.parse(params[:sort]).first)
    sort         = sort_hash[:sort] || 'created_at'
    dir          = sort_hash[:dir] || 'DESC'
    limit        = params[:limit] || 50
    start        = params[:start] || 0
    party_id     = params[:party_id]
    order_id     = params[:order_id]
    order_number = params[:order_number]

    if order_id.blank? and party_id.blank? and order_number.blank?
      orders = OrderTxn.order("#{sort} #{dir}").limit(limit).offset(start)
      result[:totalCount] = OrderTxn.all.count
    elsif !order_number.blank?
      orders = OrderTxn.find_by_order_number(order_number).nil? ? [] : [OrderTxn.find_by_order_number(order_number)]
      result[:totalCount] = orders.count
    elsif !order_id.blank?
      orders = [OrderTxn.find(order_id)]
      result[:totalCount] = orders.count
    elsif !party_id.blank?
      sort = "order_txns.#{sort}"
      orders = OrderTxn.joins("join biz_txn_events bte on bte.biz_txn_record_id = order_txns.id and bte.biz_txn_record_type = 'OrderTxn'
                   join biz_txn_party_roles btpr on btpr.biz_txn_event_id = bte.id and btpr.party_id = #{party_id} and biz_txn_party_role_type_id = #{buyer_role.id}").order("#{sort} #{dir}").limit(limit).offset(start)
      result[:totalCount] = OrderTxn.joins("join biz_txn_events bte on bte.biz_txn_record_id = order_txns.id and bte.biz_txn_record_type = 'OrderTxn'
                   join biz_txn_party_roles btpr on btpr.biz_txn_event_id = bte.id and btpr.party_id = #{party_id} and biz_txn_party_role_type_id = #{buyer_role.id}").count
    end

    result[:results] = orders.count

    orders.each do |order|

      #get payor party if it exists
      buyer_party_id = nil
      unless order.root_txn.biz_txn_party_roles.empty?
        buyer_party_id = order.root_txn.biz_txn_party_roles.where('biz_txn_party_role_type_id = ?', buyer_role.id).first.party.id
      end

      result[:orders] << {
        :total_price => help.number_to_currency(order.get_total_charges.sum{|money| money.amount}),
        :order_number => order.order_number,
        :status => order.status,
        :first_name => order.bill_to_first_name,
        :last_name => order.bill_to_last_name,
        :email => order.email,
        :phone => order.phone_number,
        :id => order.id,
        :created_at => order.created_at,
        :buyer_party_id => buyer_party_id
      }
    end

    render :json => result
  end

  def delete
    result = {}

    if OrderTxn.find(params[:id]).destroy
      result[:success] = true
    else
      result[:success] = false
    end

    render :json => result
  end

  def line_items
    result = {:success => true, :lineItems => [], :totalCount => 0, :results => 0}

    limit    = params[:limit] || 10
    start    = params[:start] || 0

    line_items = OrderLineItem.where('order_txn_id = ?',params[:order_id]).limit(limit).offset(start)

    result[:results] = line_items.count
    result[:totalCount] = OrderLineItem.count("order_txn_id = #{params[:order_id]}",)

    line_items.each do |line_item|
      price = 0
      currency_display = nil
      line_item.get_total_charges.each do |money|
        price += money.amount
        currency_display = money.currency.internal_identifier
      end
      
      result[:lineItems] << {
        :id => line_item.id,
        :product => line_item.product_type.description,
        :quantity => 1,
        :price => price,
        :currency_display => currency_display,
        :sku => line_item.product_type.inventory_entries.first.sku
      }
    end

    render :json => result
  end

  def payments
    result = {:success => true, :payments => []}

    financial_txns = OrderTxn.find(params[:order_id]).line_items.first.charge_lines.first.financial_txns
    
    financial_txns.each do |financial_txn|
      amount = financial_txn.money.amount
      currency_display = financial_txn.money.currency.internal_identifier

      financial_txn.payments.each do |payment|
        result[:payments] << {
          :id => payment.id,
          :authorization => payment.authorization_code,
          :status => payment.current_state,
          :created_at => payment.created_at,
          :amount => amount,
          :success => payment.success ? 'Yes' : 'No',
          :currency_display => currency_display
        }
      end
      
    end

    render :json => result
  end

end