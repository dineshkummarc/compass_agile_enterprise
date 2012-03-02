Party.class_eval do

  #credit cards
	has_many :credit_card_account_party_roles, :dependent => :destroy
  
  # return primary credit card
  def primary_credit_card
    return get_credit_card('primary')
  end

  # return credit card by credit card account purpose using internal identifier
  def get_credit_card(internal_identifier)
    self.credit_card_account_party_roles.each do |ccapr|
      if ccapr.credit_card_account.credit_card_account_purpose.internal_identifier.eql?(internal_identifier)
        return ccapr.credit_card
      end
    end 
    return nil  
  end

  def credit_card_accounts
     self.accounts.where('biz_txn_acct_type = ?', 'CreditCardAccount').all.collect(&:account)
  end

  def bank_accounts
     self.accounts.where('biz_txn_acct_type = ?', 'BankAccount').all.collect(&:account)
  end

  def payment_accounts
    (bank_accounts | credit_card_accounts).flatten
  end
  
end