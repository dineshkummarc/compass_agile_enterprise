class FinancialTxnAccount < ActiveRecord::Base
  acts_as_biz_txn_account

  scope :accounts_for_agreements, lambda { |agreement_ids| where("agreement_id in (?)", agreement_ids).order('due_date ASC')}
  scope :due, includes([:balance]).where("money.amount != 0")

  belongs_to :agreement
  belongs_to :balance, :dependent => :destroy
  belongs_to :payment_due, :dependent => :destroy
  belongs_to :financial_account, :polymorphic => true, :dependent => :destroy
  
  def financial_txns(result_set, options={})
    txns = nil

    options.merge!({:conditions => "biz_txn_record_type = 'FinancialTxn'"})
    
    if(result_set == :all)
      txns = self.biz_txn_events.find(:all, options).collect{|biz_txn_event| biz_txn_event.biz_txn_record}
    else
      txns = self.biz_txn_events.find(:first, options).biz_txn_record
    end
    
    txns
  end

  def account_delinquent?
    past_due = false
    
    if self.due_date.nil?
      past_due = false
    elsif self.payment_due.nil? || self.payment_due.amount == 0
      past_due = false
    else
      past_due = self.due_date.past?
    end

    past_due
  end
  
  def authorize_payment_txn(credit_card_info, gateway)
    due_amount = self.payment_due.amount

    financial_txn = FinancialTxn.create(:money => ErpBaseErpSvcs::Money.create(:amount => due_amount))

    financial_txn.account = self
    financial_txn.description = "Payment on account #{self.account_number} of #{due_amount}"

    financial_txn.txn_type = BizTxnType.iid('payment_txn')
    financial_txn.save

    financial_txn.authorize_payment(credit_card_info, gateway)
  end
  
  def finalize_payment_txn(credit_card_info, gateway)
    financial_txn = self.biz_txn_events.where("biz_txn_record_type = 'FinancialTxn'").order('biz_txn_events.created_at desc').first
    result = financial_txn.finalize_payment(credit_card_info, gateway)

    if result[:success]
      self.payment_due.amount = 0
      self.payment_due.save
    end

    result
  end
  
  def rollback_last_txn(credit_card_info, gateway)
    financial_txn = self.biz_txn_events.where("biz_txn_record_type = 'FinancialTxn'").order('biz_txn_events.created_at desc').first
    financial_txn.reverse_authorization(credit_card_info, gateway)
  end

end
