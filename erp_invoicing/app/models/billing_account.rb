class BillingAccount < ActiveRecord::Base
  has_relational_dynamic_attributes
  acts_as_financial_txn_account
  

  has_many :invoices, :dependent => :destroy do
    def by_invoice_date
      order('invoice_date desc')
    end

    def balance
      all.sum(&:balance)
    end
  end
  has_many :payment_applications, :as => :payment_applied_to, :dependent => :destroy do
    def successful
      all.select{|item| item.financial_txn.has_captured_payment?}
    end
    def pending
      all.select{|item| item.is_pending?}
    end
  end
  has_one  :recurring_payment, :dependent => :destroy

  def has_recurring_payment_enabled?
    !self.recurring_payment.nil? and self.recurring_payment.enabled
  end

  def has_payments?(status)
    selected_payment_applications = self.get_payment_applications(status)
    !(selected_payment_applications.nil? or selected_payment_applications.empty?) 
  end

  def get_payment_applications(status=:all)
    selected_payment_applications = case status.to_sym
    when :pending
      self.payment_applications.pending
    when :successful
      self.payment_applications.successful
    when :all
      self.payment_applications
    end

    unless self.invoices.empty?
      selected_payment_applications = (selected_payment_applications | self.invoices.collect{|item| item.get_payment_applications(status)}).flatten! unless (self.invoices.collect{|item| item.get_payment_applications(status)}.empty?)
    end

    selected_payment_applications
  end

  def has_outstanding_balance?
    (outstanding_balance > 0)
  end

  def outstanding_balance
    (balance - total_pending_payments)
  end

  def total_pending_payments
    self.payment_applications.pending.sum{|item| item.money.amount}
  end

  def total_payments
    self.payment_applications.successful.sum{|item| item.money.amount}
  end

  #payment due is determined by last invoice
  def payment_due
    if self.calculate_balance and !self.invoices.empty?
      self.invoices.by_invoice_date.last.payment_due
    else
      self.financial_txn_account.payment_due.amount
    end
  end

  def payment_due=(amount, currency=Currency.usd)
    currency = Currency.usd
    if amount.is_a?(Array)
      currency = amount.last
      amount = amount.first
    end
    if self.financial_txn_account.payment_due
      self.financial_txn_account.payment_due.amount = amount
    else
      self.financial_txn_account.payment_due = Money.create(:amount => amount, :currency => currency)
    end
    self.financial_txn_account.payment_due.save
  end

  def billing_date
    unless self.invoices.empty?
      current_invoice.invoice_date
    else
      self.attributes['billing_date']
    end
  end

  #override due_date for invoice.invoice_date
  def due_date
    unless self.invoices.empty?
      current_invoice.due_date
    else
      self.financial_txn_account.due_date
    end
  end

  #override balance_date for today if calculate_balance is set to true
  def balance_date
    if self.calculate_balance
      Date.today
    else
      unless self.invoices.empty?
        current_invoice.invoice_date
      else
        self.financial_txn_account.balance_date
      end
    end
  end

  #override balance to use invoices is calculate_balance is set to true
  def balance
    if self.calculate_balance
      self.invoices.balance
    else
      (self.financial_txn_account.balance.amount - self.total_payments)
    end
  end

  def balance=(amount, currency=Currency.usd)
    if amount.is_a?(Array)
      currency = amount.last
      amount = amount.first
    end
    if self.financial_txn_account.balance
      self.financial_txn_account.balance.amount = amount
    else
      self.financial_txn_account.balance = Money.create(:amount => amount, :currency => currency)
    end
    self.financial_txn_account.balance.save
  end

  def current_invoice
    self.invoices.by_invoice_date.last
  end

  def send_sms_notification
    primary_party = self.find_parties_by_role('primary').first
    from_party = Party.find_by_description('Compass AE')
    from_number = from_party.default_phone_number
    to_number = primary_party.billing_phone_number

    # prevent multiple sms notifications being sent within the time window
    previous_cmm_evt = CommunicationEvent.find_by_sql("SELECT * FROM communication_events
                                    JOIN phone_numbers from_phone ON from_contact_mechanism_id=from_phone.id
                                    JOIN phone_numbers to_phone ON to_contact_mechanism_id=to_phone.id
                                    WHERE from_contact_mechanism_type = 'PhoneNumber' 
                                    AND from_contact_mechanism_type='PhoneNumber'
                                    AND from_phone.phone_number = '#{from_number.phone_number.to_s}'
                                    AND (to_phone.phone_number = '#{to_number.phone_number.to_s}' OR to_phone.phone_number = '#{to_number.phone_number[1..to_number.phone_number.length]}')
                                    AND communication_events.created_at > '#{SMS_TIME_WINDOW.minutes.ago.to_s}'
                                    ORDER BY communication_events.created_at DESC").first

    Rails.logger.info 'not sending sms notification, one has already been sent within time window' if !previous_cmm_evt.nil?

    unless primary_party.billing_phone_number.nil? or !previous_cmm_evt.nil?
      message = SMS_NOTIFICATION_MESSAGE.gsub('payment_due',self.payment_due.to_s)
      

      # get cmm event purpose type
      sms_purpose = CommEvtPurposeType.find_by_internal_identifier('sms_notification')

      # create cmm event
      cmm_evt = CommunicationEvent.new
      cmm_evt.short_description = 'SMS Notification'
      cmm_evt.from_role = RoleType.find_by_internal_identifier('application')
      cmm_evt.from_party = from_party
      cmm_evt.from_contact_mechanism = from_number
      cmm_evt.comm_evt_purpose_types << sms_purpose
      cmm_evt.to_contact_mechanism = to_number
      cmm_evt.to_role = RoleType.find_by_internal_identifier('customer')
      cmm_evt.to_party = primary_party
      cmm_evt.case_id = self.id
      cmm_evt.notes = "From Number: #{from_number}, To Number: #{to_number}, Message: #{message}"

      clikatell = ErpTechSvcs::SmsWrapper::Clickatell.new
      cmm_evt.external_identifier = clikatell.send_message(to_number.phone_number, message, :mo => 1, :from => from_number.phone_number)

      unless cmm_evt.external_identifier.nil?
        cmm_evt.save
        return true
      else
        return false
      end
    end
  end

  def send_email_notification
    primary_party = self.find_parties_by_role('primary').first
    unless primary_party.billing_email_address.nil?
      #send email
    end
  end

end
