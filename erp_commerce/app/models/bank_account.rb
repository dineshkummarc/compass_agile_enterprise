class BankAccount < ActiveRecord::Base
  require 'attr_encrypted'

  acts_as_biz_txn_account

  belongs_to :bank_account_type

  validates :routing_number, :presence => {:message => 'Routing number cannot be blank.'}
  validates :name_on_account, :presence => {:message => 'Name on account cannot be blank.'}
  validates :crypted_private_account_number, :presence => {:message => 'Account number cannot be blank.'}

  alias :account_type :bank_account_type

  #the function EncryptionKey.get_key is meant to be overridden to provide a means for implementations to specify their
  #own encryption schemes and locations. It will default to a simple string for development and testing
  attr_encrypted :private_account_number, :key => Rails.application.config.erp_commerce.encryption_key, :marshall => true, :attribute => :crypted_private_account_number

  # These methods are exposed for the purposes of displaying a version of the account number
  # string containing the last four digits of the account number. The idea is to make it
  # painfully obvious when any coder is using the private_account_number, which should
  # be used only in limited circumstances.

  def account_number
    if self.private_account_number
      BankAccount.mask_number(self.private_account_number)
    else
      ''
    end
  end

  # Note that the setter method allows the same variable to be set, and delegates through
  # the encryption process

  def account_number=(num)
    self.private_account_number=num
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

  def purchase(financial_txn, gateway_wrapper, gateway_options={}, gateway_account_number=nil, gateway_routing_number=nil)
    gateway_account_number = self.private_account_number unless gateway_account_number
    gateway_routing_number = self.routing_number unless gateway_routing_number

    #call some service to pay via bank accounts
    result = gateway_wrapper.purchase(gateway_account_number, gateway_routing_number, financial_txn.money.amount)

    unless result[:payment].nil?
      result[:payment].financial_txn = financial_txn
      result[:payment].save
      financial_txn.payments << result[:payment]
      financial_txn.save
    end

    result
  end

  class << self
    
    def mask_number(number)
      total_chars = number.length
      total_chars -= 4
      result = ''
      result.tap do |str|
        total_chars.times do
          str << 'X'
        end
      end
      result + number[number.length-4..number.length]
    end

  end

end
