class CreditCard < ActiveRecord::Base
  
  require 'attr_encrypted'
  
  belongs_to  :postal_address
  has_one     :credit_card_account_party_role, :dependent => :destroy

  validates :first_name_on_card, :presence => {:message => 'First name on card cannot be blank.'}
  validates :last_name_on_card, :presence => {:message => 'Last name on card cannot be blank.'}
  #validates :card_type, :presence => {:message => 'Card type cannot be blank.'}
  #validates :expiration_month, :presence => {:message => 'Expiration month cannot be blank.'}
  #validates :expiration_year, :presence => {:message => 'Expiration year cannot be blank.'}
  validates :crypted_private_card_number, :presence => {:message => 'Card number cannot be blank.'}

  #the function EncryptionKey.get_key is meant to be overridden to provide a means for implementations to specify their 
  #own encryption schemes and locations. It will default to a simple string for development and testing
  attr_encrypted :private_card_number, :key => Rails.application.config.erp_commerce.encryption_key, :marshall => true, :attribute => :crypted_private_card_number

  # These methods are exposed for the purposes of displaying a version of the card number
  # string containing the last four digits of the card number. The idea is to make it
  # painfully obvious when any coder is using the private_card_number, which should
  # be used only in limited circumstances.

  def card_number
    if self.private_card_number
      CreditCard.mask_number(self.private_card_number)
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

  def add_party_with_role(party, role_type)
    
  end
     
  def cardholder
    return self.credit_card_account_party_role.party
  end
  
  def before_create
    token = CreditCardToken.new
    self.credit_card_token = token.cc_token.strip
  end

  class << self
    def mask_number(number)
      'XXXX-XXXX-XXXX-' + number[number.length-4..number.length]
    end
  end
 
end



