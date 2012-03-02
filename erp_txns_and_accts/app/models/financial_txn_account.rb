class FinancialTxnAccount < ActiveRecord::Base
  acts_as_biz_txn_account

  scope :accounts_for_agreements, lambda { |agreement_ids| where("agreement_id in (?)", agreement_ids).order('due_date ASC')}
  scope :due, includes([:balance]).where("money.amount != 0")

  belongs_to :agreement
  belongs_to :balance, :class_name => "Money", :foreign_key => 'balance_id', :dependent => :destroy
  belongs_to :payment_due, :class_name => "Money", :foreign_key => 'payment_due_id', :dependent => :destroy
  belongs_to :financial_account, :polymorphic => true
  
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
  
  def calculate_balance?
    self.calculate_balance
  end

end
