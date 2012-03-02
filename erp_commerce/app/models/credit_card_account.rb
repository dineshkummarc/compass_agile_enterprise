class CreditCardAccount < ActiveRecord::Base
  acts_as_biz_txn_account
  
  belongs_to :credit_card_account_purpose
  has_one    :credit_card_account_party_role, :dependent => :destroy
  has_one    :credit_card, :through => :credit_card_account_party_role

  def account_number
    self.credit_card.card_number
  end

  def financial_txns
    self.biz_txn_events.where('biz_txn_record_type = ?', 'FinancialTxn').collect(&:biz_txn_record)
  end

  def successful_payments
    payments = []
    self.financial_txns.each do |financial_txn|
      payments << financial_txn.payments.last if financial_txn.has_captured_payment?
    end
    payments
  end
  #financial_txn, params[:cvvs], credit_card, ErpCommerce::ActiveMerchantWrappers::BrainTreeGatewayWrapper, {}

  #params
  #financial_txn
  #payment_date
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def schedule_payment(financial_txn, payment_date, cvv, gateway_wrapper,  gateway_options={},credit_card_to_use=nil)
    result[:payment] = Payment.new
    result[:payment].success = true
    result[:payment].save
    financial_txn.payments << result[:payment]
    financial_txn.save
    
    result
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def authorize(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use
    
    gateway_options[:debug] = true
    result = gateway_wrapper.authorize(credit_card_to_use, financial_txn.money.amount, cvv, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def purchase(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use
    
    gateway_options[:debug] = true
    result = gateway_wrapper.purchase(credit_card_to_use, financial_txn.money.amount, cvv, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def capture(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use

    result = {:success => true}
    payment = Payment.find(:first, :order => 'created_at desc', :conditions => ["current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, financial_txn.id])
    #only capture this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      gateway_options[:debug] = true
      result = gateway_wrapper.capture(credit_card_to_use, payment, cvv,gateway_options)
    end
    result
  end
  
  #params
  #financial_txn
  #cvv
  #gateway_wrapper
  #
  #Optional
  #gateway_options
  #credit_card_to_use
  def reverse_authorization(financial_txn, cvv, gateway_wrapper, gateway_options={}, credit_card_to_use=nil)
    credit_card_to_use = self.credit_card unless credit_card_to_use

    result = {:success => true}
    payment = Payment.find(:first, :order => 'created_at desc', :conditions => ["current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, financial_txn.id])
    #only reverse this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      gateway_options[:debug] = true

      result = gateway_wrapper.full_reverse_of_authorization(credit_card_to_use, payment, cvv, gateway_options)
    end
    result
  end
end
