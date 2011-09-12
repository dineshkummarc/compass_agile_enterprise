class CreditCardAccountPartyRole < ActiveRecord::Base
  
  belongs_to :credit_card_account, :class_name => "CreditCardAccount"
  belongs_to :role_type
  belongs_to :party
  has_one :credit_card, :class_name => "CreditCard", :dependent => :destroy
  
end