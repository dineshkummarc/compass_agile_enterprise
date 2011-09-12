class CreditCard < ActiveRecord::Base
  
  require 'attr_encrypted'
  
  belongs_to  :postal_address
  has_many    :payments
  belongs_to  :credit_card_account_party_role

  #the function EncryptionKey.get_key is meant to be overridden to provide a means for implementations to specify their 
  #own encryption schemes and locations. It will default to a simple string for development and testing
  attr_encrypted :private_card_number, :key => EncryptionKey.get_key, :marshall => true, :attribute => :crypted_private_card_number

  # These methods are exposed for the purposes of displaying a version of the card number
  # string containing the last four digits of the card number. The idea is to make it
  # painfully obvious when any coder is using the private_card_number, which should
  # be used only in limited circumstances.

  def card_number
    if self.private_card_number
      n = self.private_card_number
      'xxxx-xxxx-xxxx-' + n[n.length-4..n.length]
    else
      ''
    end
  end

  # Note that the setter method allows the same variable to be set, and delegates through
  # the encryption process
  
  def card_number=(num)
    self.private_card_number=num
  end
  
  def to_label
    "#{card_type}:  #{card_number}"
  end
  
  def to_s
    "#{card_type}:  #{card_number}"
  end
     
  def cardholder
    return self.credit_card_account_party_role.party
  end
  
  def before_create
    token = CreditCardToken.new
    self.credit_card_token = token.cc_token.strip
  end   
 
end



