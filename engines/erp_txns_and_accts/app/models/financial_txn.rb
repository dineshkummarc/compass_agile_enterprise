class FinancialTxn < ActiveRecord::Base

  acts_as_biz_txn_event
  has_many   :charge_line_payment_txns, :as => :payment_txn,  :dependent => :destroy
  has_many   :charge_lines, :through => :charge_line_payment_txns
  has_many   :payments
  belongs_to :money, :class_name => 'MoneyAmount'
  	
  	
  def authorize_payment(credit_card, gateway, gateway_options={})
    credit_card[:charge_amount] = self.money.amount
    gateway_options[:charge_lines] = self.charge_lines
    gateway_options[:credit_card] = credit_card
    gateway_options[:debug] = true

    payment = gateway.authorize(gateway_options)

    self.payments << payment
    self.save
  end
  
  def finalize_payment(credit_card, gateway, gateway_options={})
    result = {:success => true}
    payment = Payment.find(:first, :order => 'created_at desc', :conditions => ["current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, self.id])
    #only capture this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      credit_card[:charge_amount] = self.money.amount
      gateway_options[:charge_lines] = self.charge_lines
      gateway_options[:payment] = payment
      gateway_options[:credit_card] = credit_card
      gateway_options[:debug] = true

      result = gateway.capture(gateway_options)
    end
    result
  end

  def reverse_authorization(credit_card, gateway, gateway_options={})
    result = {:success => true}
    payment = Payment.find(:first, :order => 'created_at desc', :conditions => ["current_state = ? and success = ? and financial_txn_id = ?",'authorized', 1, self.id])
    #only reverse this payment if it was authorized
    if !payment.nil? && payment.current_state.to_sym == :authorized
      credit_card[:charge_amount] = self.money.amount
      gateway_options[:charge_lines] = self.charge_lines
      gateway_options[:payment] = payment
      gateway_options[:credit_card] = credit_card
      gateway_options[:debug] = true

      result = gateway.full_reverse_of_authorization(gateway_options)
    end
    result
  end

end
