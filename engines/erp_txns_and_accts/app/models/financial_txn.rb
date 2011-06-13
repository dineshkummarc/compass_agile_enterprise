class FinancialTxn < ActiveRecord::Base

  acts_as_biz_txn_event
  has_many   :charge_line_payment_txns, :as => :payment_txn,  :dependent => :destroy
  has_many   :charge_lines, :through => :charge_line_payment_txns
  belongs_to :money, :class_name => "ErpBaseErpSvcs::Money"
  	
  def authorize(credit_card, gateway_wrapper, gateway_options={})
    credit_card[:charge_amount] = self.money.amount
    gateway_options[:debug] = true

    result = gateway_wrapper.authorize(credit_card, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = self
      result[:payment].save
      self.payments << result[:payment]
      self.save
    end

    result
  end

  def purchase(credit_card, gateway_wrapper, gateway_options={})
    credit_card[:charge_amount] = self.money.amount
    gateway_options[:debug] = true

    result = gateway_wrapper.purchase(credit_card, gateway_options)

    unless result[:payment].nil?
      result[:payment].financial_txn = self
      result[:payment].save
      self.payments << result[:payment]
      self.save
    end

    result
  end
  
  def capture(credit_card, gateway_wrapper, gateway_options={})
    result = {:success => true}
    payment = Payment.find(:first, :order => 'created_at desc', :conditions => ["current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, self.id])
    #only capture this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      credit_card[:charge_amount] = self.money.amount
      gateway_options[:debug] = true

      result = gateway_wrapper.capture(credit_card, payment, gateway_options)
    end
    result
  end

  def reverse_authorization(credit_card, gateway_wrapper, gateway_options={})
    result = {:success => true}
    payment = Payment.find(:first, :order => 'created_at desc', :conditions => ["current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, self.id])
    #only reverse this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      credit_card[:charge_amount] = self.money.amount
      gateway_options[:debug] = true

      result = gateway_wrapper.full_reverse_of_authorization(credit_card, payment, gateway_options)
    end
    result
  end

end
