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

  ##
  #Get payment accounts in a more useful format for 
  #displaying in CSR, website, etc.
  def payment_accounts_hash
    cc_results = credit_card_accounts.map do |cca|
      { id: cca.id,
        description: cca.credit_card.description,
        card_type: cca.credit_card.card_type,
        last_four: nil, #not stored yet
        exp_dt: "#{cca.credit_card.expiration_month}-#{cca.credit_card.expiration_year}",
        account_type: 'Credit Card'}
    end

    ba_results = bank_accounts.map do |ba|
      {id: ba.id,
       description: ba.name_on_account,
       routing_number: ba.routing_number,
       account_type: 'Bank Account'}
    end

    (ba_results | cc_results).flatten
  end
end
